import 'package:drift/drift.dart';

/// Web 预览使用内存数据源，不会真正打开数据库。
QueryExecutor openAppConnection() {
  throw UnsupportedError('Web 预览已使用内存数据源，无需打开 SQLite');
}
