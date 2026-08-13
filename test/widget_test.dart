import 'package:flutter_test/flutter_test.dart';
import 'package:inav/core/theme/theme_provider.dart';
import 'package:inav/core/providers/focus_lock_provider.dart';
import 'package:inav/main.dart';

void main() {
  testWidgets('App launches and shows header', (WidgetTester tester) async {
    final themeProvider = ThemeProvider();
    await themeProvider.loadThemePreference();

    final focusLockProvider = FocusLockProvider();
    await focusLockProvider.initialize();

    await tester.pumpWidget(MyApp(themeProvider: themeProvider, focusLockProvider: focusLockProvider));

    await tester.pumpAndSettle();

    expect(find.text('INav'), findsOneWidget);

    expect(find.text('Home'), findsOneWidget);
  });
}
