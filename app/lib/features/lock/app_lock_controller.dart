import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../../domain/pin_hash.dart';
import '../profile/settings_controller.dart';

/// 应用锁状态：`true` 表示已锁定。
class AppLockController extends StateNotifier<bool> {
  AppLockController(this._ref) : super(false);

  final Ref _ref;

  AppSettingsData? get _settings =>
      _ref.read(settingsControllerProvider).valueOrNull;

  /// 仅在设置已开启应用锁时锁定。
  void lockIfEnabled() {
    if (_settings?.appLockEnabled ?? false) {
      state = true;
    }
  }

  void unlock() => state = false;

  Future<bool> biometricAvailable() =>
      _ref.read(authServiceProvider).isAvailable();

  /// 生物识别或设备凭证解锁。
  Future<bool> unlockWithBiometrics() async {
    if (!(_settings?.appLockEnabled ?? false)) {
      state = false;
      return true;
    }
    final ok = await _ref
        .read(authServiceProvider)
        .authenticate(reason: '解锁 LiveBetter');
    if (ok) state = false;
    return ok;
  }

  /// 4 位密码校验，通过后解锁。
  bool verifyPin(String pin) {
    final settings = _settings;
    if (settings == null || settings.pinHash == null) return false;
    if (hashPin(pin) == settings.pinHash) {
      state = false;
      return true;
    }
    return false;
  }

  /// 生物识别不可用时的临时关闭入口。
  Future<void> disableLock() async {
    await _ref.read(settingsControllerProvider.notifier).setAppLock(false);
    state = false;
  }
}

final appLockControllerProvider =
    StateNotifierProvider<AppLockController, bool>(AppLockController.new);
