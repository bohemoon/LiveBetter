import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../data/models/models.dart';
import '../profile/settings_controller.dart';
import '../today/today_providers.dart';
import 'reminder_scheduler.dart';

/// 监听设置与数据变化，按签名去重后重新安排通知。
class NotificationSync extends ConsumerStatefulWidget {
  const NotificationSync({super.key});

  @override
  ConsumerState<NotificationSync> createState() => _NotificationSyncState();
}

class _NotificationSyncState extends ConsumerState<NotificationSync> {
  String? _lastSignature;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider).valueOrNull;
    final habits = ref.watch(habitsProvider).valueOrNull;
    final records = ref.watch(allRecordsProvider).valueOrNull;
    final today = ref.watch(todayDateProvider);
    if (settings == null || habits == null || records == null) {
      return const SizedBox.shrink();
    }

    final habitsSignature = habits
        .map((habit) => '${habit.id}:${habit.name}:${habit.enabled}:'
            '${habit.type.name}:${habit.intervalDays}')
        .join(',');
    final recordsSignature = records
        .where((record) => record.date == today ||
            record.status == RecordStatus.success)
        .map((record) => '${record.habitId}:${record.date}:'
            '${record.status?.value}:${record.amount}')
        .join(',');
    final signature = [
      today,
      settings.reminderEnabled,
      settings.reminderTime,
      settings.periodicReminderEnabled,
      settings.strictMode,
      habitsSignature,
      recordsSignature,
    ].join('|');

    if (signature != _lastSignature) {
      _lastSignature = signature;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(reminderSchedulerProvider).sync(
              settings: settings,
              habits: habits,
              records: records,
              today: today,
            );
      });
    }
    return const SizedBox.shrink();
  }
}
