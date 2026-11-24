import '../../db/daos/record_dao.dart';
import '../../models/models.dart';
import '../record_repository.dart';

class LocalRecordRepository implements RecordRepository {
  LocalRecordRepository(this._dao);

  final RecordDao _dao;

  @override
  Future<List<DailyRecord>> byDate(String date) async {
    final rows = await _dao.byDate(date);
    return rows.map(DailyRecord.fromRow).toList(growable: false);
  }

  @override
  Stream<List<DailyRecord>> watchByDate(String date) {
    return _dao.watchByDate(date).map(
          (rows) => rows.map(DailyRecord.fromRow).toList(growable: false),
        );
  }

  @override
  Future<List<DailyRecord>> between(String start, String end) async {
    final rows = await _dao.between(start, end);
    return rows.map(DailyRecord.fromRow).toList(growable: false);
  }

  @override
  Future<List<DailyRecord>> all() async {
    final rows = await _dao.all();
    return rows.map(DailyRecord.fromRow).toList(growable: false);
  }

  @override
  Stream<List<DailyRecord>> watchAll() {
    return _dao.watchAll().map(
          (rows) => rows.map(DailyRecord.fromRow).toList(growable: false),
        );
  }

  @override
  Future<void> upsert(DailyRecord record) => _dao.upsert(record);

  @override
  Future<void> remove(String habitId, String date) => _dao.remove(habitId, date);
}
