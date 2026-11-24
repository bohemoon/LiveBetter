import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../profile/settings_controller.dart';
import 'app_lock_controller.dart';
import 'lock_page.dart';

/// 在应用启动与回前台时锁定，并在锁定时覆盖全屏解锁页。
class AppLockGate extends ConsumerStatefulWidget {
  const AppLockGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends ConsumerState<AppLockGate> {
  late final AppLifecycleListener _listener;
  bool _seeded = false;

  @override
  void initState() {
    super.initState();
    _listener = AppLifecycleListener(onResume: _lockIfEnabled);
  }

  void _lockIfEnabled() {
    ref.read(appLockControllerProvider.notifier).lockIfEnabled();
  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider).valueOrNull;
    final locked = ref.watch(appLockControllerProvider);
    if (!_seeded && settings != null) {
      _seeded = true;
      if (settings.appLockEnabled) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _lockIfEnabled();
        });
      }
    }

    if (!locked || !(settings?.appLockEnabled ?? false)) {
      return widget.child;
    }
    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {},
            child: const LockPage(),
          ),
        ),
      ],
    );
  }
}
