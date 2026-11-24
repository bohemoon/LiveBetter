import 'package:flutter/painting.dart';

import 'auth_service.dart';
import 'background_image_service.dart';
import 'backup_file_service.dart';
import 'notification_service.dart';

/// Web 预览没有系统通知。
class NoopNotificationService implements NotificationService {
  @override
  Stream<void> get tapStream => const Stream<void>.empty();

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<void> scheduleDaily({
    required int hour,
    required int minute,
    required String body,
  }) async {}

  @override
  Future<void> cancelDaily() async {}

  @override
  Future<void> schedulePeriodic({
    required int id,
    required String habitName,
    required String dueDate,
  }) async {}

  @override
  Future<void> cancelPeriodic() async {}
}

/// Web 预览不支持生物识别。
class NoopAuthService implements AuthService {
  @override
  Future<bool> isAvailable() async => false;

  @override
  Future<bool> authenticate({required String reason}) async => false;
}

/// Web 预览不支持选择卡片背景。
class NoopBackgroundImageService implements BackgroundImageService {
  @override
  bool get supported => false;

  @override
  ImageProvider? providerFor(String? relativePath) => null;

  @override
  Future<String?> pick(String habitId) async => null;

  @override
  Future<void> remove(String habitId) async {}
}

/// Web 预览不支持文件分享与选择。
class NoopBackupFileService implements BackupFileService {
  @override
  bool get supported => false;

  @override
  Future<bool> shareJson(String json, {required String fileName}) async => false;

  @override
  Future<String?> pickJson() async => null;
}
