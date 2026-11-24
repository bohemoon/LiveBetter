import 'package:drift/drift.dart';

/// 打卡项表。
@DataClassName('HabitRow')
class Habits extends Table {
  TextColumn get id => text()();

  TextColumn get name => text().withLength(min: 1, max: 8)();

  /// 敏感项的对外显示名。
  TextColumn get alias => text().nullable()();

  /// `active` / `passive` / `meter` / `periodic`。
  TextColumn get type => text()();

  /// 必选项（早睡），不可关闭。
  IntColumn get isRequired => integer().named('required').withDefault(const Constant(0))();

  IntColumn get enabled => integer().withDefault(const Constant(1))();

  /// 早睡目标时间 `HH:mm`。
  TextColumn get targetTime => text().nullable()();

  /// 计量项每日目标。
  IntColumn get goal => integer().nullable()();

  /// 计量单位。
  TextColumn get unit => text().nullable()();

  /// 计量项每次累加值。
  IntColumn get step => integer().nullable()();

  /// 周期项间隔天数。
  IntColumn get intervalDays => integer().nullable()();

  TextColumn get bgPath => text().nullable()();

  IntColumn get sensitive => integer().withDefault(const Constant(0))();

  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  /// 统计起点，早于该日期不参与统计。
  TextColumn get createdAt => text()();

  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 每日记录表。
@DataClassName('DailyRecordRow')
class DailyRecords extends Table {
  @override
  String get tableName => 'records';

  IntColumn get id => integer().autoIncrement()();

  TextColumn get habitId => text().references(Habits, #id)();

  /// 本地自然日 `YYYY-MM-DD`。
  TextColumn get date => text()();

  /// `success` / `fail` / `slip`，计量项为空。
  TextColumn get status => text().nullable()();

  /// 计量项当日累计。
  IntColumn get amount => integer().nullable()();

  TextColumn get recordedAt => text()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {habitId, date},
      ];
}

/// 应用设置表，单行，`id` 固定为 1。
@DataClassName('AppSettingsRow')
class AppSettings extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();

  BoolColumn get strictMode => boolean().withDefault(const Constant(false))();

  BoolColumn get reminderEnabled => boolean().withDefault(const Constant(true))();

  TextColumn get reminderTime => text().withDefault(const Constant('22:45'))();

  BoolColumn get hideSensitiveNames => boolean().withDefault(const Constant(true))();

  BoolColumn get appLockEnabled => boolean().withDefault(const Constant(false))();

  /// 加盐哈希，不存明文。
  TextColumn get pinHash => text().nullable()();

  TextColumn get gender => text().withDefault(const Constant('female'))();

  /// `green` / `blue` / `pink`。
  TextColumn get theme => text().withDefault(const Constant('green'))();

  BoolColumn get periodEnabled => boolean().withDefault(const Constant(false))();

  TextColumn get periodStart => text().nullable()();

  IntColumn get periodLength => integer().withDefault(const Constant(5))();

  IntColumn get cycleLength => integer().withDefault(const Constant(28))();

  /// 周期项到期当天的一次性提醒开关。
  BoolColumn get periodicReminderEnabled =>
      boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}
