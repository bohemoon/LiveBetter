import '../models/models.dart';

/// 打卡项仓库接口，UI 只依赖该接口。
abstract class HabitRepository {
  Future<List<Habit>> getAll();

  Stream<List<Habit>> watchAll();

  Future<List<Habit>> getEnabled();

  Future<void> save(Habit habit);

  Future<void> setEnabled(String id, bool enabled);

  /// 删除项目；`keepHistory` 为真时保留历史记录（偏差 #7）。
  Future<void> delete(String id, {required bool keepHistory});
}
