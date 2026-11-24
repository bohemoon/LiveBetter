/// JSON 备份文件的分享与选择能力抽象。
abstract class BackupFileService {
  /// 当前平台是否支持文件导入导出。
  bool get supported;

  /// 把 JSON 写入临时文件并拉起系统分享。
  Future<bool> shareJson(String json, {required String fileName});

  /// 选择并读取一个 JSON 文件；取消时返回 null。
  Future<String?> pickJson();
}
