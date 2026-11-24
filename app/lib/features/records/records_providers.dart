import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../data/models/models.dart';
import '../../domain/stats/records_stats.dart';
import '../today/today_providers.dart';

/// 记录页当前浏览的月份，统一为当月 1 日。
final recordsMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month);
});

/// 近 7 天稳定度。
final weekStabilityProvider = Provider<WeekStability>((ref) {
  final habits = ref.watch(habitsProvider).valueOrNull ?? const <Habit>[];
  final records = ref.watch(allRecordsProvider).valueOrNull ?? const <DailyRecord>[];
  return computeWeekStability(
    habits: habits,
    records: records,
    today: ref.watch(todayDateProvider),
  );
});

/// 当前浏览月份的月度小结。
final monthSummaryProvider = Provider<MonthSummary>((ref) {
  final habits = ref.watch(habitsProvider).valueOrNull ?? const <Habit>[];
  final records = ref.watch(allRecordsProvider).valueOrNull ?? const <DailyRecord>[];
  final month = ref.watch(recordsMonthProvider);
  return computeMonthSummary(
    habits: habits,
    records: records,
    today: ref.watch(todayDateProvider),
    year: month.year,
    month: month.month,
  );
});
