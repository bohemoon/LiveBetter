import 'package:flutter/painting.dart';

/// 卡片背景图能力抽象。
abstract class BackgroundImageService {
  /// 当前平台是否支持选图。
  bool get supported;

  /// 按相对文件名解析本地图片；不存在时返回 null。
  ImageProvider? providerFor(String? relativePath);

  /// 从相册选图并压缩保存，返回相对文件名；取消时返回 null。
  Future<String?> pick(String habitId);

  /// 删除某项目已保存的背景图。
  Future<void> remove(String habitId);
}
