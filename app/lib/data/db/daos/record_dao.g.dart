// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'record_dao.dart';

// ignore_for_file: type=lint
mixin _$RecordDaoMixin on DatabaseAccessor<AppDatabase> {
  $HabitsTable get habits => attachedDatabase.habits;
  $DailyRecordsTable get dailyRecords => attachedDatabase.dailyRecords;
  RecordDaoManager get managers => RecordDaoManager(this);
}

class RecordDaoManager {
  final _$RecordDaoMixin _db;
  RecordDaoManager(this._db);
  $$HabitsTableTableManager get habits =>
      $$HabitsTableTableManager(_db.attachedDatabase, _db.habits);
  $$DailyRecordsTableTableManager get dailyRecords =>
      $$DailyRecordsTableTableManager(_db.attachedDatabase, _db.dailyRecords);
}
