import '../data/models/models.dart';

/// 到提醒时间仍未完成的打卡项。
///
/// 偏差 #9：除主动型外，计量型未达标同样纳入提醒；被动型默认保持、周期型按到期提示，均不在站内提醒范围。
List<Habit> pendingReminderHabits({
  required List<Habit> habits,
  required List<DailyRecord> records,
  required String today,
}) {
  final byHabit = <String, DailyRecord>{};
  for (final record in records) {
    if (record.date == today) byHabit[record.habitId] = record;
  }

  return habits.where((habit) {
    if (!habit.enabled) return false;
    final record = byHabit[habit.id];
    switch (habit.type) {
      case HabitType.active:
        return record?.status != RecordStatus.success;
      case HabitType.meter:
        return (record?.amount ?? 0) < (habit.goal ?? 1);
      case HabitType.passive:
      case HabitType.periodic:
        return false;
    }
  }).toList(growable: false);
}
