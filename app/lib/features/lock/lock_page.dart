import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/widgets/toast.dart';
import 'app_lock_controller.dart';

/// 全屏应用锁：优先生物识别，回落 4 位密码。
class LockPage extends ConsumerStatefulWidget {
  const LockPage({super.key});

  @override
  ConsumerState<LockPage> createState() => _LockPageState();
}

class _LockPageState extends ConsumerState<LockPage> {
  final TextEditingController _pin = TextEditingController();
  bool _biometricAvailable = false;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBiometrics();
  }

  Future<void> _loadBiometrics() async {
    final available =
        await ref.read(appLockControllerProvider.notifier).biometricAvailable();
    if (mounted) setState(() => _biometricAvailable = available);
  }

  @override
  void dispose() {
    _pin.dispose();
    super.dispose();
  }

  Future<void> _unlockWithBiometrics() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final ok = await ref
        .read(appLockControllerProvider.notifier)
        .unlockWithBiometrics();
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (!ok) _error = '未通过验证，也可以输入密码';
    });
  }

  void _unlockWithPin() {
    final pin = _pin.text.trim();
    if (pin.length != 4) {
      setState(() => _error = '请输入 4 位密码');
      return;
    }
    final ok =
        ref.read(appLockControllerProvider.notifier).verifyPin(pin);
    if (!ok && mounted) {
      setState(() => _error = '密码不正确');
      _pin.clear();
    }
  }

  Future<void> _disableTemporarily() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('暂时关闭应用锁'),
        content: const Text('将关闭应用锁并清除已保存的密码，之后可在「我的 - 隐私」重新开启。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('确认关闭'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(appLockControllerProvider.notifier).disableLock();
    if (!mounted) return;
    Toast.show(context, '应用锁已关闭');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  size: 56,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'LiveBetter',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  _biometricAvailable
                      ? '使用生物识别或 4 位密码解锁'
                      : '输入 4 位密码解锁',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                if (_biometricAvailable) ...[
                  FilledButton.icon(
                    onPressed: _busy ? null : _unlockWithBiometrics,
                    icon: const Icon(Icons.fingerprint_rounded),
                    label: const Text('生物识别解锁'),
                  ),
                  const SizedBox(height: 20),
                ],
                TextField(
                  controller: _pin,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 4,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    counterText: '',
                    labelText: '4 位密码',
                    errorText: _error,
                    border: const OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _unlockWithPin(),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _unlockWithPin,
                  child: const Text('解锁'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _disableTemporarily,
                  child: const Text('暂时关闭应用锁'),
                ),
                const SizedBox(height: 8),
                Text(
                  '忘记密码时，可关闭应用锁后重新设置',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
