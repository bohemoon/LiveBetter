import 'dart:async';

import 'package:livebetter/core/date_utils.dart';
import 'package:livebetter/data/backup/backup_codec.dart';
import 'package:livebetter/data/models/models.dart';
import 'package:livebetter/data/repositories/habit_repository.dart';
import 'package:livebetter/data/repositories/maintenance_repository.dart';
import 'package:livebetter/data/repositories/record_repository.dart';
import 'package:livebetter/data/repositories/settings_repository.dart';

/// 测试用内存数据源，行为与本地仓库一致，进程结束后重置。
class MemoryStore {
  MemoryStore._();

  factory MemoryStore.seeded() => MemoryStore._().._seed();

  final List<Habit> _habits = [];
  final List<DailyRecord> _records = [];
  late AppSettingsData _settings;

  final _habitChanges = StreamController<List<Habit>>.broadcast();
  final _recordChanges = StreamController<List<DailyRecord>>.broadcast();
  final _settingsChanges = StreamController<AppSettingsData>.broadcast();

  late final HabitRepository habitRepository = _MemoryHabitRepository(this);
  late final RecordRepository recordRepository = _MemoryRecordRepository(this);
  late final SettingsRepository settingsRepository = _MemorySettingsRepository(this);
  late final MaintenanceRepository maintenanceRepository =
      _MemoryMaintenanceRepository(this);

  static String _daysAgo(int days) {
    final now = DateTime.now();
    return formatYmd(DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: days)));
  }

  Habit _habit({
    required String id,
    required String name,
    required HabitType type,
    required int sortOrder,
    bool enabled = true,
    bool isRequired = false,
    bool sensitive = false,
    String? alias,
    String? targetTime,
    int? goal,
    String? unit,
    int? step,
  }) {
    return Habit(
      id: id,
      name: name,
      type: type,
      isRequired: isRequired,
      enabled: enabled,
      sensitive: sensitive,
      alias: alias,
      targetTime: targetTime,
      goal: goal,
      unit: unit,
      step: step,
      sortOrder: sortOrder,
      createdAt: _daysAgo(10),
      updatedAt: nowIso(),
    );
  }

  void _seed() {
    _seedHabits();
    _seedSampleRecords();
    _settings = _defaultSettings();
  }

  void _seedHabits() {
    _habits.addAll([
      _habit(
        id: 'sleep_early',
        name: '早睡',
        type: HabitType.active,
        sortOrder: 1,
        isRequired: true,
        targetTime: '23:30',
      ),
      _habit(
        id: 'no_fap',
        name: '禁飞',
        type: HabitType.passive,
        sortOrder: 2,
        sensitive: true,
        alias: '自律项',
      ),
      _habit(
        id: 'no_buffet',
        name: '不吃自助',
        type: HabitType.passive,
        sortOrder: 3,
      ),
      _habit(
        id: 'lean_body',
        name: '薄肌打造',
        type: HabitType.active,
        sortOrder: 4,
        enabled: false,
      ),
      _habit(
        id: 'water',
        name: '喝水',
        type: HabitType.meter,
        sortOrder: 5,
        goal: 8,
        unit: '杯',
        step: 1,
      ),
    ]);
  }

  void _seedSampleRecords() {
    for (final days in [1, 2, 3]) {
      _records.add(DailyRecord(
        habitId: 'sleep_early',
        date: _daysAgo(days),
        status: RecordStatus.success,
        recordedAt: nowIso(),
      ));
    }
    _records.add(DailyRecord(
      habitId: 'no_fap',
      date: _daysAgo(1),
      status: RecordStatus.slip,
      recordedAt: nowIso(),
    ));
    _records.add(DailyRecord(
      habitId: 'water',
      date: _daysAgo(1),
      amount: 8,
      recordedAt: nowIso(),
    ));
    _records.add(DailyRecord(
      habitId: 'water',
      date: todayYmd(),
      amount: 2,
      recordedAt: nowIso(),
    ));
  }

  AppSettingsData _defaultSettings() {
    return const AppSettingsData(
      strictMode: false,
      reminderEnabled: true,
      reminderTime: '22:45',
      hideSensitiveNames: true,
      appLockEnabled: false,
      gender: 'female',
      theme: 'green',
      periodEnabled: false,
      periodLength: 5,
      cycleLength: 28,
    );
  }

  /// 清除全部数据并恢复默认 5 项与默认设置。
  void _clearAllData() {
    _habits.clear();
    _records.clear();
    _seedHabits();
    _settings = _defaultSettings();
    _emitHabits();
    _emitRecords();
    _emitSettings();
  }

  /// 整库覆盖导入。
  void _replaceAll(BackupPayload payload) {
    _habits
      ..clear()
      ..addAll(payload.habits);
    _records
      ..clear()
      ..addAll(payload.records);
    _settings = payload.settings ?? _defaultSettings();
    _emitHabits();
    _emitRecords();
    _emitSettings();
  }

  List<Habit> get habits => List.unmodifiable(_habits);
  List<DailyRecord> get records => List.unmodifiable(_records);
  AppSettingsData get settings => _settings;

  Stream<List<Habit>> get habitStream => _habitChanges.stream;
  Stream<List<DailyRecord>> get recordStream => _recordChanges.stream;
  Stream<AppSettingsData> get settingsStream => _settingsChanges.stream;

  void _emitHabits() => _habitChanges.add(habits);
  void _emitRecords() => _recordChanges.add(records);
  void _emitSettings() => _settingsChanges.add(_settings);

  void _saveHabit(Habit habit) {
    final index = _habits.indexWhere((item) => item.id == habit.id);
    if (index >= 0) {
      _habits[index] = habit;
    } else {
      _habits.add(habit);
    }
    _emitHabits();
  }

  void _setHabitEnabled(String id, bool enabled) {
    final index = _habits.indexWhere((item) => item.id == id);
    if (index < 0) return;
    _habits[index] = _habits[index].copyWith(
      enabled: enabled,
      updatedAt: nowIso(),
    );
    _emitHabits();
  }

  void _deleteHabit(String id, {required bool keepHistory}) {
    _habits.removeWhere((item) => item.id == id);
    if (!keepHistory) {
      _records.removeWhere((item) => item.habitId == id);
      _emitRecords();
    }
    _emitHabits();
  }

  void _upsertRecord(DailyRecord record) {
    _records.removeWhere(
      (item) => item.habitId == record.habitId && item.date == record.date,
    );
    _records.add(record);
    _emitRecords();
  }

  void _removeRecord(String habitId, String date) {
    _records.removeWhere(
      (item) => item.habitId == habitId && item.date == date,
    );
    _emitRecords();
  }

  void _saveSettings(AppSettingsData settings) {
    _settings = settings;
    _emitSettings();
  }
}

class _MemoryHabitRepository implements HabitRepository {
  _MemoryHabitRepository(this._store);

  final MemoryStore _store;

  @override
  Future<List<Habit>> getAll() async => _store.habits;

  @override
  Stream<List<Habit>> watchAll() async* {
    yield _store.habits;
    yield* _store.habitStream;
  }

  @override
  Future<List<Habit>> getEnabled() async =>
      _store.habits.where((habit) => habit.enabled).toList();

  @override
  Future<void> save(Habit habit) async => _store._saveHabit(habit);

  @override
  Future<void> setEnabled(String id, bool enabled) async =>
      _store._setHabitEnabled(id, enabled);

  @override
  Future<void> delete(String id, {required bool keepHistory}) async =>
      _store._deleteHabit(id, keepHistory: keepHistory);
}

class _MemoryRecordRepository implements RecordRepository {
  _MemoryRecordRepository(this._store);

  final MemoryStore _store;

  @override
  Future<List<DailyRecord>> byDate(String date) async =>
      _store.records.where((record) => record.date == date).toList();

  @override
  Stream<List<DailyRecord>> watchByDate(String date) {
    return _store.recordStream
        .map((records) => records.where((record) => record.date == date).toList());
  }

  @override
  Future<List<DailyRecord>> between(String start, String end) async {
    return _store.records
        .where((record) =>
            record.date.compareTo(start) >= 0 && record.date.compareTo(end) <= 0)
        .toList();
  }

  @override
  Future<List<DailyRecord>> all() async => _store.records;

  @override
  Stream<List<DailyRecord>> watchAll() async* {
    yield _store.records;
    yield* _store.recordStream;
  }

  @override
  Future<void> upsert(DailyRecord record) async => _store._upsertRecord(record);

  @override
  Future<void> remove(String habitId, String date) async =>
      _store._removeRecord(habitId, date);
}

class _MemorySettingsRepository implements SettingsRepository {
  _MemorySettingsRepository(this._store);

  final MemoryStore _store;

  @override
  Future<AppSettingsData> get() async => _store.settings;

  @override
  Stream<AppSettingsData> watch() async* {
    yield _store.settings;
    yield* _store.settingsStream;
  }

  @override
  Future<void> save(AppSettingsData settings) async =>
      _store._saveSettings(settings);
}

class _MemoryMaintenanceRepository implements MaintenanceRepository {
  _MemoryMaintenanceRepository(this._store);

  final MemoryStore _store;

  @override
  Future<void> clearAllData() async => _store._clearAllData();

  @override
  Future<String> exportJson() async => encodeBackup(
        habits: _store.habits,
        records: _store.records,
        settings: _store.settings,
      );

  @override
  Future<ImportSummary> importJson(String source) async {
    final payload = decodeBackup(source);
    _store._replaceAll(payload);
    return ImportSummary(
      habits: payload.habits.length,
      records: payload.records.length,
      skippedHabits: payload.skippedHabits,
      skippedRecords: payload.skippedRecords,
    );
  }
}
