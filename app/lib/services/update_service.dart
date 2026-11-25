import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

/// 可用的版本更新信息。
class AppUpdateInfo {
  const AppUpdateInfo({
    required this.version,
    required this.notes,
    required this.apkUrl,
    required this.sha256Url,
    required this.sizeBytes,
  });

  final String version;
  final String notes;
  final String apkUrl;
  final String sha256Url;
  final int sizeBytes;
}

/// 更新检查、下载与校验失败时抛出，message 可直接展示给用户。
class UpdateException implements Exception {
  const UpdateException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// 基于 GitHub Releases 的更新服务，仅访问公开接口。
class UpdateService {
  UpdateService({HttpClient? client}) : _client = client ?? HttpClient();

  static const repo = 'bohemoon/LiveBetter';
  static const _maxApkBytes = 120 * 1024 * 1024;
  static const _allowedHosts = {
    'api.github.com',
    'github.com',
    'objects.githubusercontent.com',
    'release-assets.githubusercontent.com',
  };

  final HttpClient _client;

  /// 检查是否有新版本，无更新或 Release 缺少 APK 时返回 null。
  Future<AppUpdateInfo?> checkForUpdate() async {
    final package = await PackageInfo.fromPlatform();
    final json = await _getJson(
      Uri.parse('https://api.github.com/repos/$repo/releases/latest'),
    );
    return parseRelease(json, currentVersion: package.version);
  }

  /// 24 小时内只自动检查一次。
  Future<bool> shouldAutoCheck() async {
    try {
      final dir = await getApplicationSupportDirectory();
      final file = File('${dir.path}/last_update_check');
      final now = DateTime.now().millisecondsSinceEpoch;
      if (await file.exists()) {
        final last = int.tryParse(await file.readAsString()) ?? 0;
        if (now - last < const Duration(hours: 24).inMilliseconds) {
          return false;
        }
      }
      await file.writeAsString('$now');
      return true;
    } catch (_) {
      return true;
    }
  }

  /// 下载 APK 到缓存目录，返回本地文件。
  Future<File> download(
    AppUpdateInfo info, {
    void Function(int received, int total)? onProgress,
  }) async {
    _assertAllowed(info.apkUrl);
    final dir = Directory('${(await getTemporaryDirectory()).path}/updates');
    await dir.create(recursive: true);
    final file = File('${dir.path}/LiveBetter-${info.version}.apk');
    if (await file.exists()) await file.delete();

    final request = await _client.getUrl(Uri.parse(info.apkUrl));
    request.headers.set(HttpHeaders.userAgentHeader, 'LiveBetter');
    final response = await request.close();
    if (response.statusCode != HttpStatus.ok) {
      throw UpdateException('下载失败（${response.statusCode}），请稍后重试');
    }

    final total = response.contentLength > 0 ? response.contentLength : info.sizeBytes;
    if (total > _maxApkBytes) {
      throw const UpdateException('安装包大小异常，请前往发布页下载');
    }

    final sink = file.openWrite();
    var received = 0;
    try {
      await for (final chunk in response) {
        received += chunk.length;
        if (received > _maxApkBytes) {
          throw const UpdateException('安装包大小异常，请前往发布页下载');
        }
        sink.add(chunk);
        onProgress?.call(received, total);
      }
    } catch (_) {
      await sink.flush();
      await sink.close();
      await file.delete().catchError((_) => file);
      rethrow;
    }
    await sink.close();
    return file;
  }

  /// 校验下载文件的 SHA256，失败时删除文件。
  Future<void> verify(AppUpdateInfo info, File apk) async {
    _assertAllowed(info.sha256Url);
    final response = await _getText(Uri.parse(info.sha256Url));
    final expected = parseSha256(response);
    if (expected == null) {
      await apk.delete().catchError((_) => apk);
      throw const UpdateException('校验文件格式异常，请前往发布页下载');
    }
    final actual = await sha256.bind(apk.openRead()).first;
    if (actual.toString() != expected) {
      await apk.delete().catchError((_) => apk);
      throw const UpdateException('安装包校验失败，请重试');
    }
  }

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    final body = await _getText(uri);
    try {
      final json = jsonDecode(body);
      if (json is Map<String, dynamic>) return json;
    } catch (_) {
      // 落到统一错误
    }
    throw const UpdateException('更新信息解析失败，请稍后重试');
  }

  Future<String> _getText(Uri uri) async {
    if (uri.scheme != 'https' || !_allowedHosts.contains(uri.host)) {
      throw const UpdateException('更新地址不受信任');
    }
    try {
      final request = await _client
          .getUrl(uri)
          .timeout(const Duration(seconds: 10));
      request.headers.set(HttpHeaders.userAgentHeader, 'LiveBetter');
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      final response =
          await request.close().timeout(const Duration(seconds: 15));
      final body = await response.transform(utf8.decoder).join();
      if (response.statusCode == HttpStatus.forbidden) {
        throw const UpdateException('检查更新过于频繁，请稍后再试或前往 Releases 页');
      }
      if (response.statusCode != HttpStatus.ok) {
        throw UpdateException('请求失败（${response.statusCode}），请稍后重试');
      }
      return body;
    } on UpdateException {
      rethrow;
    } on TimeoutException {
      throw const UpdateException('网络超时，请稍后重试');
    } on SocketException {
      throw const UpdateException('网络不可用，请检查网络后重试');
    }
  }

  void _assertAllowed(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null ||
        uri.scheme != 'https' ||
        !_allowedHosts.contains(uri.host)) {
      throw const UpdateException('更新地址不受信任');
    }
  }
}

/// 解析 GitHub Release，仅当远端版本高于当前版本时返回更新信息。
AppUpdateInfo? parseRelease(
  Map<String, dynamic> json, {
  required String currentVersion,
}) {
  final tag = json['tag_name'];
  if (tag is! String) return null;
  final version = normalizeVersion(tag);
  if (version == null) return null;
  if (compareVersions(version, normalizeVersion(currentVersion) ?? currentVersion) <= 0) {
    return null;
  }

  final assets = json['assets'];
  if (assets is! List) return null;
  Map<String, dynamic>? apk;
  for (final item in assets) {
    if (item is! Map) continue;
    final name = item['name'];
    if (name is! String || !name.endsWith('.apk') || !name.contains('arm64')) {
      continue;
    }
    apk = item.cast<String, dynamic>();
    break;
  }
  if (apk == null) return null;

  final apkUrl = apk['browser_download_url'];
  final apkName = apk['name'];
  if (apkUrl is! String || apkName is! String) return null;

  String? shaUrl;
  for (final item in assets) {
    if (item is! Map) continue;
    if (item['name'] == '$apkName.sha256') {
      shaUrl = item['browser_download_url'] as String?;
      break;
    }
  }
  if (shaUrl == null) return null;

  return AppUpdateInfo(
    version: version,
    notes: (json['body'] as String? ?? '').trim(),
    apkUrl: apkUrl,
    sha256Url: shaUrl,
    sizeBytes: (apk['size'] as num?)?.toInt() ?? 0,
  );
}

/// 去掉前缀 v，补足三段，返回规范的 x.y.z；非法返回 null。
String? normalizeVersion(String raw) {
  final text = raw.trim().replaceFirst(RegExp(r'^[vV]'), '');
  if (!RegExp(r'^\d+(\.\d+){0,2}$').hasMatch(text)) return null;
  final parts = text.split('.').map(int.parse).toList();
  while (parts.length < 3) {
    parts.add(0);
  }
  return parts.join('.');
}

/// 语义化比较，a > b 返回 1，相等返回 0，a < b 返回 -1。
int compareVersions(String a, String b) {
  final left = normalizeVersion(a)?.split('.').map(int.parse).toList() ?? [0];
  final right = normalizeVersion(b)?.split('.').map(int.parse).toList() ?? [0];
  for (var i = 0; i < 3; i++) {
    final x = i < left.length ? left[i] : 0;
    final y = i < right.length ? right[i] : 0;
    if (x != y) return x > y ? 1 : -1;
  }
  return 0;
}

/// 解析 sha256sum 文件，返回 64 位十六进制摘要。
String? parseSha256(String content) {
  final match = RegExp(r'^([0-9a-fA-F]{64})\s').firstMatch(content.trim());
  return match?.group(1)?.toLowerCase();
}
