import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/db/database.dart';
import 'data/providers.dart';
import 'data/repositories/local/local_habit_repository.dart';
import 'data/repositories/local/local_maintenance_repository.dart';
import 'data/repositories/local/local_record_repository.dart';
import 'data/repositories/local/local_settings_repository.dart';
import 'services/local/local_auth_service.dart';
import 'services/local/local_background_image_service.dart';
import 'services/local/local_backup_file_service.dart';
import 'services/local/local_notification_service.dart';

/// 移动端使用 SQLite 本地仓库与系统原生能力。
Future<List<Override>> platformOverrides() async {
  final database = AppDatabase.open();
  final notifications = LocalNotificationService();
  await notifications.initialize();
  final images = LocalBackgroundImageService();
  await images.initialize();
  return [
    habitRepositoryProvider.overrideWithValue(
      LocalHabitRepository(database.habitDao),
    ),
    recordRepositoryProvider.overrideWithValue(
      LocalRecordRepository(database.recordDao),
    ),
    settingsRepositoryProvider.overrideWithValue(
      LocalSettingsRepository(database.settingsDao),
    ),
    maintenanceRepositoryProvider.overrideWithValue(
      LocalMaintenanceRepository(database),
    ),
    notificationServiceProvider.overrideWithValue(notifications),
    authServiceProvider.overrideWithValue(LocalAuthService()),
    backgroundImageServiceProvider.overrideWithValue(images),
    backupFileServiceProvider.overrideWithValue(LocalBackupFileService()),
  ];
}
