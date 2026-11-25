import 'package:flutter/services.dart';

/// 与 Android 原生交互：设备 ABI、安装授权、拉起安装器与打开链接。
class UpdateInstaller {
  const UpdateInstaller();

  static const _channel = MethodChannel('livebetter/update');

  Future<List<String>> supportedAbis() async {
    final result = await _channel.invokeListMethod<String>('supportedAbis');
    return result ?? const [];
  }

  Future<bool> canInstallPackages() async {
    final result = await _channel.invokeMethod<bool>('canInstallPackages');
    return result ?? false;
  }

  Future<void> openInstallSettings() async {
    await _channel.invokeMethod<void>('openInstallSettings');
  }

  Future<void> installApk(String path) async {
    await _channel.invokeMethod<void>('installApk', {'path': path});
  }

  Future<void> openUrl(String url) async {
    await _channel.invokeMethod<void>('openUrl', {'url': url});
  }
}
