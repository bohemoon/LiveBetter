import 'package:drift/drift.dart';

import '../database.dart';
import '../tables.dart';
import '../../models/models.dart';

part 'record_dao.g.dart';

@DriftAccessor(tables: [DailyRecords])
class RecordDao extends DatabaseAccessor<AppDatabase> with _$RecordDaoMixin {
  RecordDao(super.attachedDatabase);

  Future<List<DailyRecordRow>> byDate(String date) {
    return (select(dailyRecords)..where((t) => t.date.equals(date))).get();
  }

  Future<List<DailyRecordRow>> all() {
    return (select(dailyRecords)..orderBy([(t) => OrderingTerm.asc(t.date)])).get();
  }

  Stream<List<DailyRecordRow>> watchAll() {
    return (select(dailyRecords)..orderBy([(t) => OrderingTerm.asc(t.date)])).watch();
  }

  Stream<List<DailyRecordRow>> watchByDate(String date) {
    return (select(dailyRecords)..where((t) => t.date.equals(date))).watch();
  }

  /// 同一项目同一天只保留一条记录。
  Future<void> upsert(DailyRecord record) async {
    await transaction(() async {
      await (delete(dailyRecords)
            ..where(
              (t) => t.habitId.equals(record.habitId) & t.date.equals(record.date),
            ))
          .go();
      await into(dailyRecords).insert(record.toCompanion());
    });
  }

  Future<void> remove(String habitId, String date) async {
    await (delete(dailyRecords)
          ..where((t) => t.habitId.equals(habitId) & t.date.equals(date)))
        .go();
  }

  /// 闭区间查询，用于记录页统计。
  Future<List<DailyRecordRow>> between(String start, String end) {
    return (select(dailyRecords)
          ..where((t) => t.date.isBiggerOrEqualValue(start) & t.date.isSmallerOrEqualValue(end))
          ..orderBy([(t) => OrderingTerm.asc(t.date)]))
        .get();
  }
}
