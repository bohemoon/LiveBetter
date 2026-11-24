import 'package:flutter_test/flutter_test.dart';
import 'package:livebetter/data/models/models.dart';
import 'package:livebetter/domain/check_in_rules.dart';
import 'package:livebetter/domain/demo_data.dart';
import 'package:livebetter/domain/period_info.dart';
import 'package:livebetter/domain/pin_hash.dart';
import 'package:livebetter/domain/reminders.dart';

Habit makeHabit({
  required String id,
  HabitType type = HabitType.active,
  bool enabled = true,
  int? goal,
  String? unit,
  String? targetTime,
  int? intervalDays,
  String? alias,
  bool sensitive = false,
  String createdAt = '2026-01-01',
}) {
  return Habit(
    id: id,
    name: id,
    alias: alias,
    type: type,
    isRequired: false,
    enabled: enabled,
    sensitive: sensitive,
    sortOrder: 0,
    createdAt: createdAt,
    updatedAt: createdAt,
    goal: goal,
    unit: unit,
    step: 1,
    targetTime: targetTime,
    intervalDays: intervalDays,
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

void main() {
  group('经期推算', () {
    test('经期内返回第几天', () {
      final info = computePeriodInfo(
        enabled: true,
        start: '2026-11-20',
        periodLength: 5,
        cycleLength: 28,
        today: '2026-11-22',
      );
      expect(info, isNotNull);
      expect(info!.onPeriod, isTrue);
      expect(info.day, 3);
    });

    test('经期外返回距离下次天数', () {
      final info = computePeriodInfo(
        enabled: true,
        start: '2026-11-20',
        periodLength: 5,
        cycleLength: 28,
        today: '2026-11-30',
      );
      expect(info!.onPeriod, isFalse);
      expect(info.daysLeft, 18);
    });

    test('未来开始日期与未开启', () {
      final future = computePeriodInfo(
        enabled: true,
        start: '2026-11-25',
        periodLength: 5,
        cycleLength: 28,
        today: '2026-11-24',
      );
      expect(future!.onPeriod, isFalse);
      expect(future.daysLeft, 1);

      expect(
        computePeriodInfo(
          enabled: false,
          start: '2026-11-20',
          periodLength: 5,
          cycleLength: 28,
          today: '2026-11-22',
        ),
        isNull,
      );
    });
  });

  group('提醒待完成项', () {
    test('主动未完成与计量未达标纳入提醒', () {
      const today = '2026-11-24';
      final habits = [
        makeHabit(id: 'active_pending'),
        makeHabit(id: 'active_done'),
        makeHabit(id: 'meter_pending', type: HabitType.meter, goal: 8),
        makeHabit(id: 'meter_done', type: HabitType.meter, goal: 8),
        makeHabit(id: 'passive', type: HabitType.passive),
        makeHabit(id: 'periodic', type: HabitType.periodic, intervalDays: 30),
        makeHabit(id: 'disabled', enabled: false),
      ];
      final records = [
        record(
          habitId: 'active_done',
          date: today,
          status: RecordStatus.success,
        ),
        record(habitId: 'meter_pending', date: today, amount: 5),
        record(habitId: 'meter_done', date: today, amount: 8),
      ];

      final pending = pendingReminderHabits(
        habits: habits,
        records: records,
        today: today,
      );

      expect(
        pending.map((habit) => habit.id),
        ['active_pending', 'meter_pending'],
      );
    });
  });

  group('演示数据', () {
    test('覆盖 34 天且不写入今天与未来', () {
      const today = '2026-11-24';
      final habits = [
        makeHabit(id: 'active'),
        makeHabit(id: 'passive', type: HabitType.passive),
        makeHabit(id: 'meter', type: HabitType.meter, goal: 8),
        makeHabit(
          id: 'periodic',
          type: HabitType.periodic,
          intervalDays: 30,
        ),
      ];

      final records = buildDemoRecords(habits: habits, today: today);
      expect(records, isNotEmpty);
      expect(records.any((item) => item.date == today), isFalse);
      final keys = records.map((item) => '${item.habitId}@${item.date}').toSet();
      expect(keys.length, records.length);
      for (final item in records) {
        expect(item.date.compareTo('2026-10-21'), greaterThanOrEqualTo(0));
        expect(item.date.compareTo('2026-11-23'), lessThanOrEqualTo(0));
        if (item.habitId == 'meter') {
          expect(item.amount, lessThanOrEqualTo(8));
        }
      }
      expect(records.any((item) => item.habitId == 'passive'), isTrue);
    });

    test('被动型按间隔出现破戒记录', () {
      const today = '2026-11-24';
      final habits = [
        makeHabit(id: 'passive', type: HabitType.passive),
      ];
      final records = buildDemoRecords(habits: habits, today: today);
      expect(
        records.where((item) => item.status == RecordStatus.slip),
        isNotEmpty,
      );
    });
  });

  group('早睡补卡窗口', () {
    final sleep = makeHabit(
      id: 'sleep',
      type: HabitType.active,
      targetTime: '23:30',
    );

    test('00:00–04:00 归属前一日', () {
      expect(
        checkInDateFor(sleep, DateTime(2026, 11, 24, 1, 30)),
        '2026-11-23',
      );
      expect(
        checkInDateFor(sleep, DateTime(2026, 11, 24, 10)),
        '2026-11-24',
      );
    });

    test('无目标时间项目不受补卡窗口影响', () {
      final water = makeHabit(id: 'water');
      expect(
        checkInDateFor(water, DateTime(2026, 11, 24, 1, 30)),
        '2026-11-24',
      );
    });

    test('补卡窗口内视为达成，平时按目标时间判定', () {
      expect(
        evaluateActiveCheckIn(
          habit: sleep,
          existing: null,
          now: DateTime(2026, 11, 24, 1, 30),
        ),
        CheckInOutcome.success,
      );
      expect(
        evaluateActiveCheckIn(
          habit: sleep,
          existing: null,
          now: DateTime(2026, 11, 24, 22),
        ),
        CheckInOutcome.success,
      );
      expect(
        evaluateActiveCheckIn(
          habit: sleep,
          existing: null,
          now: DateTime(2026, 11, 24, 23, 45),
        ),
        CheckInOutcome.late,
      );
    });
  });

  group('别名与密码哈希', () {
    test('清空别名后回落到通用名称', () {
      final habit = makeHabit(
        id: 'secret',
        alias: '自律',
        sensitive: true,
      );
      expect(habit.displayName(hideSensitive: true), '自律');
      final cleared = habit.copyWith(clearAlias: true);
      expect(cleared.alias, isNull);
      expect(cleared.displayName(hideSensitive: true), '自律项');
    });

    test('密码只保存哈希', () {
      expect(hashPin('1234'), isNot('1234'));
      expect(hashPin('1234').length, 64);
      expect(hashPin('1234'), hashPin('1234'));
    });
  });
}
