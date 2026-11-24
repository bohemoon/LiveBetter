import 'dart:convert';

import 'package:crypto/crypto.dart';

const String _pinSalt = 'livebetter:pin:';

/// 应用锁密码只保存加盐哈希，不落明文。
String hashPin(String pin) => sha256.convert(utf8.encode('$_pinSalt$pin')).toString();
