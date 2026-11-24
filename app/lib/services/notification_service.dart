/// 本地通知能力抽象；Web 端使用空实现。
abstract class NotificationService {
  /// 用户点击通知时触发；应用启动时也会先补发一次。
  Stream<void> get tapStream;

  /// 初始化插件与本地时区，可重复调用。
  Future<void> initialize();

  /// 请求通知权限（Android 13+ 运行时权限），返回是否可用。
  Future<bool> requestPermission();

  /// 每天固定时间提醒一次。
  Future<void> scheduleDaily({
    required int hour,
    required int minute,
    required String body,
  });

  Future<void> cancelDaily();

  /// 周期项到期当天的一次性提醒。
  Future<void> schedulePeriodic({
    required int id,
    required String habitName,
    required String dueDate,
  });

  Future<void> cancelPeriodic();
}
