import 'package:material_ui/material_ui.dart';

/// 统一圆角卡片，白底 + 细边框；可选背景图并自动加半透明蒙层。
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.color,
    this.image,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final ImageProvider? image;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (image == null) {
      return Card(
        color: color,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Padding(padding: padding, child: child),
        ),
      );
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          image: DecorationImage(image: image!, fit: BoxFit.cover),
        ),
        child: InkWell(
          onTap: onTap,
          child: Container(
            color: theme.colorScheme.surface.withValues(alpha: 0.82),
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
