// Basic widget test for INav app
import 'package:flutter_test/flutter_test.dart';
import 'package:inav/core/theme/theme_provider.dart';
import 'package:inav/main.dart';

void main() {
  testWidgets('App launches and shows header', (WidgetTester tester) async {
    // Create theme provider
    final themeProvider = ThemeProvider();
    await themeProvider.loadThemePreference();

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(themeProvider: themeProvider));

    // Wait for all animations and async operations
    await tester.pumpAndSettle();

    // Verify that the app title 'INav' is displayed
    expect(find.text('INav'), findsOneWidget);

    // Verify that bottom navigation has Home tab
    expect(find.text('Home'), findsOneWidget);
  });
}
