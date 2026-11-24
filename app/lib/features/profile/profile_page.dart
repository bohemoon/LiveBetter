import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/constants.dart';
import '../../core/date_utils.dart';
import '../../data/backup/backup_codec.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../../shared/widgets/app_bottom_sheet.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/segmented_control.dart';
import '../../shared/widgets/switch_row.dart';
import '../../shared/widgets/toast.dart';
import '../notifications/reminder_scheduler.dart';
import '../today/today_providers.dart';
import 'settings_controller.dart';

/// 我的页：打卡项分区、习惯模式、提醒、隐私、经期、外观与数据管理。
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('我的')),
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
        const _SectionTitle('基础健康'),
        _Panel(
          children: [
            for (var i = 0; i < basicHabits.length; i++) ...[
              if (i > 0) const Divider(height: 20),
              _HabitRow(habit: basicHabits[i], hideSensitive: hideSensitive),
            ],
          ],
        ),
        const SizedBox(height: 20),
        const _SectionTitle('我的打卡项'),
        if (customHabits.isEmpty)
          _Panel(
            children: [
              Text(
                '还没有自定义项目，从下方选择常用项快速添加',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          )
        else
          _Panel(
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
        const _SectionTitle('习惯模式'),
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
        const _SectionTitle('提醒'),
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
              _ActionRow(
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
              _ActionRow(
                title: '通知与后台设置',
                subtitle: '收不到通知时，检查权限与电池优化',
                onTap: () => _openNotificationGuide(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const _SectionTitle('隐私'),
        AppCard(
          child: Column(
            children: [
              SwitchRow(
                title: '隐藏敏感项名称',
                subtitle: '对外显示为别名',
                value: settings.hideSensitiveNames,
                onChanged: controller.setHideSensitiveNames,
              ),
              const Divider(height: 20),
              SwitchRow(
                title: '应用锁',
                subtitle: settings.appLockEnabled
                    ? '已开启，重新进入需生物识别或密码解锁'
                    : '使用 4 位密码保护隐私数据',
                value: settings.appLockEnabled,
                onChanged: (enabled) => _toggleAppLock(context, ref, enabled),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const _SectionTitle('经期管理'),
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
              _ActionRow(
                title: '周期设置',
                subtitle: settings.periodStart == null
                    ? '记录最近一次开始日期，用于推算当前阶段'
                    : '上次开始 ${settings.periodStart} · 周期 ${settings.cycleLength} 天',
                onTap: () => _openPeriodSheet(context, ref, settings),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const _SectionTitle('外观'),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('主题色', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              SegmentedControl<AppTheme>(
                value: AppTheme.parse(settings.theme),
                options: [
                  for (final value in AppTheme.values)
                    SegmentedOption(value: value, label: value.label),
                ],
                onChanged: controller.setTheme,
              ),
              const Divider(height: 24),
              _ActionRow(
                title: '卡片背景',
                subtitle: '为单张打卡卡片选择背景图',
                onTap: () => _showBackgroundEntry(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const _SectionTitle('数据'),
        AppCard(
          child: Column(
            children: [
              _ActionRow(
                title: '导出数据',
                subtitle: '生成 JSON 备份，可分享到其他设备',
                onTap: () => _exportData(context, ref),
              ),
              const Divider(height: 20),
              _ActionRow(
                title: '导入数据',
                subtitle: '从 JSON 备份恢复，将覆盖当前数据',
                onTap: () => _importData(context, ref),
              ),
              const Divider(height: 20),
              _ActionRow(
                title: '填入演示数据',
                subtitle: '生成最近 $kDemoDataDays 天的打卡记录，便于预览统计',
                onTap: () => _confirmDemo(context, ref),
              ),
              const Divider(height: 20),
              _ActionRow(
                title: '清除全部数据',
                subtitle: '记录仅保存在本机，清除后不可恢复',
                danger: true,
                onTap: () => _confirmClear(context, ref),
              ),
            ],
          ),
        ),
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

  Future<void> _toggleAppLock(
    BuildContext context,
    WidgetRef ref,
    bool enabled,
  ) async {
    if (!enabled) {
      await ref.read(settingsControllerProvider.notifier).setAppLock(false);
      if (context.mounted) Toast.show(context, '应用锁已关闭');
      return;
    }
    final pin = await AppBottomSheet.show<String>(
      context: context,
      title: '设置应用锁密码',
      builder: (ctx) => const _PinSetupSheet(),
    );
    if (pin == null) return;
    await ref
        .read(settingsControllerProvider.notifier)
        .setAppLock(true, pin: pin);
    if (context.mounted) Toast.show(context, '应用锁已开启');
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

  Future<void> _showBackgroundEntry(BuildContext context) {
    return AppBottomSheet.show<void>(
      context: context,
      title: '卡片背景',
      builder: (ctx) => const _BackgroundSheet(),
    );
  }

  Future<void> _openNotificationGuide(BuildContext context) {
    return AppBottomSheet.show<void>(
      context: context,
      title: '通知与后台设置',
      builder: (ctx) => const _NotificationGuideSheet(),
    );
  }

  Future<void> _exportData(BuildContext context, WidgetRef ref) async {
    final service = ref.read(backupFileServiceProvider);
    if (!service.supported) {
      Toast.show(context, '当前平台暂不支持文件导出');
      return;
    }
    try {
      final json = await ref.read(maintenanceRepositoryProvider).exportJson();
      final shared =
          await service.shareJson(json, fileName: backupFileName());
      if (context.mounted && shared) {
        Toast.show(context, '备份文件已生成');
      }
    } catch (_) {
      if (context.mounted) Toast.show(context, '导出失败，请稍后重试');
    }
  }

  Future<void> _importData(BuildContext context, WidgetRef ref) async {
    final service = ref.read(backupFileServiceProvider);
    if (!service.supported) {
      Toast.show(context, '当前平台暂不支持文件导入');
      return;
    }
    final source = await service.pickJson();
    if (source == null) return;
    if (!context.mounted) return;
    final confirmed = await _confirm(
      context,
      title: '导入数据',
      message: '导入将覆盖当前全部打卡项、记录与设置，建议先导出备份。',
      confirmText: '确认导入',
      danger: true,
    );
    if (!confirmed) return;
    try {
      final summary =
          await ref.read(maintenanceRepositoryProvider).importJson(source);
      ref.invalidate(settingsControllerProvider);
      if (context.mounted) {
        Toast.show(
          context,
          '已导入 ${summary.habits} 个项目、${summary.records} 条记录',
        );
      }
    } on BackupException catch (error) {
      if (context.mounted) Toast.show(context, error.message);
    } catch (_) {
      if (context.mounted) Toast.show(context, '导入失败，数据已回滚');
    }
  }

  Future<void> _confirmDemo(BuildContext context, WidgetRef ref) async {
    final confirmed = await _confirm(
      context,
      title: '填入演示数据',
      message: '将生成最近 $kDemoDataDays 天的示例记录，不会影响今天的打卡。',
      confirmText: '生成',
    );
    if (!confirmed) return;
    await ref.read(maintenanceRepositoryProvider).seedDemoData();
    if (context.mounted) Toast.show(context, '已填入 $kDemoDataDays 天演示数据');
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final confirmed = await _confirm(
      context,
      title: '清除全部数据',
      message: '将删除所有打卡记录与设置，并恢复默认项目，且不可恢复。',
      confirmText: '确认清除',
      danger: true,
    );
    if (!confirmed) return;
    await ref.read(maintenanceRepositoryProvider).clearAllData();
    ref.invalidate(settingsControllerProvider);
    if (context.mounted) Toast.show(context, '已清除全部数据');
  }

  Future<bool> _confirm(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmText,
    bool danger = false,
  }) async {
    final result = await AppBottomSheet.show<bool>(
      context: context,
      title: title,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(message, style: Theme.of(ctx).textTheme.bodyMedium),
          const SizedBox(height: 20),
          FilledButton(
            style: danger
                ? FilledButton.styleFrom(
                    backgroundColor: Theme.of(ctx).colorScheme.error,
                  )
                : null,
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(confirmText),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('取消'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
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

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.title,
    this.subtitle,
    this.value,
    this.onTap,
    this.danger = false,
  });

  final String title;
  final String? subtitle;
  final String? value;
  final VoidCallback? onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: danger ? theme.colorScheme.error : null,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(subtitle!, style: theme.textTheme.bodySmall),
                  ],
                ],
              ),
            ),
            if (value != null) ...[
              const SizedBox(width: 12),
              Text(
                value!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ] else if (onTap != null)
              Icon(
                Icons.chevron_right,
                size: 20,
                color: theme.colorScheme.onSurfaceVariant,
              ),
          ],
        ),
      ),
    );
  }
}

class _PinSetupSheet extends ConsumerStatefulWidget {
  const _PinSetupSheet();

  @override
  ConsumerState<_PinSetupSheet> createState() => _PinSetupSheetState();
}

class _PinSetupSheetState extends ConsumerState<_PinSetupSheet> {
  final _first = TextEditingController();
  final _second = TextEditingController();

  @override
  void dispose() {
    _first.dispose();
    _second.dispose();
    super.dispose();
  }

  void _submit() {
    final first = _first.text.trim();
    final second = _second.text.trim();
    if (!RegExp(r'^\d{4}$').hasMatch(first)) {
      Toast.show(context, '请输入 4 位数字密码');
      return;
    }
    if (first != second) {
      Toast.show(context, '两次输入的密码不一致');
      return;
    }
    Navigator.of(context).pop(first);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '4 位数字，仅保存在本机，不保存明文。',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _first,
          obscureText: true,
          keyboardType: TextInputType.number,
          maxLength: 4,
          decoration: const InputDecoration(labelText: '输入密码'),
        ),
        TextField(
          controller: _second,
          obscureText: true,
          keyboardType: TextInputType.number,
          maxLength: 4,
          decoration: const InputDecoration(labelText: '再次输入'),
        ),
        const SizedBox(height: 8),
        FilledButton(onPressed: _submit, child: const Text('开启应用锁')),
      ],
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

/// 背景选择列表：逐项进入设置或清除。
class _BackgroundSheet extends ConsumerWidget {
  const _BackgroundSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final service = ref.watch(backgroundImageServiceProvider);
    final habits = ref.watch(habitsProvider).valueOrNull ?? const <Habit>[];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '为单张打卡卡片选择背景图，图片会压缩到 300KB 以内，仅保存在本机。',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        if (!service.supported)
          Text('当前平台暂不支持选图', style: theme.textTheme.bodyMedium)
        else
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.46,
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final habit in habits)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      habit.displayName(hideSensitive: false),
                      style: theme.textTheme.titleMedium,
                    ),
                    subtitle: Text(
                      habit.bgPath == null ? '未设置背景' : '已设置背景',
                      style: theme.textTheme.bodySmall,
                    ),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () => AppBottomSheet.show<void>(
                      context: context,
                      title: habit.displayName(hideSensitive: false),
                      builder: (ctx) => _BackgroundActions(habit: habit),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _BackgroundActions extends ConsumerWidget {
  const _BackgroundActions({required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(backgroundImageServiceProvider);
    final image = service.providerFor(habit.bgPath);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (image != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image(image: image, height: 140, fit: BoxFit.cover),
          ),
          const SizedBox(height: 16),
        ],
        FilledButton(
          onPressed: service.supported ? () => _pick(context, ref) : null,
          child: Text(habit.bgPath == null ? '选择图片' : '更换图片'),
        ),
        if (habit.bgPath != null) ...[
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => _clear(context, ref),
            child: const Text('清除背景'),
          ),
        ],
      ],
    );
  }

  Future<void> _pick(BuildContext context, WidgetRef ref) async {
    final relative =
        await ref.read(backgroundImageServiceProvider).pick(habit.id);
    if (relative == null) {
      if (context.mounted) Toast.show(context, '未选择图片或压缩后仍超过 300KB');
      return;
    }
    await ref.read(habitRepositoryProvider).save(
          habit.copyWith(bgPath: relative, updatedAt: nowIso()),
        );
    if (!context.mounted) return;
    Toast.show(context, '背景已更新');
    Navigator.of(context).pop();
  }

  Future<void> _clear(BuildContext context, WidgetRef ref) async {
    await ref.read(backgroundImageServiceProvider).remove(habit.id);
    await ref.read(habitRepositoryProvider).save(
          habit.copyWith(clearBgPath: true, updatedAt: nowIso()),
        );
    if (!context.mounted) return;
    Toast.show(context, '背景已清除');
    Navigator.of(context).pop();
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
