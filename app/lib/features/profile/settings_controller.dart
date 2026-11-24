import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../../domain/pin_hash.dart';

/// 设置状态：启动时从仓库装载，修改后立即生效并落库。
class SettingsController extends AsyncNotifier<AppSettingsData> {
  @override
  Future<AppSettingsData> build() {
    return ref.read(settingsRepositoryProvider).get();
  }

  Future<void> setTheme(AppTheme theme) {
    final current = state.valueOrNull;
    if (current == null || current.theme == theme.name) return Future.value();
    return _persist(current.copyWith(theme: theme.name));
  }

  Future<void> setReminderEnabled(bool enabled) {
    final current = state.valueOrNull;
    if (current == null) return Future.value();
    return _persist(current.copyWith(reminderEnabled: enabled));
  }

  Future<void> setHideSensitiveNames(bool hide) {
    final current = state.valueOrNull;
    if (current == null) return Future.value();
    return _persist(current.copyWith(hideSensitiveNames: hide));
  }

  Future<void> setStrictMode(bool strict) {
    final current = state.valueOrNull;
    if (current == null) return Future.value();
    return _persist(current.copyWith(strictMode: strict));
  }

  Future<void> setReminderTime(String time) {
    final current = state.valueOrNull;
    if (current == null) return Future.value();
    return _persist(current.copyWith(reminderTime: time));
  }

  Future<void> setPeriodicReminderEnabled(bool enabled) {
    final current = state.valueOrNull;
    if (current == null) return Future.value();
    return _persist(current.copyWith(periodicReminderEnabled: enabled));
  }

  /// 开启应用锁并保存加盐哈希；关闭时清除哈希。
  Future<void> setAppLock(bool enabled, {String? pin}) {
    final current = state.valueOrNull;
    if (current == null) return Future.value();
    if (!enabled) {
      return _persist(current.copyWith(appLockEnabled: false, clearPinHash: true));
    }
    if (pin == null || pin.length != 4) return Future.value();
    return _persist(current.copyWith(
      appLockEnabled: true,
      pinHash: hashPin(pin),
    ));
  }

  Future<void> setPeriodEnabled(bool enabled) {
    final current = state.valueOrNull;
    if (current == null) return Future.value();
    return _persist(current.copyWith(periodEnabled: enabled));
  }

  Future<void> savePeriod({
    required String start,
    required int periodLength,
    required int cycleLength,
  }) {
    final current = state.valueOrNull;
    if (current == null) return Future.value();
    return _persist(current.copyWith(
      periodEnabled: true,
      periodStart: start,
      periodLength: periodLength,
      cycleLength: cycleLength,
    ));
  }

  Future<void> _persist(AppSettingsData updated) async {
    state = AsyncData(updated);
    await ref.read(settingsRepositoryProvider).save(updated);
  }
}

final settingsControllerProvider =
    AsyncNotifierProvider<SettingsController, AppSettingsData>(SettingsController.new);

/// 当前主题，设置变化后即时重建。
final appThemeProvider = Provider<AppTheme>((ref) {
  final settings = ref.watch(settingsControllerProvider).valueOrNull;
  return AppTheme.parse(settings?.theme);
});
