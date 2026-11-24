import '../core/date_utils.dart';
import '../data/models/models.dart';

/// 主动型打卡判定结果。
enum CheckInOutcome {
  success('已打卡'),
  late('已记录，今天未在目标时间前完成'),
  duplicate('今天已经记录过了');

  const CheckInOutcome(this.message);

  final String message;
}

/// 目标时间判定：仅在目标时间前 6 小时窗口内记录才算达标，且统一使用 `<=`。
///
/// 例如目标 23:30：17:30–23:30 内记录成功；23:31 记为未达成；
/// 早晨补点（如 08:00）同样记为未达成，避免"任意时间都算成功"的漏洞。
bool isWithinTargetTime(String targetTime, DateTime now) {
  final parts = targetTime.split(':');
  if (parts.length != 2) return true;
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) return true;

  const windowMinutes = 6 * 60;
  final targetMinutes = hour * 60 + minute;
  final nowMinutes = now.hour * 60 + now.minute;

  // 按 24 小时环计算差值，落在 [-720, 720] 区间。
  var delta = nowMinutes - targetMinutes;
  if (delta > 720) delta -= 1440;
  if (delta < -720) delta += 1440;

  return delta <= 0 && delta >= -windowMinutes;
}

/// 早睡补卡窗口：00:00–04:00 的记录归属于前一日（偏差 #2）。
bool isMakeupWindow(DateTime now) => now.hour < 4;

/// 打卡归属日期：带目标时间的项目在补卡窗口内记入前一日。
String checkInDateFor(Habit habit, DateTime now) {
  if (habit.targetTime == null) return formatYmd(now);
  if (!isMakeupWindow(now)) return formatYmd(now);
  final yesterday = now.subtract(const Duration(days: 1));
  return formatYmd(DateTime(yesterday.year, yesterday.month, yesterday.day));
}

/// 主动型打卡：设置目标时间的项目（早睡）需在目标时间前完成。
CheckInOutcome evaluateActiveCheckIn({
  required Habit habit,
  required DailyRecord? existing,
  required DateTime now,
}) {
  if (existing != null) {
    return CheckInOutcome.duplicate;
  }
  final target = habit.targetTime;
  if (target == null) {
    return CheckInOutcome.success;
  }
  // 补卡窗口内的记录直接记入前一日并视为达成。
  if (isMakeupWindow(now)) {
    return CheckInOutcome.success;
  }
  return isWithinTargetTime(target, now)
      ? CheckInOutcome.success
      : CheckInOutcome.late;
}
