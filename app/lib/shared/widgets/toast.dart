import 'package:material_ui/material_ui.dart';

/// 轻提示统一封装，避免各页面直接操作 SnackBar。
class Toast {
  Toast._();

  static void show(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      );
  }
}
