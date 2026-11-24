import 'package:material_ui/material_ui.dart';

/// 三套莫兰迪主题。
enum AppTheme {
  green(
    label: '绿',
    seed: Color(0xFF5D7264),
    background: Color(0xFFF4F6F3),
    card: Color(0xFFFFFFFF),
    accent: Color(0xFF5D7264),
    accentSoft: Color(0xFFE3EBE2),
    line: Color(0xFFE4E9E3),
  ),
  blue(
    label: '蓝',
    seed: Color(0xFF5F7488),
    background: Color(0xFFF4F6F7),
    card: Color(0xFFFFFFFF),
    accent: Color(0xFF5F7488),
    accentSoft: Color(0xFFE3EAF0),
    line: Color(0xFFE3E8EC),
  ),
  pink(
    label: '粉',
    seed: Color(0xFF9D7180),
    background: Color(0xFFF9F5F6),
    card: Color(0xFFFFFFFF),
    accent: Color(0xFF9D7180),
    accentSoft: Color(0xFFF0E2E6),
    line: Color(0xFFEDE2E5),
  );

  const AppTheme({
    required this.label,
    required this.seed,
    required this.background,
    required this.card,
    required this.accent,
    required this.accentSoft,
    required this.line,
  });

  final String label;
  final Color seed;
  final Color background;
  final Color card;
  final Color accent;
  final Color accentSoft;
  final Color line;

  static AppTheme parse(String? value) {
    return AppTheme.values.firstWhere(
      (theme) => theme.name == value,
      orElse: () => AppTheme.green,
    );
  }
}

/// 统一墨色。
const Color _ink = Color(0xFF1B211D);
const Color _inkTertiary = Color(0xFF95A09A);

ThemeData buildTheme(AppTheme theme) {
  final scheme = ColorScheme.fromSeed(
    seedColor: theme.seed,
    brightness: Brightness.light,
  ).copyWith(
    primary: theme.accent,
    onPrimary: Colors.white,
    secondary: theme.accent,
    surface: theme.background,
    onSurface: _ink,
    surfaceContainerHighest: theme.accentSoft,
    outlineVariant: theme.line,
  );

  final base = ThemeData(colorScheme: scheme, useMaterial3: true);
  final textTheme = base.textTheme
      .apply(bodyColor: _ink, displayColor: _ink)
      .copyWith(
        headlineSmall: base.textTheme.headlineSmall?.copyWith(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
        titleMedium: base.textTheme.titleMedium?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(fontSize: 14, height: 1.5),
        bodySmall: base.textTheme.bodySmall?.copyWith(
          fontSize: 12,
          color: _inkTertiary,
        ),
        labelLarge: base.textTheme.labelLarge?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      );

  return base.copyWith(
    scaffoldBackgroundColor: theme.background,
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: theme.background,
      foregroundColor: _ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: theme.card,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: theme.line),
      ),
    ),
    dividerTheme: DividerThemeData(color: theme.line, thickness: 1, space: 1),
    navigationBarTheme: NavigationBarThemeData(
      height: 64,
      elevation: 0,
      backgroundColor: theme.card,
      indicatorColor: theme.accentSoft,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          size: 22,
          color: states.contains(WidgetState.selected) ? theme.accent : _inkTertiary,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontSize: 11,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w600
              : FontWeight.w400,
          color: states.contains(WidgetState.selected) ? theme.accent : _inkTertiary,
        ),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: _ink,
      contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: theme.card,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
  );
}
