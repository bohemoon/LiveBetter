import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../backup_file_service.dart';

/// 移动端：临时文件 + 系统分享导出，系统文件选择器导入。
class LocalBackupFileService implements BackupFileService {
  @override
  bool get supported => true;

  @override
  Future<bool> shareJson(String json, {required String fileName}) async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File(p.join(dir.path, fileName));
      await file.writeAsString(json, flush: true);
      final result = await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'application/json')],
          subject: 'LiveBetter 数据备份',
        ),
      );
      return result.status != ShareResultStatus.dismissed;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<String?> pickJson() async {
    try {
      final picked = await FilePicker.pickFile(
        dialogTitle: '选择 LiveBetter 备份文件',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (picked == null) return null;
      final bytes = await picked.readAsBytes();
      return utf8.decode(bytes, allowMalformed: true);
    } catch (_) {
      return null;
    }
  }
}
