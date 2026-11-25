import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../data/backup/backup_codec.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';
import '../../shared/widgets/app_bottom_sheet.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/segmented_control.dart';
import '../../shared/widgets/switch_row.dart';
import '../../shared/widgets/toast.dart';
import 'profile_common.dart';
import 'settings_controller.dart';

/// 设置页：隐私、外观与数据管理。
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: settingsAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        error: (error, _) => Center(
          child: Text('设置读取失败', style: Theme.of(context).textTheme.bodySmall),
        ),
        data: (settings) => _SettingsBody(settings: settings),
      ),
    );
  }
}

class _SettingsBody extends ConsumerWidget {
  const _SettingsBody({required this.settings});

  final AppSettingsData settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(settingsControllerProvider.notifier);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        const ProfileSectionTitle('隐私'),
        AppCard(
          child: Column(
            children: [
              SwitchRow(
                title: '隐藏敏感项名称',
                subtitle: '对外显示为别名',
                value: settings.hideSensitiveNames,
                onChanged: controller.setHideSensitiveNames,
              ),
              const Divider(height: 20),
              SwitchRow(
                title: '应用锁',
                subtitle: settings.appLockEnabled
                    ? '已开启，重新进入需生物识别或密码解锁'
                    : '使用 4 位密码保护隐私数据',
                value: settings.appLockEnabled,
                onChanged: (enabled) => _toggleAppLock(context, ref, enabled),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const ProfileSectionTitle('外观'),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('主题色', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              SegmentedControl<AppTheme>(
                value: AppTheme.parse(settings.theme),
                options: [
                  for (final value in AppTheme.values)
                    SegmentedOption(value: value, label: value.label),
                ],
                onChanged: controller.setTheme,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const ProfileSectionTitle('数据'),
        AppCard(
          child: Column(
            children: [
              ProfileActionRow(
                title: '导出数据',
                subtitle: '生成 JSON 备份，可分享到其他设备',
                onTap: () => _exportData(context, ref),
              ),
              const Divider(height: 20),
              ProfileActionRow(
                title: '导入数据',
                subtitle: '从 JSON 备份恢复，将覆盖当前数据',
                onTap: () => _importData(context, ref),
              ),
              const Divider(height: 20),
              ProfileActionRow(
                title: '清除全部数据',
                subtitle: '记录仅保存在本机，清除后不可恢复',
                danger: true,
                onTap: () => _confirmClear(context, ref),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _toggleAppLock(
    BuildContext context,
    WidgetRef ref,
    bool enabled,
  ) async {
    if (!enabled) {
      await ref.read(settingsControllerProvider.notifier).setAppLock(false);
      if (context.mounted) Toast.show(context, '应用锁已关闭');
      return;
    }
    final pin = await AppBottomSheet.show<String>(
      context: context,
      title: '设置应用锁密码',
      builder: (ctx) => const _PinSetupSheet(),
    );
    if (pin == null) return;
    await ref
        .read(settingsControllerProvider.notifier)
        .setAppLock(true, pin: pin);
    if (context.mounted) Toast.show(context, '应用锁已开启');
  }

  Future<void> _exportData(BuildContext context, WidgetRef ref) async {
    final service = ref.read(backupFileServiceProvider);
    if (!service.supported) {
      Toast.show(context, '当前平台暂不支持文件导出');
      return;
    }
    try {
      final json = await ref.read(maintenanceRepositoryProvider).exportJson();
      final shared =
          await service.shareJson(json, fileName: backupFileName());
      if (context.mounted && shared) {
        Toast.show(context, '备份文件已生成');
      }
    } catch (_) {
      if (context.mounted) Toast.show(context, '导出失败，请稍后重试');
    }
  }

  Future<void> _importData(BuildContext context, WidgetRef ref) async {
    final service = ref.read(backupFileServiceProvider);
    if (!service.supported) {
      Toast.show(context, '当前平台暂不支持文件导入');
      return;
    }
    final source = await service.pickJson();
    if (source == null) return;
    if (!context.mounted) return;
    final confirmed = await _confirm(
      context,
      title: '导入数据',
      message: '导入将覆盖当前全部打卡项、记录与设置，建议先导出备份。',
      confirmText: '确认导入',
      danger: true,
    );
    if (!confirmed) return;
    try {
      final summary =
          await ref.read(maintenanceRepositoryProvider).importJson(source);
      ref.invalidate(settingsControllerProvider);
      if (context.mounted) {
        Toast.show(
          context,
          '已导入 ${summary.habits} 个项目、${summary.records} 条记录',
        );
      }
    } on BackupException catch (error) {
      if (context.mounted) Toast.show(context, error.message);
    } catch (_) {
      if (context.mounted) Toast.show(context, '导入失败，数据已回滚');
    }
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final confirmed = await _confirm(
      context,
      title: '清除全部数据',
      message: '将删除所有打卡记录与设置，并恢复默认项目，且不可恢复。',
      confirmText: '确认清除',
      danger: true,
    );
    if (!confirmed) return;
    await ref.read(maintenanceRepositoryProvider).clearAllData();
    ref.invalidate(settingsControllerProvider);
    if (context.mounted) Toast.show(context, '已清除全部数据');
  }

  Future<bool> _confirm(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmText,
    bool danger = false,
  }) async {
    final result = await AppBottomSheet.show<bool>(
      context: context,
      title: title,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(message, style: Theme.of(ctx).textTheme.bodyMedium),
          const SizedBox(height: 20),
          FilledButton(
            style: danger
                ? FilledButton.styleFrom(
                    backgroundColor: Theme.of(ctx).colorScheme.error,
                  )
                : null,
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(confirmText),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('取消'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

class _PinSetupSheet extends ConsumerStatefulWidget {
  const _PinSetupSheet();

  @override
  ConsumerState<_PinSetupSheet> createState() => _PinSetupSheetState();
}

class _PinSetupSheetState extends ConsumerState<_PinSetupSheet> {
  final _first = TextEditingController();
  final _second = TextEditingController();

  @override
  void dispose() {
    _first.dispose();
    _second.dispose();
    super.dispose();
  }

  void _submit() {
    final first = _first.text.trim();
    final second = _second.text.trim();
    if (!RegExp(r'^\d{4}$').hasMatch(first)) {
      Toast.show(context, '请输入 4 位数字密码');
      return;
    }
    if (first != second) {
      Toast.show(context, '两次输入的密码不一致');
      return;
    }
    Navigator.of(context).pop(first);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '4 位数字，仅保存在本机，不保存明文。',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _first,
          obscureText: true,
          keyboardType: TextInputType.number,
          maxLength: 4,
          decoration: const InputDecoration(labelText: '输入密码'),
        ),
        TextField(
          controller: _second,
          obscureText: true,
          keyboardType: TextInputType.number,
          maxLength: 4,
          decoration: const InputDecoration(labelText: '再次输入'),
        ),
        const SizedBox(height: 8),
        FilledButton(onPressed: _submit, child: const Text('开启应用锁')),
      ],
    );
  }
}
