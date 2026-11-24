import 'dart:convert';

import '../../core/date_utils.dart';
import '../models/models.dart';

/// 备份文件格式标识与版本。
const String kBackupFormat = 'livebetter';
const int kBackupVersion = 1;

/// 编解码或校验失败，`message` 可直接展示给用户。
class BackupException implements Exception {
  BackupException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// 解析后的备份内容。
class BackupPayload {
  const BackupPayload({
    required this.habits,
    required this.records,
    required this.settings,
    required this.skippedHabits,
    required this.skippedRecords,
  });

  final List<Habit> habits;
  final List<DailyRecord> records;
  final AppSettingsData? settings;
  final int skippedHabits;
  final int skippedRecords;
}

/// 导出为可直接写入文件的 JSON 字符串。
///
/// 图片不进入备份，仅保留 `bgPath`；应用锁状态与 PIN 哈希不导出。
String encodeBackup({
  required List<Habit> habits,
  required List<DailyRecord> records,
  AppSettingsData? settings,
  DateTime? now,
}) {
  final exportedAt = (now ?? DateTime.now()).toUtc().toIso8601String();
  final data = <String, dynamic>{
    'format': kBackupFormat,
    'version': kBackupVersion,
    'exportedAt': exportedAt,
    'habits': habits.map(_habitToJson).toList(growable: false),
    'records': records.map(_recordToJson).toList(growable: false),
    if (settings != null) 'settings': _settingsToJson(settings),
  };
  return const JsonEncoder.withIndent('  ').convert(data);
}

/// 备份文件名：`livebetter-backup-YYYYMMDD.json`。
String backupFileName([DateTime? now]) {
  final date = now ?? DateTime.now();
  final stamp = '${date.year.toString().padLeft(4, '0')}'
      '${date.month.toString().padLeft(2, '0')}'
      '${date.day.toString().padLeft(2, '0')}';
  return 'livebetter-backup-$stamp.json';
}

/// 解析备份文件，兼容标准格式、裸对象与旧版 `lb.*` 三键。
BackupPayload decodeBackup(String source) {
  dynamic decoded;
  try {
    decoded = jsonDecode(source);
  } catch (_) {
    throw BackupException('文件不是有效的 JSON');
  }
  if (decoded is! Map) {
    throw BackupException('备份内容结构不正确');
  }
  final map = _normalizeMap(decoded);

  final format = map['format'];
  if (format != null && format != kBackupFormat) {
    throw BackupException('不是 LiveBetter 的备份文件');
  }
  final version = _asInt(map['version']);
  if (version != null && version != kBackupVersion) {
    throw BackupException('暂不支持该备份版本（$version）');
  }

  final rawHabits = _asList(map['habits']);
  final rawRecords = _asList(map['records']);
  if (rawHabits == null) {
    throw BackupException('备份缺少打卡项数据');
  }

  final habits = <Habit>[];
  final habitIds = <String>{};
  var skippedHabits = 0;
  for (final raw in rawHabits) {
    final habit = _parseHabit(raw);
    if (habit == null || !habitIds.add(habit.id)) {
      skippedHabits++;
      continue;
    }
    habits.add(habit);
  }
  if (habits.isEmpty) {
    throw BackupException('备份中没有可导入的打卡项');
  }

  final records = <DailyRecord>[];
  final recordKeys = <String>{};
  var skippedRecords = 0;
  for (final raw in rawRecords ?? const []) {
    final record = _parseRecord(raw);
    if (record == null ||
        !habitIds.contains(record.habitId) ||
        !recordKeys.add('${record.habitId}|${record.date}')) {
      skippedRecords++;
      continue;
    }
    records.add(record);
  }

  return BackupPayload(
    habits: habits,
    records: records,
    settings: _parseSettings(map['settings']),
    skippedHabits: skippedHabits,
    skippedRecords: skippedRecords,
  );
}

Map<String, dynamic> _normalizeMap(Map source) {
  final map = <String, dynamic>{};
  source.forEach((key, value) {
    if (key is! String) return;
    // 旧版 `lb.habits` 三键统一去前缀。
    final normalized = key.startsWith('lb.') ? key.substring(3) : key;
    map[normalized] = value;
  });
  return map;
}

Map<String, dynamic> _habitToJson(Habit habit) {
  return <String, dynamic>{
    'id': habit.id,
    'name': habit.name,
    if (habit.alias != null) 'alias': habit.alias,
    'type': habit.type.name,
    'required': habit.isRequired,
    'enabled': habit.enabled,
    if (habit.targetTime != null) 'targetTime': habit.targetTime,
    if (habit.goal != null) 'goal': habit.goal,
    if (habit.unit != null) 'unit': habit.unit,
    if (habit.step != null) 'step': habit.step,
    if (habit.intervalDays != null) 'intervalDays': habit.intervalDays,
    if (habit.bgPath != null) 'bgPath': habit.bgPath,
    'sensitive': habit.sensitive,
    'sortOrder': habit.sortOrder,
    'createdAt': habit.createdAt,
    'updatedAt': habit.updatedAt,
  };
}

Map<String, dynamic> _recordToJson(DailyRecord record) {
  return <String, dynamic>{
    'habitId': record.habitId,
    'date': record.date,
    if (record.status != null) 'status': record.status!.value,
    if (record.amount != null) 'amount': record.amount,
    'recordedAt': record.recordedAt,
  };
}

Map<String, dynamic> _settingsToJson(AppSettingsData settings) {
  return <String, dynamic>{
    'strictMode': settings.strictMode,
    'reminderEnabled': settings.reminderEnabled,
    'reminderTime': settings.reminderTime,
    'hideSensitiveNames': settings.hideSensitiveNames,
    'gender': settings.gender,
    'theme': settings.theme,
    'periodEnabled': settings.periodEnabled,
    'periodStart': settings.periodStart,
    'periodLength': settings.periodLength,
    'cycleLength': settings.cycleLength,
    'periodicReminderEnabled': settings.periodicReminderEnabled,
  };
}

Habit? _parseHabit(dynamic raw) {
  if (raw is! Map) return null;
  final id = _asString(_value(raw, ['id']));
  final name = _asString(_value(raw, ['name']));
  if (id == null || id.isEmpty || name == null || name.trim().isEmpty) {
    return null;
  }
  final typeValue = _asString(_value(raw, ['type'])) ?? HabitType.active.name;
  HabitType? type;
  for (final item in HabitType.values) {
    if (item.name == typeValue) {
      type = item;
      break;
    }
  }
  if (type == null) return null;

  final createdAt = _asDate(_value(raw, ['createdAt', 'created_at'])) ?? todayYmd();
  final updatedAt =
      _asString(_value(raw, ['updatedAt', 'updated_at'])) ?? nowIso();
  final targetTime = _asTime(_value(raw, ['targetTime', 'target_time']));
  final trimmedName = name.trim();

  return Habit(
    id: id,
    name: trimmedName.length > 8 ? trimmedName.substring(0, 8) : trimmedName,
    alias: _asString(_value(raw, ['alias'])),
    type: type,
    isRequired: _asBool(_value(raw, ['required', 'isRequired'])) ?? false,
    enabled: _asBool(_value(raw, ['enabled'])) ?? true,
    targetTime: targetTime,
    goal: _asInt(_value(raw, ['goal'])),
    unit: _asString(_value(raw, ['unit'])),
    step: _asInt(_value(raw, ['step'])),
    intervalDays: _asInt(_value(raw, ['intervalDays', 'interval_days'])),
    bgPath: _asString(_value(raw, ['bgPath', 'bg_path'])),
    sensitive: _asBool(_value(raw, ['sensitive'])) ?? false,
    sortOrder: _asInt(_value(raw, ['sortOrder', 'sort_order'])) ?? 0,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

DailyRecord? _parseRecord(dynamic raw) {
  if (raw is! Map) return null;
  final habitId = _asString(_value(raw, ['habitId', 'habit_id']));
  final date = _asDate(_value(raw, ['date']));
  if (habitId == null || habitId.isEmpty || date == null) return null;

  final status = RecordStatus.parse(
    _asString(_value(raw, ['status'])),
  );
  final amount = _asInt(_value(raw, ['amount']));
  if (status == null && amount == null) return null;

  return DailyRecord(
    habitId: habitId,
    date: date,
    status: status,
    amount: amount,
    recordedAt:
        _asString(_value(raw, ['recordedAt', 'recorded_at'])) ?? nowIso(),
  );
}

AppSettingsData? _parseSettings(dynamic raw) {
  if (raw is! Map) return null;
  final start = _asDate(_value(raw, ['periodStart', 'period_start']));
  return AppSettingsData(
    strictMode: _asBool(_value(raw, ['strictMode', 'strict_mode'])) ?? false,
    reminderEnabled:
        _asBool(_value(raw, ['reminderEnabled', 'reminder_enabled'])) ?? true,
    reminderTime: _asTime(_value(raw, ['reminderTime', 'reminder_time'])) ??
        '22:45',
    hideSensitiveNames:
        _asBool(_value(raw, ['hideSensitiveNames', 'hide_sensitive_names'])) ??
            true,
    appLockEnabled: false,
    gender: _asString(_value(raw, ['gender'])) ?? 'female',
    theme: _asString(_value(raw, ['theme'])) ?? 'green',
    periodEnabled:
        _asBool(_value(raw, ['periodEnabled', 'period_enabled'])) ?? false,
    periodStart: start,
    periodLength:
        _asInt(_value(raw, ['periodLength', 'period_length'])) ?? 5,
    cycleLength: _asInt(_value(raw, ['cycleLength', 'cycle_length'])) ?? 28,
    periodicReminderEnabled:
        _asBool(_value(raw, ['periodicReminderEnabled', 'periodic_reminder_enabled'])) ??
            true,
  );
}

dynamic _value(Map raw, List<String> keys) {
  for (final key in keys) {
    if (raw.containsKey(key)) return raw[key];
  }
  return null;
}

List? _asList(dynamic value) => value is List ? value : null;

String? _asString(dynamic value) {
  if (value is String) return value;
  if (value is num || value is bool) return value.toString();
  return null;
}

int? _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

bool? _asBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.toLowerCase();
    if (normalized == 'true' || normalized == '1') return true;
    if (normalized == 'false' || normalized == '0') return false;
  }
  return null;
}

String? _asDate(dynamic value) {
  final text = _asString(value);
  if (text == null) return null;
  final trimmed = text.trim();
  if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(trimmed)) return null;
  return trimmed;
}

String? _asTime(dynamic value) {
  final text = _asString(value)?.trim();
  if (text == null) return null;
  return RegExp(r'^\d{2}:\d{2}$').hasMatch(text) ? text : null;
}
