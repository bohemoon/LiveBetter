import '../models/models.dart';

/// 应用设置仓库接口。
abstract class SettingsRepository {
  Future<AppSettingsData> get();

  Stream<AppSettingsData> watch();

  Future<void> save(AppSettingsData settings);
}
