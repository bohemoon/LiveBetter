import 'package:drift/drift.dart' show Value;

import '../db/database.dart';

/// 打卡项类型。
enum HabitType {
  active('主动'),
  passive('被动'),
  meter('计量'),
  periodic('周期');

  const HabitType(this.label);

  final String label;

  static HabitType parse(String value) {
    return HabitType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => HabitType.active,
    );
  }
}

/// 记录状态。
enum RecordStatus {
  success('success'),
  fail('fail'),
  slip('slip');

  const RecordStatus(this.value);

  final String value;

  static RecordStatus? parse(String? value) {
    if (value == null) return null;
    for (final status in RecordStatus.values) {
      if (status.value == value) return status;
    }
    return null;
  }
}

/// 打卡项领域模型。
class Habit {
  const Habit({
    required this.id,
    required this.name,
    required this.type,
    required this.isRequired,
    required this.enabled,
    required this.sensitive,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
    this.alias,
    this.targetTime,
    this.goal,
    this.unit,
    this.step,
    this.intervalDays,
    this.bgPath,
  });

  final String id;
  final String name;
  final String? alias;
  final HabitType type;
  final bool isRequired;
  final bool enabled;
  final String? targetTime;
  final int? goal;
  final String? unit;
  final int? step;
  final int? intervalDays;
  final String? bgPath;
  final bool sensitive;
  final int sortOrder;
  final String createdAt;
  final String updatedAt;

  /// 列表展示名：敏感项按设置隐藏名称。
  String displayName({required bool hideSensitive}) {
    if (sensitive && hideSensitive) {
      final fallback = alias?.trim();
      return (fallback == null || fallback.isEmpty) ? '自律项' : fallback;
    }
    return name;
  }

  Habit copyWith({
    String? name,
    String? alias,
    bool clearAlias = false,
    HabitType? type,
    bool? isRequired,
    bool? enabled,
    String? targetTime,
    int? goal,
    String? unit,
    int? step,
    int? intervalDays,
    String? bgPath,
    bool clearBgPath = false,
    bool? sensitive,
    int? sortOrder,
    String? createdAt,
    String? updatedAt,
  }) {
    return Habit(
      id: id,
      name: name ?? this.name,
      alias: clearAlias ? null : (alias ?? this.alias),
      type: type ?? this.type,
      isRequired: isRequired ?? this.isRequired,
      enabled: enabled ?? this.enabled,
      targetTime: targetTime ?? this.targetTime,
      goal: goal ?? this.goal,
      unit: unit ?? this.unit,
      step: step ?? this.step,
      intervalDays: intervalDays ?? this.intervalDays,
      bgPath: clearBgPath ? null : (bgPath ?? this.bgPath),
      sensitive: sensitive ?? this.sensitive,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Habit.fromRow(HabitRow row) {
    return Habit(
      id: row.id,
      name: row.name,
      alias: row.alias,
      type: HabitType.parse(row.type),
      isRequired: row.isRequired != 0,
      enabled: row.enabled != 0,
      targetTime: row.targetTime,
      goal: row.goal,
      unit: row.unit,
      step: row.step,
      intervalDays: row.intervalDays,
      bgPath: row.bgPath,
      sensitive: row.sensitive != 0,
      sortOrder: row.sortOrder,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  HabitsCompanion toCompanion() {
    return HabitsCompanion(
      id: Value(id),
      name: Value(name),
      alias: Value(alias),
      type: Value(type.name),
      isRequired: Value(isRequired ? 1 : 0),
      enabled: Value(enabled ? 1 : 0),
      targetTime: Value(targetTime),
      goal: Value(goal),
      unit: Value(unit),
      step: Value(step),
      intervalDays: Value(intervalDays),
      bgPath: Value(bgPath),
      sensitive: Value(sensitive ? 1 : 0),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }
}

/// 每日记录领域模型。
class DailyRecord {
  const DailyRecord({
    this.id,
    required this.habitId,
    required this.date,
    required this.recordedAt,
    this.status,
    this.amount,
  });

  final int? id;
  final String habitId;
  final String date;
  final RecordStatus? status;
  final int? amount;
  final String recordedAt;

  factory DailyRecord.fromRow(DailyRecordRow row) {
    return DailyRecord(
      id: row.id,
      habitId: row.habitId,
      date: row.date,
      status: RecordStatus.parse(row.status),
      amount: row.amount,
      recordedAt: row.recordedAt,
    );
  }

  DailyRecordsCompanion toCompanion() {
    return DailyRecordsCompanion(
      id: id == null ? const Value.absent() : Value(id!),
      habitId: Value(habitId),
      date: Value(date),
      status: Value(status?.value),
      amount: Value(amount),
      recordedAt: Value(recordedAt),
    );
  }
}

/// 应用设置领域模型。
class AppSettingsData {
  const AppSettingsData({
    required this.strictMode,
    required this.reminderEnabled,
    required this.reminderTime,
    required this.hideSensitiveNames,
    required this.appLockEnabled,
    required this.gender,
    required this.theme,
    required this.periodEnabled,
    required this.periodLength,
    required this.cycleLength,
    this.periodicReminderEnabled = true,
    this.pinHash,
    this.periodStart,
  });

  final bool strictMode;
  final bool reminderEnabled;
  final String reminderTime;
  final bool hideSensitiveNames;
  final bool appLockEnabled;
  final String? pinHash;
  final String gender;
  final String theme;
  final bool periodEnabled;
  final String? periodStart;
  final int periodLength;
  final int cycleLength;
  final bool periodicReminderEnabled;

  factory AppSettingsData.fromRow(AppSettingsRow row) {
    return AppSettingsData(
      strictMode: row.strictMode,
      reminderEnabled: row.reminderEnabled,
      reminderTime: row.reminderTime,
      hideSensitiveNames: row.hideSensitiveNames,
      appLockEnabled: row.appLockEnabled,
      pinHash: row.pinHash,
      gender: row.gender,
      theme: row.theme,
      periodEnabled: row.periodEnabled,
      periodStart: row.periodStart,
      periodLength: row.periodLength,
      cycleLength: row.cycleLength,
      periodicReminderEnabled: row.periodicReminderEnabled,
    );
  }

  AppSettingsData copyWith({
    bool? strictMode,
    bool? reminderEnabled,
    String? reminderTime,
    bool? hideSensitiveNames,
    bool? appLockEnabled,
    String? pinHash,
    bool clearPinHash = false,
    String? gender,
    String? theme,
    bool? periodEnabled,
    String? periodStart,
    int? periodLength,
    int? cycleLength,
    bool? periodicReminderEnabled,
  }) {
    return AppSettingsData(
      strictMode: strictMode ?? this.strictMode,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      hideSensitiveNames: hideSensitiveNames ?? this.hideSensitiveNames,
      appLockEnabled: appLockEnabled ?? this.appLockEnabled,
      pinHash: clearPinHash ? null : (pinHash ?? this.pinHash),
      gender: gender ?? this.gender,
      theme: theme ?? this.theme,
      periodEnabled: periodEnabled ?? this.periodEnabled,
      periodStart: periodStart ?? this.periodStart,
      periodLength: periodLength ?? this.periodLength,
      cycleLength: cycleLength ?? this.cycleLength,
      periodicReminderEnabled:
          periodicReminderEnabled ?? this.periodicReminderEnabled,
    );
  }

  AppSettingsCompanion toCompanion() {
    return AppSettingsCompanion(
      id: const Value(1),
      strictMode: Value(strictMode),
      reminderEnabled: Value(reminderEnabled),
      reminderTime: Value(reminderTime),
      hideSensitiveNames: Value(hideSensitiveNames),
      appLockEnabled: Value(appLockEnabled),
      pinHash: Value(pinHash),
      gender: Value(gender),
      theme: Value(theme),
      periodEnabled: Value(periodEnabled),
      periodStart: Value(periodStart),
      periodLength: Value(periodLength),
      cycleLength: Value(cycleLength),
      periodicReminderEnabled: Value(periodicReminderEnabled),
    );
  }
}
