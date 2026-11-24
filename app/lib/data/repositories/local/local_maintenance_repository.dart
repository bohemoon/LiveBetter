import '../../../core/constants.dart';
import '../../../core/date_utils.dart';
import '../../../domain/demo_data.dart';
import '../../backup/backup_codec.dart';
import '../../db/database.dart';
import '../../models/models.dart';
import '../maintenance_repository.dart';

/// 本地数据维护：演示数据、清除、JSON 导入导出。
class LocalMaintenanceRepository implements MaintenanceRepository {
  LocalMaintenanceRepository(this._db);

  final AppDatabase _db;

  @override
  Future<void> seedDemoData() async {
    var rows = await _db.habitDao.getAll();
    if (rows.isEmpty) {
      await _db.seedDefaults();
      rows = await _db.habitDao.getAll();
    }
    final today = todayYmd();
    final start = formatYmd(
      parseYmd(today).subtract(const Duration(days: kDemoDataDays)),
    );
    var habits = rows.map(Habit.fromRow).toList(growable: false);
    // 演示数据早于默认项目创建日期，先回填创建日以便统计可见。
    for (final habit in habits) {
      if (habit.createdAt.compareTo(start) > 0) {
        final backdated = habit.copyWith(createdAt: start, updatedAt: nowIso());
        await _db.habitDao.save(backdated);
      }
    }
    habits = habits
        .map((habit) => habit.createdAt.compareTo(start) > 0
            ? habit.copyWith(createdAt: start)
            : habit)
        .toList(growable: false);
    final records = buildDemoRecords(habits: habits, today: today);
    await _db.transaction(() async {
      for (final record in records) {
        await _db
            .into(_db.dailyRecords)
            .insertOnConflictUpdate(record.toCompanion());
      }
    });
  }

  @override
  Future<void> clearAllData() async {
    await _db.transaction(() async {
      await _db.delete(_db.dailyRecords).go();
      await _db.delete(_db.habits).go();
      await _db.delete(_db.appSettings).go();
      await _db.seedDefaults();
    });
  }

  @override
  Future<String> exportJson() async {
    final habitRows = await _db.habitDao.getAll();
    final recordRows = await _db.recordDao.all();
    final settingsRow = await _db.settingsDao.find();
    return encodeBackup(
      habits: habitRows.map(Habit.fromRow).toList(growable: false),
      records: recordRows.map(DailyRecord.fromRow).toList(growable: false),
      settings:
          settingsRow == null ? null : AppSettingsData.fromRow(settingsRow),
    );
  }

  @override
  Future<ImportSummary> importJson(String source) async {
    final payload = decodeBackup(source);
    await _db.transaction(() async {
      await _db.delete(_db.dailyRecords).go();
      await _db.delete(_db.habits).go();
      await _db.delete(_db.appSettings).go();
      for (final habit in payload.habits) {
        await _db.into(_db.habits).insert(habit.toCompanion());
      }
      for (final record in payload.records) {
        await _db.into(_db.dailyRecords).insert(record.toCompanion());
      }
      final settings = payload.settings;
      if (settings == null) {
        await _db.into(_db.appSettings).insert(AppSettingsCompanion.insert());
      } else {
        await _db.settingsDao.save(settings);
      }
    });
    return ImportSummary(
      habits: payload.habits.length,
      records: payload.records.length,
      skippedHabits: payload.skippedHabits,
      skippedRecords: payload.skippedRecords,
    );
  }
}
