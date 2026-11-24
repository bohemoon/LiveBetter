import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/providers.dart';
import '../../data/models/models.dart';
import '../../domain/habit_day_status.dart';
import '../../shared/widgets/app_card.dart';
import 'today_providers.dart';

/// 单项目历史视图：按天查看达成状态。
class HabitHistoryPage extends ConsumerWidget {
  const HabitHistoryPage({super.key, required this.habitId});

  final String habitId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final habit = ref.watch(habitByIdProvider(habitId));
    final records = ref.watch(allRecordsProvider).valueOrNull;
    final today = ref.watch(todayDateProvider);

    if (habit == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('项目历史')),
        body: Center(
          child: Text('未找到该打卡项', style: theme.textTheme.bodySmall),
        ),
      );
    }
    if (records == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('项目历史')),
        body: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    final byDate = <String, DailyRecord>{};
    for (final record in records) {
      if (record.habitId == habitId) byDate[record.date] = record;
    }

    final days = _recentDays(habit.createdAt, today);
    final achievedCount =
        days.where((day) => describeHabitDay(habit, byDate[day]).achieved).length;

    return Scaffold(
      appBar: AppBar(title: Text('${habit.name} · 历史')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          AppCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _Summary(label: '近期天数', value: '${days.length}'),
                _Summary(label: '达成', value: '$achievedCount'),
                _Summary(label: '类型', value: habit.type.label),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('最近 ${days.length} 天', style: theme.textTheme.bodySmall),
          const SizedBox(height: 8),
          for (final day in days) ...[
            _DayRow(habit: habit, date: day, record: byDate[day]),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  /// 最近 60 天内且不早于项目创建日期的日期，最新在前。
  List<String> _recentDays(String createdAt, String today) {
    final todayDate = DateTime.parse(today);
    final created = DateTime.parse(createdAt);
    final earliest = todayDate.subtract(const Duration(days: 59));
    var cursor = created.isAfter(earliest) ? created : earliest;
    final days = <String>[];
    while (!cursor.isAfter(todayDate)) {
      days.add(DateFormat('yyyy-MM-dd').format(cursor));
      cursor = cursor.add(const Duration(days: 1));
    }
    return days.reversed.toList(growable: false);
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.label, required this.value});

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

class _DayRow extends StatelessWidget {
  const _DayRow({
    required this.habit,
    required this.date,
    required this.record,
  });

  final Habit habit;
  final String date;
  final DailyRecord? record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = describeHabitDay(habit, record);
    final weekday = const ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    final parsed = DateTime.parse(date);

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${DateFormat('M月d日').format(parsed)} ${weekday[parsed.weekday - 1]}',
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Text(
            status.label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: status.achieved
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
