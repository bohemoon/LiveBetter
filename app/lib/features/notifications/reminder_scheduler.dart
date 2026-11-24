import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../../domain/reminders.dart';
import '../../domain/stats/habit_stats.dart';
import '../../services/notification_service.dart';

/// 按设置与数据变化重新安排通知：每日提醒 + 周期项到期提醒。
class ReminderScheduler {
  ReminderScheduler(this._notifications);

  final NotificationService _notifications;

  Future<void> sync({
    required AppSettingsData settings,
    required List<Habit> habits,
    required List<DailyRecord> records,
    required String today,
  }) async {
    if (settings.reminderEnabled) {
      final pending = pendingReminderHabits(
        habits: habits,
        records: records,
        today: today,
      );
      final body = pending.isEmpty
          ? '今天可以慢一点，按自己的节奏来'
          : '今天还有 ${pending.length} 项可以稍后完成，按自己的节奏来';
      final parts = settings.reminderTime.split(':');
      final hour = int.tryParse(parts.first) ?? 22;
      final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 45 : 45;
      await _notifications.scheduleDaily(
        hour: hour,
        minute: minute,
        body: body,
      );
    } else {
      await _notifications.cancelDaily();
    }

    await _notifications.cancelPeriodic();
    if (!settings.periodicReminderEnabled) return;

    final periodic = habits
        .where((habit) => habit.enabled && habit.type == HabitType.periodic)
        .toList(growable: false);
    for (var index = 0; index < periodic.length; index++) {
      final habit = periodic[index];
      final stats = computeHabitStats(
        habit: habit,
        records: records,
        today: today,
        strictMode: settings.strictMode,
      );
      var dueDate = stats.nextDueDate;
      if (dueDate == null) continue;
      if (dueDate.compareTo(today) < 0) dueDate = today;
      await _notifications.schedulePeriodic(
        id: index,
        habitName: habit.name,
        dueDate: dueDate,
      );
    }
  }
}

final reminderSchedulerProvider = Provider<ReminderScheduler>(
  (ref) => ReminderScheduler(ref.watch(notificationServiceProvider)),
);
