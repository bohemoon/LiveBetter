import 'package:flutter_test/flutter_test.dart';
import 'package:livebetter/data/models/models.dart';
import 'package:livebetter/domain/check_in_rules.dart';
import 'package:livebetter/domain/stats/habit_stats.dart';

Habit habit({
  required HabitType type,
  String createdAt = '2026-11-01',
  String? targetTime,
  int? goal,
  int? intervalDays,
}) {
  return Habit(
    id: 'h1',
    name: '测试',
    type: type,
    isRequired: false,
    enabled: true,
    sensitive: false,
    sortOrder: 0,
    createdAt: createdAt,
    updatedAt: createdAt,
    targetTime: targetTime,
    goal: goal,
    intervalDays: intervalDays,
    step: 1,
  );
}

DailyRecord success(String date) => DailyRecord(
      habitId: 'h1',
      date: date,
      status: RecordStatus.success,
      recordedAt: '2026-11-01T22:00:00',
    );

DailyRecord slip(String date) => DailyRecord(
      habitId: 'h1',
      date: date,
      status: RecordStatus.slip,
      recordedAt: '2026-11-01T22:00:00',
    );

DailyRecord amount(String date, int value) => DailyRecord(
      habitId: 'h1',
      date: date,
      amount: value,
      recordedAt: '2026-11-01T22:00:00',
    );

void main() {
  group('主动型', () {
    test('今天待打卡不打断连击', () {
      final stats = computeHabitStats(
        habit: habit(type: HabitType.active),
        records: [
          success('2026-11-01'),
          success('2026-11-02'),
          success('2026-11-03'),
          success('2026-11-04'),
        ],
        today: '2026-11-05',
        strictMode: false,
      );
      expect(stats.currentStreak, 4);
      expect(stats.longestStreak, 4);
      expect(stats.totalDays, 4);
      expect(stats.doneToday, isFalse);
    });

    test('温和模式每自然周一次断签豁免', () {
      final stats = computeHabitStats(
        habit: habit(type: HabitType.active, createdAt: '2026-11-02'),
        records: [
          success('2026-11-02'),
          success('2026-11-03'),
          success('2026-11-07'),
          success('2026-11-08'),
        ],
        today: '2026-11-08',
        strictMode: false,
      );
      // 11-06 首次断签被豁免，11-05 同周再次断签才中断。
      expect(stats.currentStreak, 2);
      expect(stats.totalDays, 4);
    });

    test('严格模式无豁免', () {
      final stats = computeHabitStats(
        habit: habit(type: HabitType.active, createdAt: '2026-11-02'),
        records: [
          success('2026-11-02'),
          success('2026-11-03'),
          success('2026-11-07'),
          success('2026-11-08'),
        ],
        today: '2026-11-08',
        strictMode: true,
      );
      expect(stats.currentStreak, 2);
    });

    test('创建日之前的记录不计入统计', () {
      final stats = computeHabitStats(
        habit: habit(type: HabitType.active, createdAt: '2026-11-05'),
        records: [success('2026-11-04')],
        today: '2026-11-05',
        strictMode: false,
      );
      expect(stats.totalDays, 0);
      expect(stats.currentStreak, 0);
    });
  });

  group('被动型', () {
    test('破戒当天重新计数，保留最长与累计', () {
      final stats = computeHabitStats(
        habit: habit(type: HabitType.passive),
        records: [slip('2026-11-03')],
        today: '2026-11-05',
        strictMode: false,
      );
      expect(stats.currentStreak, 2);
      expect(stats.longestStreak, 2);
      expect(stats.totalDays, 3);
      expect(stats.doneToday, isTrue);
    });
  });

  group('计量型', () {
    test('达到目标才记一天', () {
      final stats = computeHabitStats(
        habit: habit(type: HabitType.meter, goal: 8),
        records: [amount('2026-11-04', 8), amount('2026-11-05', 3)],
        today: '2026-11-05',
        strictMode: false,
      );
      expect(stats.doneToday, isFalse);
      expect(stats.amountToday, 3);
      expect(stats.currentStreak, 1);
      expect(stats.totalDays, 1);
    });
  });

  group('周期型', () {
    test('只计算下次到期，不计入连击与累计', () {
      final stats = computeHabitStats(
        habit: habit(type: HabitType.periodic, intervalDays: 30),
        records: [success('2026-11-01')],
        today: '2026-11-10',
        strictMode: false,
      );
      expect(stats.currentStreak, 0);
      expect(stats.totalDays, 0);
      expect(stats.nextDueDate, '2026-12-01');
      expect(stats.nextDueInDays, 21);
    });

    test('没有完成记录时视为今天到期', () {
      final stats = computeHabitStats(
        habit: habit(type: HabitType.periodic, intervalDays: 7),
        records: const [],
        today: '2026-11-10',
        strictMode: false,
      );
      expect(stats.nextDueInDays, 0);
      expect(stats.doneToday, isFalse);
    });
  });

  group('早睡目标时间', () {
    final sleep = habit(type: HabitType.active, targetTime: '23:30');

    test('等于目标分钟视为达标', () {
      expect(
        evaluateActiveCheckIn(
          habit: sleep,
          existing: null,
          now: DateTime(2026, 11, 24, 23, 30),
        ),
        CheckInOutcome.success,
      );
    });

    test('晚于目标分钟记为未达成', () {
      expect(
        evaluateActiveCheckIn(
          habit: sleep,
          existing: null,
          now: DateTime(2026, 11, 24, 23, 31),
        ),
        CheckInOutcome.late,
      );
    });

    test('早晨补点也不算达标', () {
      expect(
        evaluateActiveCheckIn(
          habit: sleep,
          existing: null,
          now: DateTime(2026, 11, 24, 8, 0),
        ),
        CheckInOutcome.late,
      );
    });

    test('重复打卡提示已记录', () {
      expect(
        evaluateActiveCheckIn(
          habit: sleep,
          existing: success('2026-11-24'),
          now: DateTime(2026, 11, 24, 22, 0),
        ),
        CheckInOutcome.duplicate,
      );
    });
  });
}
