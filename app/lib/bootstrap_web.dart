import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/providers.dart';
import 'data/repositories/memory/memory_store.dart';
import 'services/noop_services.dart';

/// Web 预览使用内存数据源与空实现的原生能力。
Future<List<Override>> platformOverrides() async {
  final store = MemoryStore.seeded();
  return [
    habitRepositoryProvider.overrideWithValue(store.habitRepository),
    recordRepositoryProvider.overrideWithValue(store.recordRepository),
    settingsRepositoryProvider.overrideWithValue(store.settingsRepository),
    maintenanceRepositoryProvider.overrideWithValue(store.maintenanceRepository),
    notificationServiceProvider.overrideWithValue(NoopNotificationService()),
    authServiceProvider.overrideWithValue(NoopAuthService()),
    backgroundImageServiceProvider.overrideWithValue(
      NoopBackgroundImageService(),
    ),
    backupFileServiceProvider.overrideWithValue(NoopBackupFileService()),
  ];
}
