import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../notification_service.dart';

/// 基于 flutter_local_notifications 的移动端实现。
class LocalNotificationService implements NotificationService {
  LocalNotificationService();

  static const int _dailyId = 1001;
  static const int _periodicBaseId = 2100;
  static const String _dailyChannel = 'daily_reminder';
  static const String _periodicChannel = 'periodic_reminder';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final StreamController<void> _taps = StreamController<void>.broadcast();
  Future<void>? _initFuture;

  @override
  Stream<void> get tapStream => _taps.stream;

  @override
  Future<void> initialize() {
    return _initFuture ??= _initialize();
  }

  Future<void> _initialize() async {
    try {
      tzdata.initializeTimeZones();
      try {
        final info = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(info.identifier));
      } catch (_) {
        tz.setLocalLocation(tz.getLocation('Asia/Shanghai'));
      }
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      await _plugin.initialize(
        const InitializationSettings(android: android),
        onDidReceiveNotificationResponse: (_) => _taps.add(null),
      );
      // 从通知冷启动时也回到今日页。
      final launch = await _plugin.getNotificationAppLaunchDetails();
      if (launch?.didNotificationLaunchApp ?? false) {
        _taps.add(null);
      }
    } catch (_) {
      // 通知初始化失败不影响应用启动，后续调度会再次尝试。
      _initFuture = null;
    }
  }

  @override
  Future<bool> requestPermission() async {
    await initialize();
    try {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      final granted = await android?.requestNotificationsPermission();
      return granted ?? true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> scheduleDaily({
    required int hour,
    required int minute,
    required String body,
  }) async {
    await initialize();
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return;
    try {
      final now = tz.TZDateTime.now(tz.local);
      var scheduled =
          tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
      if (!scheduled.isAfter(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }
      await _plugin.zonedSchedule(
        _dailyId,
        'LiveBetter',
        body,
        scheduled,
        _details(
          channelId: _dailyChannel,
          channelName: '每日提醒',
          channelDescription: '每天固定时间提醒尚未完成的打卡项',
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (_) {
      // 权限缺失或系统限制时静默跳过。
    }
  }

  @override
  Future<void> cancelDaily() async {
    await initialize();
    try {
      await _plugin.cancel(_dailyId);
    } catch (_) {}
  }

  @override
  Future<void> schedulePeriodic({
    required int id,
    required String habitName,
    required String dueDate,
  }) async {
    await initialize();
    final date = DateTime.tryParse(dueDate);
    if (date == null) return;
    try {
      final scheduled = tz.TZDateTime(
        tz.local,
        date.year,
        date.month,
        date.day,
        9,
      );
      if (!scheduled.isAfter(tz.TZDateTime.now(tz.local))) return;
      await _plugin.zonedSchedule(
        _periodicBaseId + id,
        '到期提醒',
        '「$habitName」今天到期，方便时完成即可',
        scheduled,
        _details(
          channelId: _periodicChannel,
          channelName: '周期到期提醒',
          channelDescription: '周期项到期当天提醒一次',
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (_) {}
  }

  @override
  Future<void> cancelPeriodic() async {
    await initialize();
    try {
      final pending = await _plugin.pendingNotificationRequests();
      for (final item in pending) {
        if (item.id >= _periodicBaseId) {
          await _plugin.cancel(item.id);
        }
      }
    } catch (_) {}
  }

  NotificationDetails _details({
    required String channelId,
    required String channelName,
    required String channelDescription,
  }) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
    );
  }
}
