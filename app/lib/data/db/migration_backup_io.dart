import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// 迁移前把旧版数据导出为 JSON，保留最近 3 份。
///
/// 迁移过程中读表的原始数据由调用方传入，避免引用新版表结构。
Future<void> writePreMigrationBackup({
  required int fromVersion,
  required Map<String, dynamic> data,
}) async {
  try {
    final documents = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(documents.path, 'backups'));
    await dir.create(recursive: true);
    final stamp = _stamp(DateTime.now());
    final file = File(
      p.join(dir.path, 'pre_migration_v${fromVersion}_$stamp.json'),
    );
    await file.writeAsString(jsonEncode(data));
    final backups = await dir
        .list()
        .where((entity) =>
            entity is File &&
            p.basename(entity.path).startsWith('pre_migration_'))
        .cast<File>()
        .toList();
    backups.sort((a, b) => b.path.compareTo(a.path));
    for (final old in backups.skip(3)) {
      try {
        await old.delete();
      } catch (_) {}
    }
  } catch (_) {
    // 备份失败不阻塞迁移。
  }
}

String _stamp(DateTime time) {
  String two(int value) => value.toString().padLeft(2, '0');
  return '${time.year}${two(time.month)}${two(time.day)}'
      '_${two(time.hour)}${two(time.minute)}${two(time.second)}';
}
