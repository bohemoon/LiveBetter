import 'package:drift/drift.dart';

import '../database.dart';
import '../tables.dart';
import '../../models/models.dart';

part 'habit_dao.g.dart';

@DriftAccessor(tables: [Habits])
class HabitDao extends DatabaseAccessor<AppDatabase> with _$HabitDaoMixin {
  HabitDao(super.attachedDatabase);

  Future<List<HabitRow>> getAll() {
    return (select(habits)
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
  }

  Stream<List<HabitRow>> watchAll() {
    return (select(habits)
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .watch();
  }

  Future<void> save(Habit habit) async {
    await into(habits).insertOnConflictUpdate(habit.toCompanion());
  }

  Future<void> setEnabled(String id, bool enabled) async {
    await (update(habits)..where((t) => t.id.equals(id))).write(
      HabitsCompanion(
        enabled: Value(enabled ? 1 : 0),
        updatedAt: Value(DateTime.now().toIso8601String()),
      ),
    );
  }

  /// 删除项目，可选择是否同时删除历史记录。
  Future<void> deleteHabit(String id, {required bool keepHistory}) async {
    await transaction(() async {
      if (!keepHistory) {
        final records = attachedDatabase.dailyRecords;
        await (delete(records)..where((t) => t.habitId.equals(id))).go();
      }
      await (delete(habits)..where((t) => t.id.equals(id))).go();
    });
  }

  Future<int> count() async {
    final query = selectOnly(habits)..addColumns([habits.id.count()]);
    final row = await query.getSingle();
    return row.read(habits.id.count()) ?? 0;
  }
}
