import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../../domain/stats/habit_stats.dart';
import '../profile/settings_controller.dart';
import 'check_in_controller.dart';

/// 全部打卡项，数据变化自动推送。
final habitsProvider = StreamProvider<List<Habit>>(
  (ref) => ref.watch(habitRepositoryProvider).watchAll(),
);

/// 全部记录，任意写入后自动刷新统计。
final allRecordsProvider = StreamProvider<List<DailyRecord>>(
  (ref) => ref.watch(recordRepositoryProvider).watchAll(),
);

/// 当前日期（跨日自动切换）的记录。
final todayRecordsProvider = StreamProvider<List<DailyRecord>>((ref) {
  final date = ref.watch(todayDateProvider);
  return ref.watch(recordRepositoryProvider).watchByDate(date);
});

/// 按 ID 查找打卡项。
final habitByIdProvider = Provider.family<Habit?, String>((ref, id) {
  final habits = ref.watch(habitsProvider).valueOrNull;
  if (habits == null) return null;
  for (final habit in habits) {
    if (habit.id == id) return habit;
  }
  return null;
});

/// 单个打卡项今天的记录。
final todayRecordProvider = Provider.family<DailyRecord?, String>((ref, habitId) {
  final date = ref.watch(todayDateProvider);
  final records = ref.watch(allRecordsProvider).valueOrNull;
  if (records == null) return null;
  for (final record in records) {
    if (record.habitId == habitId && record.date == date) return record;
  }
  return null;
});

typedef RecordOnDateKey = ({String habitId, String date});

/// 指定打卡项在指定日期的记录，用于早睡补卡窗口与历史视图。
final recordOnDateProvider =
    Provider.family<DailyRecord?, RecordOnDateKey>((ref, key) {
  final records = ref.watch(allRecordsProvider).valueOrNull;
  if (records == null) return null;
  for (final record in records) {
    if (record.habitId == key.habitId && record.date == key.date) return record;
  }
  return null;
});

/// 单个打卡项的统计结果。
final habitStatsProvider = Provider.family<HabitStats?, String>((ref, habitId) {
  final habit = ref.watch(habitByIdProvider(habitId));
  final records = ref.watch(allRecordsProvider).valueOrNull;
  if (habit == null || records == null) return null;
  final strictMode =
      ref.watch(settingsControllerProvider).valueOrNull?.strictMode ?? false;
  return computeHabitStats(
    habit: habit,
    records: records,
    today: ref.watch(todayDateProvider),
    strictMode: strictMode,
  );
});

final checkInControllerProvider = Provider<CheckInController>(
  (ref) => CheckInController(ref.watch(recordRepositoryProvider)),
);
