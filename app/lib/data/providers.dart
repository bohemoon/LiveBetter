import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_service.dart';
import '../services/background_image_service.dart';
import '../services/backup_file_service.dart';
import '../services/notification_service.dart';
import '../services/update_installer.dart';
import '../services/update_service.dart';
import 'repositories/habit_repository.dart';
import 'repositories/maintenance_repository.dart';
import 'repositories/record_repository.dart';
import 'repositories/settings_repository.dart';

/// 仓库由平台入口（`bootstrap_io`）注入实例。
final habitRepositoryProvider = Provider<HabitRepository>(
  (ref) => throw UnimplementedError('habitRepositoryProvider 必须在启动时覆盖'),
);

final recordRepositoryProvider = Provider<RecordRepository>(
  (ref) => throw UnimplementedError('recordRepositoryProvider 必须在启动时覆盖'),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => throw UnimplementedError('settingsRepositoryProvider 必须在启动时覆盖'),
);

final maintenanceRepositoryProvider = Provider<MaintenanceRepository>(
  (ref) => throw UnimplementedError('maintenanceRepositoryProvider 必须在启动时覆盖'),
);

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => throw UnimplementedError('notificationServiceProvider 必须在启动时覆盖'),
);

final authServiceProvider = Provider<AuthService>(
  (ref) => throw UnimplementedError('authServiceProvider 必须在启动时覆盖'),
);

final backgroundImageServiceProvider = Provider<BackgroundImageService>(
  (ref) => throw UnimplementedError('backgroundImageServiceProvider 必须在启动时覆盖'),
);

final backupFileServiceProvider = Provider<BackupFileService>(
  (ref) => throw UnimplementedError('backupFileServiceProvider 必须在启动时覆盖'),
);

/// 应用内更新：检查、下载与校验。
final updateServiceProvider = Provider<UpdateService>((ref) => UpdateService());

/// 应用内更新：拉起系统安装器。
final updateInstallerProvider = Provider<UpdateInstaller>(
  (ref) => const UpdateInstaller(),
);
