import 'package:flutter_test/flutter_test.dart';
import 'package:livebetter/data/models/models.dart';
import 'package:livebetter/features/notifications/reminder_scheduler.dart';
import 'package:livebetter/services/notification_service.dart';

void main() {
  group('提醒排期', () {
    test('每日提醒按待完成项生成中性文案，并安排周期到期提醒', () async {
      final fake = _FakeNotifications();
      final scheduler = ReminderScheduler(fake);
      final habits = [
        _habit('a', '项目 A'),
        _habit('b', '项目 B'),
        _habit('p', '体检', type: HabitType.periodic, intervalDays: 30),
      ];
      final records = [_success('a', '2026-11-24')];

      await scheduler.sync(
        settings: _settings(reminderTime: '22:45'),
        habits: habits,
        records: records,
        today: '2026-11-24',
      );

      expect(fake.dailyHour, 22);
      expect(fake.dailyMinute, 45);
      expect(fake.dailyBody, contains('1 项'));
      expect(fake.periodic, hasLength(1));
      expect(fake.periodic.single.habitName, '体检');
      expect(fake.periodic.single.dueDate, '2026-11-24');
    });

    test('没有待完成项时使用更温和的文案', () async {
      final fake = _FakeNotifications();
      final scheduler = ReminderScheduler(fake);
      await scheduler.sync(
        settings: _settings(),
        habits: [_habit('a', '项目 A')],
        records: [_success('a', '2026-11-24')],
        today: '2026-11-24',
      );

      expect(fake.dailyBody, '今天可以慢一点，按自己的节奏来');
    });

    test('关闭每日提醒与周期提醒后全部取消', () async {
      final fake = _FakeNotifications();
      final scheduler = ReminderScheduler(fake);
      await scheduler.sync(
        settings: _settings(reminderEnabled: false, periodicReminderEnabled: false),
        habits: [_habit('p', '体检', type: HabitType.periodic, intervalDays: 30)],
        records: const [],
        today: '2026-11-24',
      );

      expect(fake.dailyCancelled, true);
      expect(fake.periodicCancelled, true);
      expect(fake.dailyBody, isNull);
      expect(fake.periodic, isEmpty);
    });

    test('关闭周期提醒时不影响每日提醒', () async {
      final fake = _FakeNotifications();
      final scheduler = ReminderScheduler(fake);
      await scheduler.sync(
        settings: _settings(periodicReminderEnabled: false),
        habits: [_habit('p', '体检', type: HabitType.periodic, intervalDays: 30)],
        records: const [],
        today: '2026-11-24',
      );

      expect(fake.dailyBody, isNotNull);
      expect(fake.periodicCancelled, true);
      expect(fake.periodic, isEmpty);
    });

    test('周期项完成后的下次到期日期写入排期', () async {
      final fake = _FakeNotifications();
      final scheduler = ReminderScheduler(fake);
      await scheduler.sync(
        settings: _settings(),
        habits: [_habit('p', '体检', type: HabitType.periodic, intervalDays: 7)],
        records: [_success('p', '2026-11-24')],
        today: '2026-11-24',
      );

      expect(fake.periodic.single.dueDate, '2026-12-01');
    });
  });
}

AppSettingsData _settings({
  bool reminderEnabled = true,
  bool periodicReminderEnabled = true,
  String reminderTime = '22:45',
}) {
  return AppSettingsData(
    strictMode: false,
    reminderEnabled: reminderEnabled,
    reminderTime: reminderTime,
    hideSensitiveNames: true,
    appLockEnabled: false,
    gender: 'female',
    theme: 'green',
    periodEnabled: false,
    periodLength: 5,
    cycleLength: 28,
    periodicReminderEnabled: periodicReminderEnabled,
  );
}

Habit _habit(
  String id,
  String name, {
  HabitType type = HabitType.active,
  int? intervalDays,
}) {
  return Habit(
    id: id,
    name: name,
    type: type,
    isRequired: false,
    enabled: true,
    sensitive: false,
    sortOrder: 0,
    intervalDays: intervalDays,
    createdAt: '2026-01-01',
    updatedAt: '2026-01-01T08:00:00.000',
  );
}

DailyRecord _success(String habitId, String date) {
  return DailyRecord(
    habitId: habitId,
    date: date,
    status: RecordStatus.success,
    recordedAt: '${date}T08:00:00.000',
  );
}

class _FakeNotifications implements NotificationService {
  int? dailyHour;
  int? dailyMinute;
  String? dailyBody;
  bool dailyCancelled = false;
  bool periodicCancelled = false;
  final List<({String habitName, String dueDate})> periodic = [];

  @override
  Stream<void> get tapStream => const Stream<void>.empty();

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> scheduleDaily({
    required int hour,
    required int minute,
    required String body,
  }) async {
    dailyHour = hour;
    dailyMinute = minute;
    dailyBody = body;
  }

  @override
  Future<void> cancelDaily() async {
    dailyCancelled = true;
    dailyBody = null;
  }

  @override
  Future<void> schedulePeriodic({
    required int id,
    required String habitName,
    required String dueDate,
  }) async {
    periodic.add((habitName: habitName, dueDate: dueDate));
  }

  @override
  Future<void> cancelPeriodic() async {
    periodicCancelled = true;
    periodic.clear();
  }
}
