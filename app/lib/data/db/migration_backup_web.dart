/// Web 预览不落盘，也没有数据库迁移。
Future<void> writePreMigrationBackup({
  required int fromVersion,
  required Map<String, dynamic> data,
}) async {}
