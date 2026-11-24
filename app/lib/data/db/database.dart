import 'package:drift/drift.dart';

import '../../core/constants.dart';
import '../../core/date_utils.dart';
import 'connection.dart';
import 'daos/habit_dao.dart';
import 'daos/record_dao.dart';
import 'daos/settings_dao.dart';
import 'migration_backup.dart';
import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [Habits, DailyRecords, AppSettings],
  daos: [HabitDao, RecordDao, SettingsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// 打开应用私有目录下的 SQLite 文件。
  AppDatabase.open() : super(openAppConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
        await seedDefaults();
      },
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          await _backupBeforeMigration(from);
          await m.addColumn(
            appSettings,
            appSettings.periodicReminderEnabled,
          );
        }
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }

  /// 迁移前导出旧数据为 JSON 备份（仅移动端落盘）。
  Future<void> _backupBeforeMigration(int fromVersion) async {
    try {
      final habitRows = await customSelect('SELECT * FROM habits').get();
      final recordRows = await customSelect('SELECT * FROM records').get();
      final settingRows = await customSelect('SELECT * FROM app_settings').get();
      await writePreMigrationBackup(
        fromVersion: fromVersion,
        data: <String, dynamic>{
          'format': 'livebetter',
          'version': 1,
          'exportedAt': DateTime.now().toUtc().toIso8601String(),
          'habits': habitRows
              .map((row) => Map<String, dynamic>.from(row.data))
              .toList(growable: false),
          'records': recordRows
              .map((row) => Map<String, dynamic>.from(row.data))
              .toList(growable: false),
          'settings': settingRows.isEmpty
              ? null
              : Map<String, dynamic>.from(settingRows.first.data),
        },
      );
    } catch (_) {
      // 备份失败不阻塞迁移。
    }
  }

  /// 首次启动写入默认 5 项与默认设置；清除数据后同样复用。
  Future<void> seedDefaults() async {
    final today = todayYmd();
    final now = nowIso();

    await batch((batch) {
      batch.insertAll(habits, [
        HabitsCompanion.insert(
          id: HabitIds.sleepEarly,
          name: '早睡',
          type: 'active',
          createdAt: today,
          updatedAt: now,
          isRequired: const Value(1),
          targetTime: const Value(kDefaultSleepTarget),
          sortOrder: const Value(1),
        ),
        HabitsCompanion.insert(
          id: HabitIds.noFap,
          name: '禁飞',
          type: 'passive',
          createdAt: today,
          updatedAt: now,
          alias: const Value('自律项'),
          sensitive: const Value(1),
          sortOrder: const Value(2),
        ),
        HabitsCompanion.insert(
          id: HabitIds.noBuffet,
          name: '不吃自助',
          type: 'passive',
          createdAt: today,
          updatedAt: now,
          sortOrder: const Value(3),
        ),
        HabitsCompanion.insert(
          id: HabitIds.leanBody,
          name: '薄肌打造',
          type: 'active',
          createdAt: today,
          updatedAt: now,
          enabled: const Value(0),
          sortOrder: const Value(4),
        ),
        HabitsCompanion.insert(
          id: HabitIds.water,
          name: '喝水',
          type: 'meter',
          createdAt: today,
          updatedAt: now,
          goal: const Value(8),
          unit: const Value('杯'),
          step: const Value(1),
          sortOrder: const Value(5),
        ),
      ]);
      batch.insert(appSettings, AppSettingsCompanion.insert());
    });
  }
}

