import 'dart:io';

import 'package:flutter/painting.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../background_image_service.dart';

/// 相册选图 + 压缩到 300KB 以内，存到应用私有目录。
class LocalBackgroundImageService implements BackgroundImageService {
  static const int _maxBytes = 300 * 1024;

  Directory? _dir;

  @override
  bool get supported => true;

  Future<Directory> _ensureDir() async {
    final cached = _dir;
    if (cached != null) return cached;
    final documents = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(documents.path, 'backgrounds'));
    await dir.create(recursive: true);
    _dir = dir;
    return dir;
  }

  /// 启动时预创建目录，避免首屏读取背景图时抖动。
  Future<void> initialize() async {
    try {
      await _ensureDir();
    } catch (_) {}
  }

  @override
  ImageProvider? providerFor(String? relativePath) {
    final dir = _dir;
    if (dir == null || relativePath == null || relativePath.isEmpty) {
      return null;
    }
    final file = File(p.join(dir.path, relativePath));
    return file.existsSync() ? FileImage(file) : null;
  }

  @override
  Future<String?> pick(String habitId) async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
      );
      if (picked == null) return null;
      final dir = await _ensureDir();
      final target = p.join(dir.path, '$habitId.jpg');

      for (final quality in [82, 68, 52, 36]) {
        final result = await FlutterImageCompress.compressAndGetFile(
          picked.path,
          target,
          quality: quality,
          minWidth: 1080,
          minHeight: 1080,
          format: CompressFormat.jpeg,
        );
        if (result == null) continue;
        final file = File(result.path);
        if (await file.length() <= _maxBytes) {
          return p.basename(result.path);
        }
      }
      // 压缩后仍超过 300KB，放弃本次选择。
      final fallback = File(target);
      if (await fallback.exists()) {
        await fallback.delete();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> remove(String habitId) async {
    final dir = _dir;
    if (dir == null) return;
    try {
      await for (final entity in dir.list()) {
        if (entity is File && p.basename(entity.path).startsWith('$habitId.')) {
          await entity.delete();
        }
      }
    } catch (_) {}
  }
}
