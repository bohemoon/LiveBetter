import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// 打开应用私有目录下的 SQLite 文件。
QueryExecutor openAppConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'livebetter.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
