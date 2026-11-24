import 'package:flutter_test/flutter_test.dart';
import 'package:livebetter/data/models/models.dart';
import 'package:livebetter/domain/stats/records_stats.dart';

Habit makeHabit({
  required String id,
  HabitType type = HabitType.active,
  bool enabled = true,
  bool required = false,
  int? goal,
  String createdAt = '2026-11-01',
}) {
  return Habit(
    id: id,
    name: id,
    type: type,
    isRequired: required,
    enabled: enabled,
    sensitive: false,
    sortOrder: 0,
    createdAt: createdAt,
    updatedAt: createdAt,
    goal: goal,
    step: 1,
  );
}

DailyRecord record({
  required String habitId,
  required String date,
  RecordStatus? status,
  int? amount,
}) {
  return DailyRecord(
    habitId: habitId,
    date: date,
    status: status,
    amount: amount,
    recordedAt: '${date}T22:00:00',
  );
}

DailyRecord success(String habitId, String date) =>
    record(habitId: habitId, date: date, status: RecordStatus.success);

void main() {
  group('单日达成口径', () {
    test('四种类型', () {
      final active = makeHabit(id: 'a');
      final passive = makeHabit(id: 'p', type: HabitType.passive);
      final meter = makeHabit(id: 'm', type: HabitType.meter, goal: 8);
      final periodic = makeHabit(id: 'r', type: HabitType.periodic);

      expect(isHabitMet(active, success('a', '2026-11-02')), isTrue);
      expect(
        isHabitMet(
          active,
          record(habitId: 'a', date: '2026-11-02', status: RecordStatus.fail),
        ),
        isFalse,
      );
      expect(isHabitMet(active, null), isFalse);

      expect(isHabitMet(passive, null), isTrue);
      expect(
        isHabitMet(
          passive,
          record(habitId: 'p', date: '2026-11-02', status: RecordStatus.slip),
        ),
        isFalse,
      );

      expect(
        isHabitMet(
          meter,
          record(habitId: 'm', date: '2026-11-02', amount: 8),
        ),
        isTrue,
      );
      expect(
        isHabitMet(
          meter,
          record(habitId: 'm', date: '2026-11-02', amount: 7),
        ),
        isFalse,
      );

      expect(isHabitMet(periodic, success('r', '2026-11-02')), isFalse);
    });

    test('周期型与关闭项不参与记录统计', () {
      final habits = [
        makeHabit(id: 'a'),
        makeHabit(id: 'p', type: HabitType.passive, enabled: false),
        makeHabit(id: 'r', type: HabitType.periodic),
        makeHabit(id: 'req', required: true, enabled: false),
      ];
      final tracked = trackedHabits(habits).map((habit) => habit.id).toList();
      expect(tracked, ['a', 'req']);
    });

    test('色阶 0–4 分级且超过 4 按 4 计', () {
      expect(const DayProgress(date: 'd', met: 0, total: 5).level, 0);
      expect(const DayProgress(date: 'd', met: 2, total: 5).level, 2);
      expect(const DayProgress(date: 'd', met: 7, total: 8).level, 4);
    });
  });

  group('本周稳定度', () {
    test('近 7 天达成率与档位', () {
      final habits = [
        makeHabit(id: 'a'),
        makeHabit(id: 'p', type: HabitType.passive),
      ];
      final records = [
        for (var day = 1; day <= 5; day++) success('a', '2026-11-0$day'),
        record(
          habitId: 'p',
          date: '2026-11-06',
          status: RecordStatus.slip,
        ),
      ];

      final data = computeWeekStability(
        habits: habits,
        records: records,
        today: '2026-11-07',
      );

      expect(data.days.length, 7);
      expect(data.days.first.date, '2026-11-01');
      expect(data.days.last.date, '2026-11-07');
      expect(data.done, 11);
      expect(data.total, 14);
      expect(data.pct, closeTo(0.786, 0.001));
      expect(data.label, '一般');
      expect(data.cheer, '做得不错，允许自己偶尔松一松');
    });

    test('创建日之前不计入统计', () {
      final data = computeWeekStability(
        habits: [makeHabit(id: 'a', createdAt: '2026-11-06')],
        records: [success('a', '2026-11-06'), success('a', '2026-11-07')],
        today: '2026-11-07',
      );

      expect(data.days[0].total, 0);
      expect(data.days[4].total, 0);
      expect(data.days[5].total, 1);
      expect(data.done, 2);
      expect(data.total, 2);
      expect(data.label, '稳');
    });
  });

  group('月度小结', () {
    test('完成项次、全勤天数与在坚持项目数', () {
      final habits = [
        makeHabit(id: 'a'),
        makeHabit(
          id: 'm',
          type: HabitType.meter,
          goal: 8,
          createdAt: '2026-11-05',
        ),
        makeHabit(id: 'r', type: HabitType.periodic),
      ];
      final records = [
        for (var day = 1; day <= 3; day++) success('a', '2026-11-0$day'),
        record(habitId: 'm', date: '2026-11-06', amount: 8),
        record(habitId: 'm', date: '2026-11-07', amount: 8),
        record(habitId: 'r', date: '2026-11-02', status: RecordStatus.success),
      ];

      final summary = computeMonthSummary(
        habits: habits,
        records: records,
        today: '2026-11-10',
        year: 2026,
        month: 11,
      );

      expect(summary.days.length, 10);
      expect(summary.days.last.date, '2026-11-10');
      expect(summary.done, 5);
      expect(summary.total, 16);
      expect(summary.fullDays, 3);
      expect(summary.activeHabits, 2);
      expect(summary.cheerTitle, '这个月在慢慢积累');
    });

    test('浏览历史月份时整月都参与统计', () {
      final summary = computeMonthSummary(
        habits: [makeHabit(id: 'a', createdAt: '2026-10-01')],
        records: [success('a', '2026-10-01')],
        today: '2026-11-24',
        year: 2026,
        month: 10,
      );

      expect(summary.days.length, 31);
      expect(summary.done, 1);
      expect(summary.total, 31);
      expect(summary.fullDays, 1);
    });
  });
}
