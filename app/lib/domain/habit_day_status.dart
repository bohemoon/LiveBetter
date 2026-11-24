import '../data/models/models.dart';

/// 单日状态文案，用于单项目历史视图。
class HabitDayStatus {
  const HabitDayStatus({required this.label, required this.achieved});

  final String label;
  final bool achieved;
}

HabitDayStatus describeHabitDay(Habit habit, DailyRecord? record) {
  switch (habit.type) {
    case HabitType.active:
      if (record?.status == RecordStatus.success) {
        return const HabitDayStatus(label: '已达成', achieved: true);
      }
      if (record?.status == RecordStatus.fail) {
        return const HabitDayStatus(label: '未达成', achieved: false);
      }
      return const HabitDayStatus(label: '未打卡', achieved: false);
    case HabitType.passive:
      if (record?.status == RecordStatus.slip) {
        return const HabitDayStatus(label: '重新开始', achieved: false);
      }
      return const HabitDayStatus(label: '保持', achieved: true);
    case HabitType.meter:
      final goal = habit.goal ?? 1;
      final amount = record?.amount ?? 0;
      final unit = habit.unit ?? '';
      return HabitDayStatus(
        label: '$amount / $goal $unit',
        achieved: amount >= goal,
      );
    case HabitType.periodic:
      if (record?.status == RecordStatus.success) {
        return const HabitDayStatus(label: '已完成', achieved: true);
      }
      return const HabitDayStatus(label: '待完成', achieved: false);
  }
}
