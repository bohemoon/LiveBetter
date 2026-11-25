import 'package:material_ui/material_ui.dart';

import '../../shared/widgets/app_card.dart';

/// 分区标题。
class ProfileSectionTitle extends StatelessWidget {
  const ProfileSectionTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}

/// 分区内容卡片。
class ProfilePanel extends StatelessWidget {
  const ProfilePanel({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

/// 可点击的设置行，右侧可显示当前值或箭头。
class ProfileActionRow extends StatelessWidget {
  const ProfileActionRow({
    super.key,
    required this.title,
    this.subtitle,
    this.value,
    this.onTap,
    this.danger = false,
  });

  final String title;
  final String? subtitle;
  final String? value;
  final VoidCallback? onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: danger ? theme.colorScheme.error : null,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(subtitle!, style: theme.textTheme.bodySmall),
                  ],
                ],
              ),
            ),
            if (value != null) ...[
              const SizedBox(width: 12),
              Text(
                value!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ] else if (onTap != null)
              Icon(
                Icons.chevron_right,
                size: 20,
                color: theme.colorScheme.onSurfaceVariant,
              ),
          ],
        ),
      ),
    );
  }
}
