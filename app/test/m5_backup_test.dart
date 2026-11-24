import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:livebetter/data/backup/backup_codec.dart';
import 'package:livebetter/data/models/models.dart';
import 'package:livebetter/data/repositories/memory/memory_store.dart';

void main() {
  group('备份编解码', () {
    test('导出后可完整还原项目、记录与设置', () {
      final habits = [
        _habit(id: 'sleep_early', name: '早睡', type: HabitType.active),
        _habit(
          id: 'water',
          name: '喝水',
          type: HabitType.meter,
          goal: 8,
          unit: '杯',
          step: 1,
          bgPath: 'water.jpg',
        ),
      ];
      final records = [
        _record('sleep_early', '2026-11-20'),
        _record('water', '2026-11-20', amount: 5),
      ];
      final settings = AppSettingsData(
        strictMode: true,
        reminderEnabled: false,
        reminderTime: '23:10',
        hideSensitiveNames: false,
        appLockEnabled: true,
        pinHash: 'secret-hash',
        gender: 'male',
        theme: 'blue',
        periodEnabled: true,
        periodStart: '2026-11-01',
        periodLength: 6,
        cycleLength: 30,
        periodicReminderEnabled: false,
      );

      final json = encodeBackup(
        habits: habits,
        records: records,
        settings: settings,
        now: DateTime(2026, 11, 24, 9),
      );
      final payload = decodeBackup(json);

      expect(payload.habits.length, 2);
      expect(payload.habits.last.bgPath, 'water.jpg');
      expect(payload.habits.last.goal, 8);
      expect(payload.records.length, 2);
      expect(payload.skippedHabits, 0);
      expect(payload.skippedRecords, 0);
      expect(payload.settings?.strictMode, true);
      expect(payload.settings?.reminderTime, '23:10');
      expect(payload.settings?.periodicReminderEnabled, false);
      // 应用锁状态与密码哈希不进入备份。
      expect(payload.settings?.appLockEnabled, false);
      expect(payload.settings?.pinHash, null);
    });

    test('兼容旧版 lb.* 三键与下划线字段', () {
      final source = jsonEncode({
        'lb.habits': [
          {
            'id': 'custom_1',
            'name': '拉伸',
            'type': 'periodic',
            'required': 0,
            'enabled': 1,
            'interval_days': 14,
            'bg_path': 'stretch.jpg',
            'created_at': '2026-01-01',
          },
        ],
        'lb.records': [
          {'habit_id': 'custom_1', 'date': '2026-11-01', 'status': 'success'},
        ],
        'lb.settings': {'reminder_enabled': false, 'cycle_length': 31},
      });

      final payload = decodeBackup(source);
      expect(payload.habits.single.type, HabitType.periodic);
      expect(payload.habits.single.intervalDays, 14);
      expect(payload.habits.single.bgPath, 'stretch.jpg');
      expect(payload.records.single.habitId, 'custom_1');
      expect(payload.settings?.reminderEnabled, false);
      expect(payload.settings?.cycleLength, 31);
    });

    test('未知类型与重复记录被跳过并计数', () {
      final source = jsonEncode({
        'format': 'livebetter',
        'version': 1,
        'habits': [
          {'id': 'a', 'name': '有效项', 'type': 'active'},
          {'id': 'b', 'name': '未来类型', 'type': 'unknown'},
          {'id': 'a', 'name': '重复 ID', 'type': 'active'},
        ],
        'records': [
          {'habitId': 'a', 'date': '2026-11-20', 'status': 'success'},
          {'habitId': 'a', 'date': '2026-11-20', 'status': 'fail'},
          {'habitId': 'missing', 'date': '2026-11-20', 'status': 'success'},
        ],
      });

      final payload = decodeBackup(source);
      expect(payload.habits.length, 1);
      expect(payload.skippedHabits, 2);
      expect(payload.records.length, 1);
      expect(payload.records.single.status, RecordStatus.success);
      expect(payload.skippedRecords, 2);
    });

    test('非 LiveBetter、版本不支持与缺少项目都会被拒绝', () {
      expect(
        () => decodeBackup(jsonEncode({'format': 'other', 'habits': []})),
        throwsA(isA<BackupException>()),
      );
      expect(
        () => decodeBackup(jsonEncode({
          'format': 'livebetter',
          'version': 2,
          'habits': [],
        })),
        throwsA(isA<BackupException>()),
      );
      expect(
        () => decodeBackup(jsonEncode({'records': []})),
        throwsA(isA<BackupException>()),
      );
      expect(
        () => decodeBackup(jsonEncode({'habits': []})),
        throwsA(isA<BackupException>()),
      );
      expect(
        () => decodeBackup('not-json'),
        throwsA(isA<BackupException>()),
      );
    });

    test('备份文件名使用 YYYYMMDD', () {
      expect(backupFileName(DateTime(2026, 3, 5)), 'livebetter-backup-20260305.json');
    });

    test('内存仓库可完成导出与整库导入', () async {
      final store = MemoryStore.seeded();
      final exported = await store.maintenanceRepository.exportJson();
      final expected = decodeBackup(exported);
      final summary = await store.maintenanceRepository.importJson(exported);

      expect(summary.habits, expected.habits.length);
      expect(summary.records, expected.records.length);
      expect(store.habits.length, expected.habits.length);
      expect(store.settings.periodicReminderEnabled, true);
    });

    test('非法备份不会改动现有数据', () async {
      final store = MemoryStore.seeded();
      final before = store.habits.length;
      expect(
        () => store.maintenanceRepository.importJson('not-json'),
        throwsA(isA<BackupException>()),
      );
      expect(store.habits.length, before);
    });
  });
}

Habit _habit({
  required String id,
  required String name,
  required HabitType type,
  int? goal,
  String? unit,
  int? step,
  String? bgPath,
}) {
  return Habit(
    id: id,
    name: name,
    type: type,
    isRequired: false,
    enabled: true,
    sensitive: false,
    sortOrder: 0,
    goal: goal,
    unit: unit,
    step: step,
    bgPath: bgPath,
    createdAt: '2026-01-01',
    updatedAt: '2026-01-01T08:00:00.000',
  );
}

DailyRecord _record(String habitId, String date, {int? amount}) {
  return DailyRecord(
    habitId: habitId,
    date: date,
    status: amount == null ? RecordStatus.success : null,
    amount: amount,
    recordedAt: '${date}T08:00:00.000',
  );
}
