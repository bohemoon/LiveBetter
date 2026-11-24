import 'dart:math';

import '../core/constants.dart';
import '../core/date_utils.dart';
import '../data/models/models.dart';

/// 生成最近 34 天的演示记录，覆盖四种类型。
///
/// - 主动型大多数天成功，少量留白；
/// - 被动型间隔出现破戒；
/// - 计量型在目标值上下浮动；
/// - 周期型按间隔完成一次；
/// - 不超过项目创建日期，也不写入今天之后。
List<DailyRecord> buildDemoRecords({
  required List<Habit> habits,
  required String today,
  int days = kDemoDataDays,
}) {
  final random = Random(20261124);
  final todayDate = parseYmd(today);
  final records = <DailyRecord>[];

  for (var offset = days; offset >= 1; offset--) {
    final date = todayDate.subtract(Duration(days: offset));
    final dateKey = formatYmd(date);
    final recordedAt = DateTime(
      date.year,
      date.month,
      date.day,
      22,
      15,
    ).toIso8601String();

    for (final habit in habits) {
      if (dateKey.compareTo(habit.createdAt) < 0) continue;
      switch (habit.type) {
        case HabitType.active:
          if (random.nextDouble() < 0.82) {
            records.add(DailyRecord(
              habitId: habit.id,
              date: dateKey,
              status: RecordStatus.success,
              recordedAt: recordedAt,
            ));
          }
        case HabitType.passive:
          if (offset % 9 == 0) {
            records.add(DailyRecord(
              habitId: habit.id,
              date: dateKey,
              status: RecordStatus.slip,
              recordedAt: recordedAt,
            ));
          }
        case HabitType.meter:
          final goal = habit.goal ?? 1;
          final roll = random.nextDouble();
          if (roll < 0.7) {
            records.add(DailyRecord(
              habitId: habit.id,
              date: dateKey,
              amount: goal,
              recordedAt: recordedAt,
            ));
          } else if (roll < 0.9) {
            records.add(DailyRecord(
              habitId: habit.id,
              date: dateKey,
              amount: max(1, goal ~/ 2),
              recordedAt: recordedAt,
            ));
          }
        case HabitType.periodic:
          final interval = habit.intervalDays ?? 180;
          if (offset % interval == 0) {
            records.add(DailyRecord(
              habitId: habit.id,
              date: dateKey,
              status: RecordStatus.success,
              recordedAt: recordedAt,
            ));
          }
      }
    }
  }

  return records;
}
