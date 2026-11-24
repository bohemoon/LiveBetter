// 按平台选择 SQLite 连接实现：移动端用文件，Web 端在预览中不使用。
export 'connection_io.dart' if (dart.library.js_interop) 'connection_web.dart';
