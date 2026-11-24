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
  StreamSubscription<void>? _tapSubscription;

  @override
  void initState() {
    super.initState();
    _tapSubscription = ref
        .read(notificationServiceProvider)
        .tapStream
        .listen((_) => appRouter.go('/today'));
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
