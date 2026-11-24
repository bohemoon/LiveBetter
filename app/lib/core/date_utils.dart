import 'package:intl/intl.dart';

/// 应用内统一使用设备本地时区的自然日，格式 `YYYY-MM-DD`。
final DateFormat _ymd = DateFormat('yyyy-MM-dd');

/// 格式化为 `YYYY-MM-DD`。
String formatYmd(DateTime date) => _ymd.format(date);

/// 今天的日期主键。
String todayYmd() => formatYmd(DateTime.now());

/// 当前时间 ISO 字符串，用于 `updatedAt` / `recordedAt`。
String nowIso() => DateTime.now().toIso8601String();

/// 两个日期主键是否指向不同自然日。
bool isDifferentDay(String a, String b) => a != b;

/// 解析 `YYYY-MM-DD`，失败时回退到今天。
DateTime parseYmd(String value) {
  final parsed = DateTime.tryParse(value);
  return parsed ?? DateTime.now();
}

/// 是否为合法的 `YYYY-MM-DD`。
bool isValidYmd(String value) {
  if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) return false;
  return DateTime.tryParse(value) != null;
}
