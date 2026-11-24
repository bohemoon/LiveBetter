/// 生物识别 / 设备凭证能力抽象。
abstract class AuthService {
  /// 设备是否支持生物识别或设备凭证。
  Future<bool> isAvailable();

  /// 拉起系统认证，返回是否通过。
  Future<bool> authenticate({required String reason});
}
