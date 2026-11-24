import '../models/models.dart';

/// 每日记录仓库接口。
abstract class RecordRepository {
  Future<List<DailyRecord>> byDate(String date);

  Stream<List<DailyRecord>> watchByDate(String date);

  /// 闭区间查询，起止均为 `YYYY-MM-DD`。
  Future<List<DailyRecord>> between(String start, String end);

  /// 全部记录，按日期升序，用于统计引擎。
  Future<List<DailyRecord>> all();

  /// 全部记录的实时流，任意写入后自动推送。
  Stream<List<DailyRecord>> watchAll();

  Future<void> upsert(DailyRecord record);

  Future<void> remove(String habitId, String date);
}
