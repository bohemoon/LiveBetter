import '../../core/date_utils.dart';
import '../../data/models/models.dart';

/// 打卡项统计快照。
class HabitStats {
  const HabitStats({
    required this.currentStreak,
    required this.longestStreak,
    required this.totalDays,
    required this.amountToday,
    required this.doneToday,
    this.nextDueInDays,
    this.nextDueDate,
  });

  final int currentStreak;
  final int longestStreak;
  final int totalDays;
  final int amountToday;
  final bool doneToday;

  /// 周期项距下次到期天数，已到期为 0。
  final int? nextDueInDays;
  final String? nextDueDate;

  static const HabitStats empty = HabitStats(
    currentStreak: 0,
    longestStreak: 0,
    totalDays: 0,
    amountToday: 0,
    doneToday: false,
  );
}

/// 纯函数统计引擎：输入打卡项、全部记录与今天，输出连击与累计。
///
/// 规则见《开发规划》第 6 章：
/// - 主动：当天 `success` 记一天；温和模式每自然周 1 次断签豁免（不增天数、不断连击）。
/// - 被动：无 `slip` 即保持，创建当天不计。
/// - 计量：`amount >= goal` 记一天。
/// - 周期：不参与连击与累计，只计算下次到期。
HabitStats computeHabitStats({
  required Habit habit,
  required List<DailyRecord> records,
  required String today,
  required bool strictMode,
}) {
  final todayDate = _parseDate(today);
  final startDate = _parseDate(habit.createdAt);

  final byDate = <String, DailyRecord>{};
  for (final record in records) {
    if (record.habitId != habit.id) continue;
    byDate[record.date] = record;
  }

  if (habit.type == HabitType.periodic) {
    return _periodicStats(
      habit: habit,
      records: records,
      today: today,
      todayDate: todayDate,
      todayRecord: byDate[today],
    );
  }

  if (startDate.isAfter(todayDate)) {
    return HabitStats.empty;
  }

  final amountToday = byDate[today]?.amount ?? 0;
  final doneToday = _isAchieved(habit, startDate, byDate, todayDate);
  final current = _currentStreak(
    habit: habit,
    startDate: startDate,
    byDate: byDate,
    today: todayDate,
    strictMode: strictMode,
  );
  final longest = _longestStreak(
    habit: habit,
    startDate: startDate,
    byDate: byDate,
    today: todayDate,
    strictMode: strictMode,
  );

  var total = 0;
  for (var day = startDate;
      !day.isAfter(todayDate);
      day = day.add(const Duration(days: 1))) {
    if (_isAchieved(habit, startDate, byDate, day)) total++;
  }

  return HabitStats(
    currentStreak: current,
    longestStreak: longest < current ? current : longest,
    totalDays: total,
    amountToday: amountToday,
    doneToday: doneToday,
  );
}

HabitStats _periodicStats({
  required Habit habit,
  required List<DailyRecord> records,
  required String today,
  required DateTime todayDate,
  required DailyRecord? todayRecord,
}) {
  final completions = records
      .where((record) =>
          record.habitId == habit.id && record.status == RecordStatus.success)
      .map((record) => record.date)
      .toList()
    ..sort();

  final interval = habit.intervalDays ?? 1;
  DateTime nextDue;
  if (completions.isEmpty) {
    nextDue = todayDate;
  } else {
    nextDue = _parseDate(completions.last).add(Duration(days: interval));
  }
  var diff = nextDue.difference(todayDate).inDays;
  if (diff < 0) diff = 0;

  return HabitStats(
    currentStreak: 0,
    longestStreak: 0,
    totalDays: 0,
    amountToday: 0,
    doneToday: todayRecord?.status == RecordStatus.success,
    nextDueInDays: diff,
    nextDueDate: formatYmd(nextDue),
  );
}

int _currentStreak({
  required Habit habit,
  required DateTime startDate,
  required Map<String, DailyRecord> byDate,
  required DateTime today,
  required bool strictMode,
}) {
  var streak = 0;
  final exemptedWeeks = <String>{};
  var day = today;

  while (!day.isBefore(startDate)) {
    if (habit.type == HabitType.passive) {
      // 创建当天不计入坚持天数。
      if (!day.isAfter(startDate)) break;
      if (byDate[formatYmd(day)]?.status == RecordStatus.slip) break;
      streak++;
    } else if (_isAchieved(habit, startDate, byDate, day)) {
      streak++;
    } else if (isSameDay(day, today)) {
      // 今天尚未打卡不打断连击。
    } else {
      final week = _weekKey(day);
      if (!strictMode && !exemptedWeeks.contains(week)) {
        exemptedWeeks.add(week);
      } else {
        break;
      }
    }
    day = day.subtract(const Duration(days: 1));
  }
  return streak;
}

int _longestStreak({
  required Habit habit,
  required DateTime startDate,
  required Map<String, DailyRecord> byDate,
  required DateTime today,
  required bool strictMode,
}) {
  var run = 0;
  var best = 0;
  final exemptedWeeks = <String>{};

  for (var day = startDate;
      !day.isAfter(today);
      day = day.add(const Duration(days: 1))) {
    if (habit.type == HabitType.passive) {
      if (!day.isAfter(startDate)) continue;
      if (byDate[formatYmd(day)]?.status == RecordStatus.slip) {
        run = 0;
      } else {
        run++;
        if (run > best) best = run;
      }
      continue;
    }

    if (_isAchieved(habit, startDate, byDate, day)) {
      run++;
      if (run > best) best = run;
    } else if (isSameDay(day, today)) {
      // 今天未打卡，不判定断签。
    } else {
      final week = _weekKey(day);
      if (!strictMode && !exemptedWeeks.contains(week)) {
        exemptedWeeks.add(week);
      } else {
        run = 0;
      }
    }
  }
  return best;
}

bool _isAchieved(
  Habit habit,
  DateTime startDate,
  Map<String, DailyRecord> byDate,
  DateTime day,
) {
  final record = byDate[formatYmd(day)];
  switch (habit.type) {
    case HabitType.active:
      return record?.status == RecordStatus.success;
    case HabitType.passive:
      if (!day.isAfter(startDate)) return false;
      return record?.status != RecordStatus.slip;
    case HabitType.meter:
      return (record?.amount ?? 0) >= (habit.goal ?? 1);
    case HabitType.periodic:
      return false;
  }
}

DateTime _parseDate(String ymd) {
  return DateTime.parse(ymd);
}

bool isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

/// 自然周标识，以周一日期表示。
String _weekKey(DateTime day) {
  final monday = day.subtract(Duration(days: day.weekday - 1));
  return formatYmd(DateTime(monday.year, monday.month, monday.day));
}
