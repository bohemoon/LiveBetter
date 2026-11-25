import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/date_utils.dart';
import '../core/providers.dart';
import '../features/profile/habit_editor_page.dart';
import '../features/profile/profile_page.dart';
import '../features/profile/settings_page.dart';
import '../features/records/records_page.dart';
import '../features/today/habit_detail_page.dart';
import '../features/today/habit_history_page.dart';
import '../features/today/today_page.dart';

/// 三 Tab 外壳 + 详情页路由。
final GoRouter appRouter = GoRouter(
  initialLocation: '/today',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/today',
              builder: (context, state) => const TodayPage(),
              routes: [
                GoRoute(
                  path: 'habit/:id',
                  builder: (context, state) {
                    return HabitDetailPage(habitId: state.pathParameters['id']!);
                  },
                  routes: [
                    GoRoute(
                      path: 'history',
                      builder: (context, state) {
                        return HabitHistoryPage(
                          habitId: state.pathParameters['id']!,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/records',
              builder: (context, state) => const RecordsPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfilePage(),
              routes: [
                GoRoute(
                  path: 'settings',
                  builder: (context, state) => const SettingsPage(),
                ),
                GoRoute(
                  path: 'habit/new',
                  builder: (context, state) => const HabitEditorPage(),
                ),
                GoRoute(
                  path: 'habit/:id/edit',
                  builder: (context, state) {
                    return HabitEditorPage(
                      habitId: state.pathParameters['id'],
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);

/// 底部导航外壳，同时负责回前台跨日检测。
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(
      onResume: () => _refreshToday(),
    );
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  /// 回到前台时若已跨日，重置"今天"以触发整页数据刷新。
  void _refreshToday() {
    final current = ref.read(todayDateProvider);
    final actual = todayYmd();
    if (isDifferentDay(current, actual)) {
      ref.read(todayDateProvider.notifier).state = actual;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: widget.navigationShell.currentIndex,
        onDestinationSelected: (index) {
          widget.navigationShell.goBranch(
            index,
            initialLocation: index == widget.navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.wb_sunny_outlined),
            selectedIcon: Icon(Icons.wb_sunny),
            label: '今日',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            selectedIcon: Icon(Icons.event_note),
            label: '记录',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    );
  }
}
