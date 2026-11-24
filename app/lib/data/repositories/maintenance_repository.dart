/// 导入结果统计。
class ImportSummary {
  const ImportSummary({
    required this.habits,
    required this.records,
    required this.skippedHabits,
    required this.skippedRecords,
  });

  final int habits;
  final int records;
  final int skippedHabits;
  final int skippedRecords;
}

/// 数据维护入口：演示数据、清除全部数据、JSON 导入导出。
abstract class MaintenanceRepository {
  /// 填充最近 34 天演示记录。
  Future<void> seedDemoData();

  /// 清空记录与项目并恢复默认 5 项与默认设置。
  Future<void> clearAllData();

  /// 导出为 JSON 字符串，图片与 PIN 不进入备份。
  Future<String> exportJson();

  /// 校验并整库覆盖导入；失败抛出 [BackupException]。
  Future<ImportSummary> importJson(String source);
}
