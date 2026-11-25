import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_info.dart';
import '../../core/constants.dart';
import '../../core/date_utils.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../../shared/widgets/app_bottom_sheet.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/segmented_control.dart';
import '../../shared/widgets/switch_row.dart';
import '../../shared/widgets/toast.dart';
import '../notifications/reminder_scheduler.dart';
import '../today/today_providers.dart';
import 'profile_common.dart';
import 'settings_controller.dart';

/// 我的页：打卡项分区、习惯模式、提醒、隐私、经期、外观与数据管理。
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
        actions: [
          IconButton(
            tooltip: '设置',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/profile/settings'),
          ),
        ],
      ),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        error: (error, _) => Center(
          child: Text('设置读取失败', style: Theme.of(context).textTheme.bodySmall),
        ),
        data: (settings) => _ProfileBody(settings: settings),
      ),
    );
  }
}

class _ProfileBody extends ConsumerWidget {
  const _ProfileBody({required this.settings});

  final AppSettingsData settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(settingsControllerProvider.notifier);
    final habits = ref.watch(habitsProvider).valueOrNull ?? const <Habit>[];
    final basicHabits =
        habits.where((habit) => HabitIds.basic.contains(habit.id)).toList();
    final customHabits =
        habits.where((habit) => !HabitIds.basic.contains(habit.id)).toList();
    final hideSensitive = settings.hideSensitiveNames;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        const ProfileSectionTitle('基础健康'),
        ProfilePanel(
          children: [
            for (var i = 0; i < basicHabits.length; i++) ...[
              if (i > 0) const Divider(height: 20),
              _HabitRow(habit: basicHabits[i], hideSensitive: hideSensitive),
            ],
          ],
        ),
        const SizedBox(height: 20),
        const ProfileSectionTitle('我的打卡项'),
        if (customHabits.isEmpty)
          ProfilePanel(
            children: [
              Text(
                '还没有自定义项目，从下方选择常用项快速添加',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          )
        else
          ProfilePanel(
            children: [
              for (var i = 0; i < customHabits.length; i++) ...[
                if (i > 0) const Divider(height: 20),
                _HabitRow(habit: customHabits[i], hideSensitive: hideSensitive),
              ],
            ],
          ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () => context.push('/profile/habit/new'),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('添加打卡项'),
        ),
        const SizedBox(height: 20),
        const ProfileSectionTitle('习惯模式'),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SegmentedControl<bool>(
                value: settings.strictMode,
                options: const [
                  SegmentedOption(value: false, label: '温和'),
                  SegmentedOption(value: true, label: '严格'),
                ],
                onChanged: controller.setStrictMode,
              ),
              const SizedBox(height: 10),
              Text(
                settings.strictMode
                    ? '没有豁免，断签即从头开始'
                    : '每周 1 次豁免，断签不中断连续天数',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const ProfileSectionTitle('提醒'),
        AppCard(
          child: Column(
            children: [
              SwitchRow(
                title: '每日提醒',
                subtitle: '到点后在首页显示一条中性提示',
                value: settings.reminderEnabled,
                onChanged: (enabled) async {
                  if (enabled) {
                    await ref
                        .read(notificationServiceProvider)
                        .requestPermission();
                  }
                  await controller.setReminderEnabled(enabled);
                },
              ),
              const Divider(height: 20),
              ProfileActionRow(
                title: '提醒时间',
                subtitle: '睡前留出一点缓冲',
                value: settings.reminderTime,
                onTap: settings.reminderEnabled
                    ? () => _pickReminderTime(context, ref, settings)
                    : null,
              ),
              const Divider(height: 20),
              SwitchRow(
                title: '周期项到期提醒',
                subtitle: '到期当天 09:00 提醒一次',
                value: settings.periodicReminderEnabled,
                onChanged: controller.setPeriodicReminderEnabled,
              ),
              const Divider(height: 20),
              ProfileActionRow(
                title: '通知与后台设置',
                subtitle: '收不到通知时，检查权限与电池优化',
                onTap: () => _openNotificationGuide(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const ProfileSectionTitle('经期管理'),
        AppCard(
          child: Column(
            children: [
              SwitchRow(
                title: '经期提醒',
                subtitle: '开启后在首页显示周期进度',
                value: settings.periodEnabled,
                onChanged: (enabled) {
                  if (enabled && settings.periodStart == null) {
                    _openPeriodSheet(context, ref, settings);
                    return;
                  }
                  controller.setPeriodEnabled(enabled);
                },
              ),
              const Divider(height: 20),
              ProfileActionRow(
                title: '周期设置',
                subtitle: settings.periodStart == null
                    ? '记录最近一次开始日期，用于推算当前阶段'
                    : '上次开始 ${settings.periodStart} · 周期 ${settings.cycleLength} 天',
                onTap: () => _openPeriodSheet(context, ref, settings),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        const _AppFooter(),
      ],
    );
  }

  Future<void> _pickReminderTime(
    BuildContext context,
    WidgetRef ref,
    AppSettingsData settings,
  ) async {
    final parts = settings.reminderTime.split(':');
    final initial = TimeOfDay(
      hour: int.tryParse(parts.isNotEmpty ? parts[0] : '') ?? 22,
      minute: int.tryParse(parts.length > 1 ? parts[1] : '') ?? 45,
    );
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return;
    final text =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    await ref.read(settingsControllerProvider.notifier).setReminderTime(text);
  }

  Future<void> _openPeriodSheet(
    BuildContext context,
    WidgetRef ref,
    AppSettingsData settings,
  ) async {
    await AppBottomSheet.show<void>(
      context: context,
      title: '经期管理',
      builder: (ctx) => _PeriodSheet(settings: settings),
    );
  }

  Future<void> _openNotificationGuide(BuildContext context) {
    return AppBottomSheet.show<void>(
      context: context,
      title: '通知与后台设置',
      builder: (ctx) => const _NotificationGuideSheet(),
    );
  }
}

class _HabitRow extends ConsumerWidget {
  const _HabitRow({required this.habit, required this.hideSensitive});

  final Habit habit;
  final bool hideSensitive;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final subtitle = switch (habit.type) {
      HabitType.active => '主动打卡',
      HabitType.passive => '被动保持',
      HabitType.meter => '累计记录 · 目标 ${habit.goal ?? 1} ${habit.unit ?? ''}',
      HabitType.periodic => '周期记录 · 每 ${habit.intervalDays ?? 180} 天',
    };

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => context.push('/profile/habit/${habit.id}/edit'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.displayName(hideSensitive: hideSensitive),
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    habit.isRequired ? '$subtitle · 核心项不可关闭' : subtitle,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (habit.isRequired)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '必选',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              )
            else
              Switch.adaptive(
                value: habit.enabled,
                onChanged: (value) => ref
                    .read(habitRepositoryProvider)
                    .setEnabled(habit.id, value),
              ),
          ],
        ),
      ),
    );
  }
}

class _PeriodSheet extends ConsumerStatefulWidget {
  const _PeriodSheet({required this.settings});

  final AppSettingsData settings;

  @override
  ConsumerState<_PeriodSheet> createState() => _PeriodSheetState();
}

class _PeriodSheetState extends ConsumerState<_PeriodSheet> {
  late String _start;
  late final TextEditingController _cycle;
  late final TextEditingController _length;

  @override
  void initState() {
    super.initState();
    _start = widget.settings.periodStart ?? todayYmd();
    _cycle = TextEditingController(text: '${widget.settings.cycleLength}');
    _length = TextEditingController(text: '${widget.settings.periodLength}');
  }

  @override
  void dispose() {
    _cycle.dispose();
    _length.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: parseYmd(_start),
      firstDate: DateTime(now.year - 5),
      lastDate: now,
    );
    if (picked == null) return;
    setState(() => _start = formatYmd(picked));
  }

  Future<void> _save() async {
    final cycle = int.tryParse(_cycle.text.trim()) ?? 0;
    final length = int.tryParse(_length.text.trim()) ?? 0;
    if (cycle < 15 || cycle > 60) {
      Toast.show(context, '周期长度需在 15–60 天之间');
      return;
    }
    if (length < 1 || length > 14) {
      Toast.show(context, '经期天数需在 1–14 天之间');
      return;
    }
    await ref.read(settingsControllerProvider.notifier).savePeriod(
          start: _start,
          periodLength: length,
          cycleLength: cycle,
        );
    if (!mounted) return;
    Toast.show(context, '经期设置已保存');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '用于推算当前阶段，数据只保存在本机。',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () async {
            setState(() => _start = todayYmd());
          },
          child: const Text('今天来了'),
        ),
        const SizedBox(height: 12),
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _pickDate,
          child: InputDecorator(
            decoration: const InputDecoration(labelText: '上次开始日期'),
            child: Text(_start),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _cycle,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: '周期长度（天）'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _length,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: '经期天数'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        FilledButton(onPressed: _save, child: const Text('保存')),
      ],
    );
  }
}

/// 通知权限与国产 ROM 后台限制的引导。
class _NotificationGuideSheet extends ConsumerStatefulWidget {
  const _NotificationGuideSheet();

  @override
  ConsumerState<_NotificationGuideSheet> createState() =>
      _NotificationGuideSheetState();
}

class _NotificationGuideSheetState
    extends ConsumerState<_NotificationGuideSheet> {
  bool _busy = false;

  Future<void> _requestPermission() async {
    if (_busy) return;
    setState(() => _busy = true);
    final granted = await ref
        .read(notificationServiceProvider)
        .requestPermission();
    if (!mounted) return;
    setState(() => _busy = false);
    Toast.show(context, granted ? '通知权限已就绪' : '未获得通知权限，请到系统设置中开启');
  }

  Future<void> _resync() async {
    final settings = ref.read(settingsControllerProvider).valueOrNull;
    if (settings == null) return;
    final habits = ref.read(habitsProvider).valueOrNull ?? const <Habit>[];
    final records =
        ref.read(allRecordsProvider).valueOrNull ?? const <DailyRecord>[];
    await ref.read(reminderSchedulerProvider).sync(
          settings: settings,
          habits: habits,
          records: records,
          today: todayYmd(),
        );
    if (mounted) Toast.show(context, '已重新安排提醒');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '1. 通知权限\nAndroid 13 及以上需要在系统弹窗中允许通知。\n\n'
          '2. 电池优化\n设置 → 应用 → LiveBetter → 电池 → 选择「无限制」或关闭电池优化。\n\n'
          '3. 自启动与后台运行\n国产 ROM（小米 / 华为 / OPPO / vivo 等）需在系统管家中允许自启动并保持后台运行，否则提醒可能被清理。',
          style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
        ),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: _busy ? null : _requestPermission,
          child: const Text('申请通知权限'),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: _resync,
          child: const Text('重新安排提醒'),
        ),
      ],
    );
  }
}

/// 页脚：版本号运行时读取，避免发版后文案滞后（偏差 #14）。
class _AppFooter extends ConsumerWidget {
  const _AppFooter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = ref.watch(packageInfoProvider).valueOrNull;
    final theme = Theme.of(context).textTheme.bodySmall;
    final version = info == null
        ? '版本读取中'
        : 'v${info.version} (${info.buildNumber})';

    return Column(
      children: [
        Text('LiveBetter $version', style: theme),
        const SizedBox(height: 4),
        Text('开源 · Apache-2.0 ｜ 数据仅保存在本机', style: theme),
      ],
    );
  }
}
