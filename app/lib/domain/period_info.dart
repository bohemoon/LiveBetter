import '../core/date_utils.dart';

/// 经期阶段推算结果。
class PeriodInfo {
  const PeriodInfo({required this.onPeriod, this.day = 0, this.daysLeft = 0});

  /// 当前是否处于经期。
  final bool onPeriod;

  /// 经期第几天（从 1 开始）。
  final int day;

  /// 距离下次经期天数。
  final int daysLeft;
}

/// 按开始日期、周期与经期天数推算当前阶段。
///
/// 与原型一致：距今天数为负（未来日期）时按未开始处理。
PeriodInfo? computePeriodInfo({
  required bool enabled,
  required String? start,
  required int periodLength,
  required int cycleLength,
  required String today,
}) {
  if (!enabled || start == null || !isValidYmd(start)) return null;

  final since = parseYmd(today).difference(parseYmd(start)).inDays;
  final len = cycleLength <= 0 ? 28 : cycleLength;
  final plen = periodLength <= 0 ? 5 : periodLength;

  if (since < 0) {
    return PeriodInfo(onPeriod: false, daysLeft: -since);
  }

  final dayInCycle = since % len;
  if (dayInCycle < plen) {
    return PeriodInfo(onPeriod: true, day: dayInCycle + 1);
  }
  return PeriodInfo(onPeriod: false, daysLeft: len - dayInCycle);
}
