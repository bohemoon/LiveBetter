import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/providers.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../../domain/period_info.dart';
import '../../domain/reminders.dart';
import '../../domain/stats/habit_stats.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/toast.dart';
import '../profile/settings_controller.dart';
import 'today_providers.dart';

/// 今日页：日期问候、早睡倒计时与打卡项网格。
class TodayPage extends ConsumerWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider).valueOrNull;
    final hideSensitive = settings?.hideSensitiveNames ?? true;
    final sleepTarget = ref.watch(habitByIdProvider(habitIdSleep))?.targetTime;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              _Header(targetTime: sleepTarget),
              const SizedBox(height: 20),
              Expanded(
                child: ref.watch(habitsProvider).when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (error, _) => _ErrorView(message: error.toString()),
                      data: (habits) {
                        final visible = habits.where((habit) => habit.enabled).toList();
                        final date = ref.watch(todayDateProvider);
                        final periodInfo = settings == null
                            ? null
                            : computePeriodInfo(
                                enabled: settings.periodEnabled,
                                start: settings.periodStart,
                                periodLength: settings.periodLength,
                                cycleLength: settings.cycleLength,
                                today: date,
                              );
                        final records = ref.watch(allRecordsProvider).valueOrNull ??
                            const <DailyRecord>[];
                        final pending = settings != null &&
                                settings.reminderEnabled &&
                                _reminderReached(settings.reminderTime) &&
                                visible.isNotEmpty
                            ? pendingReminderHabits(
                                habits: visible,
                                records: records,
                                today: date,
                              )
                            : const <Habit>[];

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (periodInfo != null) ...[
                              _PeriodCard(
                                info: periodInfo,
                                cycleLength: settings!.cycleLength,
                                onTap: () => context.go('/profile'),
                              ),
                              const SizedBox(height: 12),
                            ],
                            if (pending.isNotEmpty) ...[
                              _ReminderBanner(count: pending.length),
                              const SizedBox(height: 12),
                            ],
                            Expanded(
                              child: visible.isEmpty
                                  ? const _EmptyView()
                                  : GridView.builder(
                                      padding: const EdgeInsets.only(bottom: 24),
                                      itemCount: visible.length,
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        mainAxisSpacing: 12,
                                        crossAxisSpacing: 12,
                                        childAspectRatio: 1.05,
                                      ),
                                      itemBuilder: (context, index) {
                                        final habit = visible[index];
                                        return _HabitCard(
                                          habit: habit,
                                          hideSensitive: hideSensitive,
                                          onTap: () =>
                                              context.push('/today/habit/${habit.id}'),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        );
                      },
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 当前时间是否已过提醒时间。
  bool _reminderReached(String reminderTime) {
    final parts = reminderTime.split(':');
    if (parts.length != 2) return false;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return false;
    final now = DateTime.now();
    return now.hour * 60 + now.minute >= hour * 60 + minute;
  }
}

/// 经期提示卡：显示经期第几天或距离下次天数。
class _PeriodCard extends StatelessWidget {
  const _PeriodCard({
    required this.info,
    required this.cycleLength,
    required this.onTap,
  });

  final PeriodInfo info;
  final int cycleLength;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return AppCard(
      color: info.onPeriod ? scheme.surfaceContainerHighest : null,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            Icons.favorite_border,
            size: 18,
            color: info.onPeriod ? scheme.primary : scheme.onSurfaceVariant,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  info.onPeriod
                      ? '经期第 ${info.day} 天'
                      : '距离下次经期 ${info.daysLeft} 天',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  info.onPeriod ? '记得多休息，少碰冰饮' : '按 $cycleLength 天周期推算',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            size: 20,
            color: scheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

/// 到点后的中性提醒，包含主动型与计量未达标项。
class _ReminderBanner extends StatelessWidget {
  const _ReminderBanner({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      color: theme.colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(Icons.notifications_none, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '今天还有 $count 项可以稍后完成，按自己的节奏来',
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

const String habitIdSleep = 'sleep_early';

class _Header extends StatefulWidget {
  const _Header({this.targetTime});

  final String? targetTime;

  @override
  State<_Header> createState() => _HeaderState();
}

class _HeaderState extends State<_Header> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 5) return '夜深了';
    if (hour < 11) return '早上好';
    if (hour < 14) return '中午好';
    if (hour < 18) return '下午好';
    return '晚上好';
  }

  String _countdownText(DateTime now) {
    final target = widget.targetTime;
    if (target == null) return '';
    final parts = target.split(':');
    if (parts.length != 2) return '';
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return '';
    final targetAt = DateTime(now.year, now.month, now.day, hour, minute);
    final diff = targetAt.difference(now);
    if (diff.isNegative) return '已过 $target 目标时间';
    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;
    if (hours > 0) return '距 $target 还有 $hours 小时 $minutes 分';
    return '距 $target 还有 $minutes 分钟';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final dateText = '${DateFormat('M月d日').format(now)} ${_weekdays[now.weekday - 1]}';
    final countdown = _countdownText(now);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(dateText, style: theme.textTheme.bodySmall),
        const SizedBox(height: 6),
        Text('$_greeting，今天也慢慢来', style: theme.textTheme.headlineSmall),
        if (countdown.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(countdown, style: theme.textTheme.bodySmall),
        ],
      ],
    );
  }
}

const List<String> _weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];

class _HabitCard extends ConsumerWidget {
  const _HabitCard({
    required this.habit,
    required this.hideSensitive,
    required this.onTap,
  });

  final Habit habit;
  final bool hideSensitive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final stats = ref.watch(habitStatsProvider(habit.id)) ?? HabitStats.empty;

    return AppCard(
      onTap: onTap,
      image: ref
          .watch(backgroundImageServiceProvider)
          .providerFor(habit.bgPath),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  habit.type.label,
                  style: theme.textTheme.bodySmall?.copyWith(color: scheme.primary),
                ),
              ),
              const Spacer(),
              if (habit.isRequired)
                Icon(Icons.star_rounded, size: 16, color: scheme.primary),
            ],
          ),
          const Spacer(),
          Text(
            habit.displayName(hideSensitive: hideSensitive),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          _cardSubtitle(context, theme, stats, ref),
        ],
      ),
    );
  }

  Widget _cardSubtitle(
    BuildContext context,
    ThemeData theme,
    HabitStats stats,
    WidgetRef ref,
  ) {
    final dateKey = ref.watch(todayDateProvider);
    if (habit.type == HabitType.meter) {
      final goal = habit.goal ?? 1;
      final amount = stats.amountToday;
      final reached = amount >= goal;
      return Row(
        children: [
          Expanded(
            child: Text(
              '$amount / $goal ${habit.unit ?? ''}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: reached ? theme.colorScheme.primary : null,
              ),
            ),
          ),
          SizedBox(
            width: 28,
            height: 28,
            child: IconButton(
              padding: EdgeInsets.zero,
              iconSize: 20,
              visualDensity: VisualDensity.compact,
              onPressed: reached
                  ? null
                  : () async {
                      final next = await ref
                          .read(checkInControllerProvider)
                          .incrementMeter(habit, dateKey, amount);
                      if (next >= goal && context.mounted) {
                        Toast.show(context, '今日已达标');
                      }
                    },
              icon: const Icon(Icons.add_circle_outline),
            ),
          ),
        ],
      );
    }

    if (habit.type == HabitType.periodic) {
      final due = stats.nextDueInDays ?? 0;
      final text = due == 0 ? '今天到期' : '距下次 $due 天';
      return Text(
        stats.doneToday ? '今天已完成' : text,
        style: theme.textTheme.bodySmall,
      );
    }

    if (habit.type == HabitType.passive) {
      final record = ref.watch(todayRecordProvider(habit.id));
      final slipped = record?.status == RecordStatus.slip;
      return Text(
        slipped ? '今天重新开始' : '已坚持 ${stats.currentStreak} 天',
        style: theme.textTheme.bodySmall,
      );
    }

    return Text(
      stats.doneToday
          ? '今日已完成 · 连续 ${stats.currentStreak} 天'
          : '连续 ${stats.currentStreak} 天',
      style: theme.textTheme.bodySmall,
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '数据加载失败\n$message',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('还没有启用的打卡项', style: Theme.of(context).textTheme.bodySmall),
    );
  }
}
