import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/date_utils.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';
import 'app_card.dart';
import 'toast.dart';

/// 单个打卡项的卡片背景：预览、选择/更换与清除。
class HabitBackgroundCard extends ConsumerWidget {
  const HabitBackgroundCard({super.key, required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final service = ref.watch(backgroundImageServiceProvider);
    final image = service.providerFor(habit.bgPath);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('卡片背景', style: theme.textTheme.bodyMedium),
          if (image != null) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image(
                image: image,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ],
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed:
                    service.supported ? () => _pick(context, ref) : null,
                child: Text(habit.bgPath == null ? '选择图片' : '更换图片'),
              ),
              if (habit.bgPath != null)
                TextButton(
                  onPressed: () => _clear(context, ref),
                  child: const Text('清除背景'),
                ),
            ],
          ),
          if (!service.supported)
            Text(
              '当前平台暂不支持选图',
              style: theme.textTheme.bodySmall,
            ),
        ],
      ),
    );
  }

  Future<void> _pick(BuildContext context, WidgetRef ref) async {
    final relative = await ref
        .read(backgroundImageServiceProvider)
        .pick(habit.id);
    if (relative == null) {
      if (context.mounted) Toast.show(context, '未选择图片或压缩后仍超过 300KB');
      return;
    }
    await ref.read(habitRepositoryProvider).save(
          habit.copyWith(bgPath: relative, updatedAt: nowIso()),
        );
    if (context.mounted) Toast.show(context, '背景已更新');
  }

  Future<void> _clear(BuildContext context, WidgetRef ref) async {
    await ref.read(backgroundImageServiceProvider).remove(habit.id);
    await ref.read(habitRepositoryProvider).save(
          habit.copyWith(clearBgPath: true, updatedAt: nowIso()),
        );
    if (context.mounted) Toast.show(context, '背景已清除');
  }
}
