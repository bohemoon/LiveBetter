import '../../../core/constants.dart';
import '../../db/daos/settings_dao.dart';
import '../../models/models.dart';
import '../settings_repository.dart';

class LocalSettingsRepository implements SettingsRepository {
  LocalSettingsRepository(this._dao);

  final SettingsDao _dao;

  static const AppSettingsData _fallback = AppSettingsData(
    strictMode: DefaultSettings.strictMode,
    reminderEnabled: DefaultSettings.reminderEnabled,
    reminderTime: DefaultSettings.reminderTime,
    hideSensitiveNames: DefaultSettings.hideSensitiveNames,
    appLockEnabled: DefaultSettings.appLockEnabled,
    gender: DefaultSettings.gender,
    theme: DefaultSettings.theme,
    periodEnabled: DefaultSettings.periodEnabled,
    periodLength: DefaultSettings.periodLength,
    cycleLength: DefaultSettings.cycleLength,
  );

  @override
  Future<AppSettingsData> get() async {
    final row = await _dao.find();
    return row == null ? _fallback : AppSettingsData.fromRow(row);
  }

  @override
  Stream<AppSettingsData> watch() {
    return _dao.watchSingle().map(
          (row) => row == null ? _fallback : AppSettingsData.fromRow(row),
        );
  }

  @override
  Future<void> save(AppSettingsData settings) => _dao.save(settings);
}
