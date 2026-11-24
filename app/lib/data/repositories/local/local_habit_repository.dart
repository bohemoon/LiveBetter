import '../../db/daos/habit_dao.dart';
import '../../models/models.dart';
import '../habit_repository.dart';

class LocalHabitRepository implements HabitRepository {
  LocalHabitRepository(this._dao);

  final HabitDao _dao;

  @override
  Future<List<Habit>> getAll() async {
    final rows = await _dao.getAll();
    return rows.map(Habit.fromRow).toList(growable: false);
  }

  @override
  Stream<List<Habit>> watchAll() {
    return _dao.watchAll().map(
          (rows) => rows.map(Habit.fromRow).toList(growable: false),
        );
  }

  @override
  Future<List<Habit>> getEnabled() async {
    final habits = await getAll();
    return habits.where((habit) => habit.enabled).toList(growable: false);
  }

  @override
  Future<void> save(Habit habit) => _dao.save(habit);

  @override
  Future<void> setEnabled(String id, bool enabled) => _dao.setEnabled(id, enabled);

  @override
  Future<void> delete(String id, {required bool keepHistory}) =>
      _dao.deleteHabit(id, keepHistory: keepHistory);
}
