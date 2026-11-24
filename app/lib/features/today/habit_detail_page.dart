import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../core/date_utils.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../../domain/check_in_rules.dart';
import '../../domain/stats/habit_stats.dart';
import '../../shared/widgets/app_bottom_sheet.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/toast.dart';
import 'today_providers.dart';

/// 打卡项详情：四种类型的打卡 / 撤销入口与统计。
class HabitDetailPage extends ConsumerWidget {
  const HabitDetailPage({super.key, required this.habitId});

  final String habitId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habit = ref.watch(habitByIdProvider(habitId));

    if (habit == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Text(
            '未找到该打卡项',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      );
    }

    final stats = ref.watch(habitStatsProvider(habitId)) ?? HabitStats.empty;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(habit.name)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Text(
            habit.type.label + (habit.isRequired ? ' · 必选' : ''),
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          _StatsCard(habit: habit, stats: stats),
          const SizedBox(height: 12),
          _BackgroundCard(habit: habit),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => context.push('/today/habit/${habit.id}/history'),
              child: const Text('查看每日记录'),
            ),
          ),
          const SizedBox(height: 12),
          Text('今日', style: theme.textTheme.bodySmall),
          const SizedBox(height: 8),
          AppCard(
            child: switch (habit.type) {
              HabitType.active => _ActiveActions(habit: habit),
              HabitType.passive => _PassiveActions(habit: habit),
              HabitType.meter => _MeterActions(habit: habit),
              HabitType.periodic => _PeriodicActions(habit: habit),
            },
          ),
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.habit, required this.stats});

  final Habit habit;
  final HabitStats stats;

  @override
  Widget build(BuildContext context) {
    if (habit.type == HabitType.periodic) {
      return AppCard(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _StatItem(label: '下次到期', value: stats.nextDueDate ?? '—'),
            _StatItem(
              label: '状态',
              value: stats.doneToday ? '今天已完成' : '待完成',
            ),
          ],
        ),
      );
    }
    return AppCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _StatItem(label: '当前连续', value: '${stats.currentStreak} 天'),
          _StatItem(label: '最长纪录', value: '${stats.longestStreak} 天'),
          _StatItem(label: '累计', value: '${stats.totalDays} 天'),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(value, style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}

/// 卡片背景：选择图片（压缩到 300KB 内）或清除。
class _BackgroundCard extends ConsumerWidget {
  const _BackgroundCard({required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final service = ref.watch(backgroundImageServiceProvider);
    final image = service.providerFor(habit.bgPath);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('卡片背景', style: theme.textTheme.bodyMedium),
          if (image != null) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image(
                image: image,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ],
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed:
                    service.supported ? () => _pick(context, ref) : null,
                child: Text(habit.bgPath == null ? '选择图片' : '更换图片'),
              ),
              if (habit.bgPath != null)
                TextButton(
                  onPressed: () => _clear(context, ref),
                  child: const Text('清除背景'),
                ),
            ],
          ),
          if (!service.supported)
            Text(
              '当前平台暂不支持选图',
              style: theme.textTheme.bodySmall,
            ),
        ],
      ),
    );
  }

  Future<void> _pick(BuildContext context, WidgetRef ref) async {
    final relative = await ref
        .read(backgroundImageServiceProvider)
        .pick(habit.id);
    if (relative == null) {
      if (context.mounted) Toast.show(context, '未选择图片或压缩后仍超过 300KB');
      return;
    }
    await ref.read(habitRepositoryProvider).save(
          habit.copyWith(bgPath: relative, updatedAt: nowIso()),
        );
    if (context.mounted) Toast.show(context, '背景已更新');
  }

  Future<void> _clear(BuildContext context, WidgetRef ref) async {
    await ref.read(backgroundImageServiceProvider).remove(habit.id);
    await ref.read(habitRepositoryProvider).save(
          habit.copyWith(clearBgPath: true, updatedAt: nowIso()),
        );
    if (context.mounted) Toast.show(context, '背景已清除');
  }
}

class _ActiveActions extends ConsumerWidget {
  const _ActiveActions({required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final date = checkInDateFor(habit, now);
    final record = ref.watch(recordOnDateProvider((habitId: habit.id, date: date)));
    final isMakeupDate = date != ref.watch(todayDateProvider);

    if (record == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (habit.targetTime != null)
            Text('目标时间 ${habit.targetTime}', style: theme.textTheme.bodySmall),
          if (isMakeupDate) ...[
            const SizedBox(height: 4),
            Text(
              '补卡窗口：现在打卡记入昨日',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ],
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () async {
              final outcome = await ref
                  .read(checkInControllerProvider)
                  .checkInActive(habit);
              if (context.mounted) {
                Toast.show(
                  context,
                  isMakeupDate ? '${outcome.message}（记入昨日）' : outcome.message,
                );
              }
            },
            child: Text(habit.targetTime != null ? '我要睡了' : '打卡'),
          ),
        ],
      );
    }

    final success = record.status == RecordStatus.success;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          success ? '今天已完成' : '今天未在目标时间前完成',
          style: theme.textTheme.bodyMedium,
        ),
        if (isMakeupDate) ...[
          const SizedBox(height: 4),
          Text('该记录归属昨日', style: theme.textTheme.bodySmall),
        ],
        const SizedBox(height: 8),
        TextButton(
          onPressed: () async {
            await ref.read(checkInControllerProvider).undo(habit.id, date);
            if (context.mounted) Toast.show(context, '已撤销今日记录');
          },
          child: const Text('撤销今日记录'),
        ),
      ],
    );
  }
}

class _PassiveActions extends ConsumerWidget {
  const _PassiveActions({required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final record = ref.watch(todayRecordProvider(habit.id));
    final date = ref.watch(todayDateProvider);
    final slipped = record?.status == RecordStatus.slip;

    if (slipped) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('今天已重新开始计数，历史纪录保留', style: theme.textTheme.bodyMedium),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () async {
              await ref.read(checkInControllerProvider).undo(habit.id, date);
              if (context.mounted) Toast.show(context, '已撤销破戒记录');
            },
            child: const Text('撤销'),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('保持中，无需操作', style: theme.textTheme.bodyMedium),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => _confirmSlip(context, ref, habit, date),
          child: const Text('今天破戒'),
        ),
      ],
    );
  }

  Future<void> _confirmSlip(
    BuildContext context,
    WidgetRef ref,
    Habit habit,
    String date,
  ) async {
    final confirmed = await AppBottomSheet.show<bool>(
      context: context,
      title: '确认今天破戒？',
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '将重新开始计数，最长纪录与累计天数会保留。',
            style: Theme.of(ctx).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('确认'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('取消'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(checkInControllerProvider).markSlip(habit, date);
    if (context.mounted) Toast.show(context, '已重新开始计数');
  }
}

class _MeterActions extends ConsumerWidget {
  const _MeterActions({required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final stats = ref.watch(habitStatsProvider(habit.id)) ?? HabitStats.empty;
    final date = ref.watch(todayDateProvider);
    final goal = habit.goal ?? 1;
    final amount = stats.amountToday;
    final step = habit.step ?? 1;
    final controller = ref.read(checkInControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text('$amount', style: theme.textTheme.headlineSmall),
            Text(' / $goal ${habit.unit ?? ''}', style: theme.textTheme.bodyMedium),
          ],
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: goal == 0 ? 0 : (amount / goal).clamp(0, 1),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton(
              onPressed: amount <= 0
                  ? null
                  : () => controller.decrementMeter(habit, date, amount),
              child: Text('-$step'),
            ),
            const SizedBox(width: 24),
            FilledButton(
              onPressed: () async {
                final next = await controller.incrementMeter(habit, date, amount);
                if (next >= goal && context.mounted) {
                  Toast.show(context, '今日已达标');
                }
              },
              child: Text('+$step'),
            ),
          ],
        ),
        if (amount >= goal) ...[
          const SizedBox(height: 8),
          Text(
            '今日已达标',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary),
          ),
        ],
      ],
    );
  }
}

class _PeriodicActions extends ConsumerWidget {
  const _PeriodicActions({required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final stats = ref.watch(habitStatsProvider(habit.id)) ?? HabitStats.empty;
    final date = ref.watch(todayDateProvider);
    final record = ref.watch(todayRecordProvider(habit.id));
    final doneToday = record?.status == RecordStatus.success;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          doneToday
              ? '今天已完成，下次到期 ${stats.nextDueDate ?? '—'}'
              : '距下次到期 ${stats.nextDueInDays ?? 0} 天',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: doneToday
              ? null
              : () async {
                  await ref
                      .read(checkInControllerProvider)
                      .completePeriodic(habit, date);
                  if (context.mounted) Toast.show(context, '已完成本次');
                },
          child: const Text('完成本次'),
        ),
        if (doneToday) ...[
          const SizedBox(height: 8),
          TextButton(
            onPressed: () async {
              await ref.read(checkInControllerProvider).undo(habit.id, date);
              if (context.mounted) Toast.show(context, '已撤销今日记录');
            },
            child: const Text('撤销今日记录'),
          ),
        ],
      ],
    );
  }
}
