import '../../core/date_utils.dart';
import '../../data/models/models.dart';

/// 记录页统计算法（纯函数）：按自然日聚合启用中的打卡项。
///
/// 规则见《开发规划》第 6 章：周期型不参与日历、稳定度与连续统计。

/// 参与记录页统计的打卡项：必选或已启用，且排除周期型。
List<Habit> trackedHabits(Iterable<Habit> habits) {
  return habits
      .where((habit) =>
          (habit.isRequired || habit.enabled) && habit.type != HabitType.periodic)
      .toList();
}

/// 单个打卡项在指定日期是否算「坚持成功」。
bool isHabitMet(Habit habit, DailyRecord? record) {
  switch (habit.type) {
    case HabitType.active:
      return record?.status == RecordStatus.success;
    case HabitType.passive:
      return record?.status != RecordStatus.slip;
    case HabitType.meter:
      return (record?.amount ?? 0) >= (habit.goal ?? 1);
    case HabitType.periodic:
      return false;
  }
}

/// 单日进度：参与统计的项目数与达成数。
class DayProgress {
  const DayProgress({
    required this.date,
    required this.met,
    required this.total,
  });

  final String date;
  final int met;
  final int total;

  bool get hasData => total > 0;

  /// 全部参与项都已达成。
  bool get isFull => total > 0 && met >= total;

  double get ratio => total == 0 ? 0 : met / total;

  /// 五级色阶：0–4，超过 4 项按 4 级处理。
  int get level => met <= 0 ? 0 : (met >= 4 ? 4 : met);
}

/// 本周稳定度：近 N 天每日达成率与总体档位。
class WeekStability {
  const WeekStability({
    required this.days,
    required this.done,
    required this.total,
  });

  final List<DayProgress> days;
  final int done;
  final int total;

  double get pct => total == 0 ? 0 : done / total;

  String get label {
    if (pct >= 0.85) return '稳';
    if (pct >= 0.6) return '一般';
    return '起伏';
  }

  String get cheer {
    if (pct >= 0.85) return '这周很稳，保持这个节奏';
    if (pct >= 0.6) return '做得不错，允许自己偶尔松一松';
    if (pct >= 0.3) return '有在坚持，慢一点也没关系';
    return '这周辛苦了，先照顾好自己';
  }
}

/// 月度小结：完成项次、全勤天数与在坚持项目数。
class MonthSummary {
  const MonthSummary({
    required this.year,
    required this.month,
    required this.days,
    required this.done,
    required this.total,
    required this.fullDays,
    required this.activeHabits,
  });

  final int year;
  final int month;
  final List<DayProgress> days;
  final int done;
  final int total;
  final int fullDays;
  final int activeHabits;

  double get ratio => total == 0 ? 0 : done / total;

  String get cheerTitle {
    if (ratio >= 0.85) return '这个月状态很好';
    if (ratio >= 0.6) return '这个月走得挺稳';
    if (ratio >= 0.3) return '这个月在慢慢积累';
    if (ratio > 0) return '这个月有些辛苦';
    return '新的一段路';
  }

  String get cheerDesc {
    if (ratio >= 0.85) return '大部分日子都守住了，值得给自己一点肯定。';
    if (ratio >= 0.6) return '有做到的日子，也有放松的日子，都算数。';
    if (ratio >= 0.3) return '不用每天都完美，愿意继续就很好。';
    if (ratio > 0) return '偶尔停下来也没关系，想继续的时候随时可以。';
    return '从今天开始，先完成一件小事就好。';
  }
}

/// 计算近 [length] 天（含今天）的稳定度。
WeekStability computeWeekStability({
  required List<Habit> habits,
  required List<DailyRecord> records,
  required String today,
  int length = 7,
}) {
  final tracked = trackedHabits(habits);
  final index = _indexRecords(records);
  final todayDate = parseYmd(today);

  var done = 0;
  var total = 0;
  final days = <DayProgress>[];
  for (var offset = length - 1; offset >= 0; offset--) {
    final date = formatYmd(todayDate.subtract(Duration(days: offset)));
    final progress = _dayProgress(tracked, index, date);
    days.add(progress);
    done += progress.met;
    total += progress.total;
  }
  return WeekStability(days: days, done: done, total: total);
}

/// 计算指定年月的月度小结，未来日期不计入。
MonthSummary computeMonthSummary({
  required List<Habit> habits,
  required List<DailyRecord> records,
  required String today,
  required int year,
  required int month,
}) {
  final tracked = trackedHabits(habits);
  final index = _indexRecords(records);
  final daysInMonth = DateTime(year, month + 1, 0).day;
  final monthEnd = formatYmd(DateTime(year, month, daysInMonth));

  var done = 0;
  var total = 0;
  var fullDays = 0;
  final days = <DayProgress>[];
  for (var day = 1; day <= daysInMonth; day++) {
    final date = formatYmd(DateTime(year, month, day));
    if (date.compareTo(today) > 0) break;
    final progress = _dayProgress(tracked, index, date);
    days.add(progress);
    done += progress.met;
    total += progress.total;
    if (progress.isFull) fullDays++;
  }

  final activeHabits =
      tracked.where((habit) => habit.createdAt.compareTo(monthEnd) <= 0).length;

  return MonthSummary(
    year: year,
    month: month,
    days: days,
    done: done,
    total: total,
    fullDays: fullDays,
    activeHabits: activeHabits,
  );
}

DayProgress _dayProgress(
  List<Habit> tracked,
  Map<String, Map<String, DailyRecord>> index,
  String date,
) {
  var met = 0;
  var total = 0;
  for (final habit in tracked) {
    if (date.compareTo(habit.createdAt) < 0) continue;
    total++;
    if (isHabitMet(habit, index[habit.id]?[date])) met++;
  }
  return DayProgress(date: date, met: met, total: total);
}

Map<String, Map<String, DailyRecord>> _indexRecords(List<DailyRecord> records) {
  final index = <String, Map<String, DailyRecord>>{};
  for (final record in records) {
    (index[record.habitId] ??= <String, DailyRecord>{})[record.date] = record;
  }
  return index;
}
