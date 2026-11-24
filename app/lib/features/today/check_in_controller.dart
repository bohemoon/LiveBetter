import '../../core/date_utils.dart';
import '../../data/models/models.dart';
import '../../data/repositories/record_repository.dart';
import '../../domain/check_in_rules.dart';

/// 今日页的打卡写入入口，所有写操作完成后由 drift 流自动刷新界面。
class CheckInController {
  CheckInController(this._records);

  final RecordRepository _records;

  Future<DailyRecord?> recordOf(String habitId, String date) async {
    final records = await _records.byDate(date);
    for (final record in records) {
      if (record.habitId == habitId) return record;
    }
    return null;
  }

  Future<CheckInOutcome> checkInActive(Habit habit) async {
    final now = DateTime.now();
    // 早睡补卡窗口内归属前一日，避免凌晨打卡记到今天。
    final targetDate = checkInDateFor(habit, now);
    final existing = await recordOf(habit.id, targetDate);
    final outcome = evaluateActiveCheckIn(
      habit: habit,
      existing: existing,
      now: now,
    );
    if (outcome == CheckInOutcome.duplicate) return outcome;

    await _records.upsert(
      DailyRecord(
        habitId: habit.id,
        date: targetDate,
        status: outcome == CheckInOutcome.success
            ? RecordStatus.success
            : RecordStatus.fail,
        recordedAt: nowIso(),
      ),
    );
    return outcome;
  }

  Future<void> undo(String habitId, String date) => _records.remove(habitId, date);

  /// 计量项 +step，返回最新累计值。
  Future<int> incrementMeter(Habit habit, String date, int current) async {
    final next = current + (habit.step ?? 1);
    await _records.upsert(
      DailyRecord(
        habitId: habit.id,
        date: date,
        amount: next,
        recordedAt: nowIso(),
      ),
    );
    return next;
  }

  /// 计量项 -step，减到 0 时删除记录。
  Future<int> decrementMeter(Habit habit, String date, int current) async {
    final step = habit.step ?? 1;
    if (current <= step) {
      await _records.remove(habit.id, date);
      return 0;
    }
    final next = current - step;
    await _records.upsert(
      DailyRecord(
        habitId: habit.id,
        date: date,
        amount: next,
        recordedAt: nowIso(),
      ),
    );
    return next;
  }

  /// 被动型破戒，历史记录保留。
  Future<void> markSlip(Habit habit, String date) {
    return _records.upsert(
      DailyRecord(
        habitId: habit.id,
        date: date,
        status: RecordStatus.slip,
        recordedAt: nowIso(),
      ),
    );
  }

  /// 周期型完成本次，下一次到期日重新计算。
  Future<void> completePeriodic(Habit habit, String date) {
    return _records.upsert(
      DailyRecord(
        habitId: habit.id,
        date: date,
        status: RecordStatus.success,
        recordedAt: nowIso(),
      ),
    );
  }
}
