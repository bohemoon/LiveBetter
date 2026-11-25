import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/providers.dart';
import '../features/lock/app_lock_gate.dart';
import '../features/notifications/notification_sync.dart';
import '../features/profile/settings_controller.dart';
import 'router.dart';
import 'theme.dart';

class LiveBetterApp extends ConsumerStatefulWidget {
  const LiveBetterApp({super.key});

  @override
  ConsumerState<LiveBetterApp> createState() => _LiveBetterAppState();
}

class _LiveBetterAppState extends ConsumerState<LiveBetterApp> {
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();
  StreamSubscription<void>? _tapSubscription;

  @override
  void initState() {
    super.initState();
    _tapSubscription = ref
        .read(notificationServiceProvider)
        .tapStream
        .listen((_) => appRouter.go('/today'));
    WidgetsBinding.instance.addPostFrameCallback((_) => _autoCheckUpdate());
  }

  /// 启动后静默检查更新（24 小时最多一次），失败不打扰用户。
  Future<void> _autoCheckUpdate() async {
    try {
      final service = ref.read(updateServiceProvider);
      if (!await service.shouldAutoCheck()) return;
      final info = await service.checkForUpdate();
      if (info == null) return;
      _messengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('发现新版本 v${info.version}，可在 我的 → 设置 中更新')),
      );
    } catch (_) {
      // 网络异常或限流时静默跳过。
    }
  }

  @override
  void dispose() {
    _tapSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(appThemeProvider);
    return MaterialApp.router(
      title: 'LiveBetter',
      scaffoldMessengerKey: _messengerKey,
      debugShowCheckedModeBanner: false,
      theme: buildTheme(theme),
      routerConfig: appRouter,
      builder: (context, child) {
        return AppLockGate(
          child: Stack(
            children: [
              Positioned.fill(
                child: child ?? const SizedBox.shrink(),
              ),
              const NotificationSync(),
            ],
          ),
        );
      },
    );
  }
}
