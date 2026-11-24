import 'package:flutter_test/flutter_test.dart';
import 'package:livebetter/app/theme.dart';

void main() {
  test('三套主题都能生成 Material 3 配色', () {
    for (final theme in AppTheme.values) {
      final data = buildTheme(theme);
      expect(data.useMaterial3, isTrue);
      expect(data.colorScheme.primary, theme.accent);
      expect(data.scaffoldBackgroundColor, theme.background);
    }
  });

  test('主题解析对非法值回退到绿色主题', () {
    expect(AppTheme.parse('pink'), AppTheme.pink);
    expect(AppTheme.parse('unknown'), AppTheme.green);
    expect(AppTheme.parse(null), AppTheme.green);
  });
}
