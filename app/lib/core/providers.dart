import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'date_utils.dart';

/// 当前"今天"的日期主键，回到前台跨日时更新以触发整页刷新。
final todayDateProvider = StateProvider<String>((ref) => todayYmd());
