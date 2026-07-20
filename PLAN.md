# Implementation Plan - INav Reusable Header & Navigation System

## Problem Statement
Create a reusable header and bottom navigation bar system for the INav Flutter app that matches the HTML reference design. The system needs centralized theme management (light/dark mode) with persistent state, reusable components, and a clean scalable architecture suitable for multi-page navigation.

## Requirements
- **State Management**: Provider for theme management
- **Theme Persistence**: SharedPreferences to remember user's theme choice
- **Icons**: Phosphor Icons Flutter package (matching HTML reference
- **Navigation**: IndexedStack to preserve state across tab switches
- **Header**: Fixed on all pages with app title and theme toggle
- **Bottom Navigation**: 5 tabs (Home, Quran, Mosque, Qibla, Settings)
- **Colors**: Match HTML Tailwind config exactly
- **File Structure**: Clean, scalable, with separated reusable components

## Background

### Research Findings

1. **Provider Package**: Official Flutter state management solution, perfect for theme management. Uses ChangeNotifier pattern with context.watch() for reactive updates and context.read() for one-time reads.

2. **Phosphor Icons Flutter**: Available on pub.dev with support for multiple styles (thin, light, regular, bold, fill, duotone). Usage: `PhosphorIcon(PhosphorIcons.regular.moon)` or with standard `Icon()` widget.

3. **IndexedStack**: Best widget for preserving state across tabs - keeps all children in memory but only displays one at a time, perfect for navigation where scroll position matters.

4. **SharedPreferences**: Standard solution for simple key-value persistence, ideal for storing theme preference.

5. **Performance**: IndexedStack with 5 tabs is lightweight for mobile devices. The HTML reference is mobile-first, so targeting standard Android/iOS devices is appropriate.

## Proposed Solution

Create a layered architecture with clear separation of concerns:

```
lib/
├── main.dart                          # App entry point
├── core/
│   ├── theme/
│   │   ├── app_theme.dart            # Theme definitions (light/dark)
│   │   ├── theme_provider.dart       # Theme state management
│   │   └── app_colors.dart           # Color constants from HTML
│   └── constants/
│       └── app_constants.dart        # App-wide constants
├── widgets/
│   ├── common/
│   │   ├── app_header.dart           # Reusable header widget
│   │   └── theme_toggle_button.dart  # Theme switcher button
│   └── navigation/
│       └── bottom_nav_bar.dart       # Bottom navigation bar
└── screens/
    ├── main_screen.dart              # Main scaffold with header + nav
    ├── home/
    │   └── home_screen.dart          # Home tab content
    ├── quran/
    │   └── quran_screen.dart         # Quran tab content
    ├── mosque/
    │   └── mosque_screen.dart        # Mosque tab content
    ├── qibla/
    │   └── qibla_screen.dart         # Qibla tab content
    └── settings/
        └── settings_screen.dart      # Settings tab content
```

### Key Design Decisions

1. **Theme Provider**: ChangeNotifier-based provider that loads saved preference on init, exposes toggle method, and persists changes
2. **Reusable Components**: Header and navbar as separate widgets accepting callbacks/parameters
3. **Color System**: Extract exact color values from HTML Tailwind config into app_colors.dart
4. **Navigation Logic**: MainScreen manages IndexedStack with currentIndex state
5. **No Duplication**: Theme logic centralized in ThemeProvider, consumed via context.watch()

---

## Task Breakdown

### Task 1: Project Setup and Dependencies
**Objective**: Configure pubspec.yaml with required packages and verify installation.

**Implementation guidance**:
- Add `provider: ^6.1.1` for state management
- Add `shared_preferences: ^2.2.2` for theme persistence
- Add `phosphor_flutter: ^2.1.0` for icons matching HTML reference
- Run `flutter pub get` to install dependencies
- Verify no version conflicts in pubspec.lock

**Tests**: Run `flutter pub get` successfully without errors

**Demo**: Dependencies listed in pubspec.yaml and installed in project

---

### Task 2: Create Color System from HTML Reference
**Objective**: Extract and define all color constants from the HTML Tailwind config into a centralized Dart file.

**Implementation guidance**:
- Create `lib/core/theme/app_colors.dart`
- Define Color constants for:
  - Primary colors (light: #0D47A1, dark: #3B82F6)
  - Accent: #1976D2
  - Surface colors (light: #F8FAFC, dark: #0F172A)
  - Card colors (light: #FFFFFF, dark: #1E293B)
  - Text colors (main and muted for both themes)
  - Border colors (light: #E2E8F0, dark: #334155)
  - Success: #10B981, Teal: #0D9488
- Use static const Color fields in a class
- Add comments mapping to HTML Tailwind color names

**Tests**: Colors compile without errors and match hex values from HTML

**Demo**: File with all color constants ready for use in theme definitions

---

### Task 3: Create Theme Definitions
**Objective**: Build light and dark ThemeData objects using the color system.

**Implementation guidance**:
- Create `lib/core/theme/app_theme.dart`
- Define `AppTheme` class with static methods:
  - `ThemeData lightTheme()` - returns light theme configuration
  - `ThemeData darkTheme()` - returns dark theme configuration
- Configure ThemeData properties:
  - colorScheme with primary, surface, background colors
  - scaffoldBackgroundColor
  - appBarTheme
  - bottomNavigationBarTheme
  - textTheme with Inter font family (matching HTML)
  - iconTheme
- Use AppColors for all color values
- Set useMaterial3: true for modern design

**Tests**: Both themes instantiate without errors and use correct colors

**Demo**: Theme definitions ready to be applied to MaterialApp

---

### Task 4: Implement Theme Provider with Persistence
**Objective**: Create ChangeNotifier-based provider for theme state management with SharedPreferences persistence.

**Implementation guidance**:
- Create `lib/core/theme/theme_provider.dart`
- Define `ThemeProvider extends ChangeNotifier`
- Fields:
  - `ThemeMode _themeMode` (private)
  - `SharedPreferences? _prefs` (private)
  - `ThemeMode get themeMode` (public getter)
- Methods:
  - `Future<void> loadThemePreference()` - loads from SharedPreferences on init
  - `Future<void> toggleTheme()` - switches theme and saves to SharedPreferences
  - `bool get isDarkMode` - convenience getter
- Use SharedPreferences key: 'theme_mode'
- Store as string: 'light', 'dark', or 'system'
- Call `notifyListeners()` after theme change

**Tests**: Theme toggles correctly and persists across app restarts

**Demo**: Working theme provider that loads saved preference and toggles theme

---

### Task 5: Build Reusable Header Widget
**Objective**: Create the app header component matching HTML reference with app title and theme toggle button.

**Implementation guidance**:
- Create `lib/widgets/common/app_header.dart`
- Define `AppHeader extends StatelessWidget`
- Layout structure:
  - Container with bottom border
  - Row with mainAxisAlignment: spaceBetween
  - Left: Text "INav" (bold, size 24, primary color)
  - Right: ThemeToggleButton widget
- Styling:
  - Padding: horizontal 24, vertical 20
  - Border bottom: 1px, color from theme
  - Background: surface color from theme
- Use `context.watch<ThemeProvider>()` to react to theme changes
- Make header sticky with appropriate elevation

**Tests**: Header displays correctly in both light and dark themes

**Demo**: Fixed header at top showing "INav" title and theme toggle button

---

### Task 6: Build Theme Toggle Button Widget
**Objective**: Create standalone theme toggle button with icon that changes based on current theme.

**Implementation guidance**:
- Create `lib/widgets/common/theme_toggle_button.dart`
- Define `ThemeToggleButton extends StatelessWidget`
- Use `context.watch<ThemeProvider>()` to get current theme
- Display icon:
  - Light mode: `PhosphorIcons.regular.moon` (moon icon)
  - Dark mode: `PhosphorIcons.fill.sun` (filled sun icon with amber color)
- Wrap in InkWell or IconButton for tap interaction
- OnTap: call `context.read<ThemeProvider>().toggleTheme()`
- Styling:
  - Rounded container (borderRadius: 12)
  - Padding: 10
  - Hover/press effect with scale animation
  - Icon size: 24

**Tests**: Button toggles theme when tapped, icon changes appropriately

**Demo**: Working theme toggle button that switches between light/dark mode

---

### Task 7: Build Bottom Navigation Bar Widget
**Objective**: Create the 5-tab bottom navigation bar matching HTML reference design.

**Implementation guidance**:
- Create `lib/widgets/navigation/bottom_nav_bar.dart`
- Define `BottomNavBar extends StatelessWidget`
- Parameters:
  - `int currentIndex` (required)
  - `ValueChanged<int> onTap` (required)
- 5 BottomNavigationBarItem entries:
  1. Home - `PhosphorIcons.house` (filled when active)
  2. Quran - `PhosphorIcons.bookOpen`
  3. Mosque - `PhosphorIcons.mosque`
  4. Qibla - `PhosphorIcons.compass`
  5. Settings - `PhosphorIcons.gear`
- Styling matching HTML:
  - Background: card color with blur effect
  - Border top: 1px
  - Active item: primary color with filled icon
  - Inactive items: muted text color with regular icons
  - Icon size: 22, text size: 11
  - Safe area padding for iOS devices
- Use BottomNavigationBar widget with type: BottomNavigationBarType.fixed

**Tests**: All 5 tabs display correctly with proper icons and colors

**Demo**: Bottom navigation bar with 5 tabs matching HTML design

---

### Task 8: Create Placeholder Screen Widgets
**Objective**: Build simple placeholder screens for each of the 5 tabs.

**Implementation guidance**:
- Create files in respective folders:
  - `lib/screens/home/home_screen.dart`
  - `lib/screens/quran/quran_screen.dart`
  - `lib/screens/mosque/mosque_screen.dart`
  - `lib/screens/qibla/qibla_screen.dart`
  - `lib/screens/settings/settings_screen.dart`
- Each screen: StatelessWidget with Center + Column containing:
  - Icon matching the tab (from Phosphor Icons)
  - Text showing screen name
  - Simple styled container for visual confirmation
- Use theme colors for styling
- Add padding and basic layout structure

**Tests**: Each screen builds without errors and displays its name

**Demo**: 5 placeholder screens ready to be populated with actual content

---

### Task 9: Build Main Screen with Navigation Logic
**Objective**: Create the main scaffold that combines header, content area with IndexedStack, and bottom navigation.

**Implementation guidance**:
- Create `lib/screens/main_screen.dart`
- Define `MainScreen extends StatefulWidget`
- State management:
  - `int _currentIndex = 0` for tracking active tab
  - Method `void _onTabTapped(int index)` to update index
- Build method structure:
  - Scaffold with:
    - No appBar (using custom header)
    - body: Column with:
      - AppHeader() widget
      - Expanded with IndexedStack:
        - index: _currentIndex
        - children: all 5 screen widgets
    - bottomNavigationBar: BottomNavBar with currentIndex and onTap callback
- IndexedStack preserves state of all screens
- Background color from theme

**Tests**: Navigation switches between screens, state is preserved when switching tabs

**Demo**: Fully functional app with working navigation between 5 tabs

---

### Task 10: Wire Theme Provider into App Root
**Objective**: Integrate ThemeProvider at app root and apply theme to MaterialApp.

**Implementation guidance**:
- Update `lib/main.dart`
- Modify `main()` function:
  - Make it async
  - Call `WidgetsFlutterBinding.ensureInitialized()`
  - Create ThemeProvider instance
  - Call `await themeProvider.loadThemePreference()`
  - Pass themeProvider to runApp
- Wrap MaterialApp with ChangeNotifierProvider<ThemeProvider>
- Use MultiProvider if additional providers added later
- Configure MaterialApp:
  - theme: AppTheme.lightTheme()
  - darkTheme: AppTheme.darkTheme()
  - themeMode: context.watch<ThemeProvider>().themeMode
  - home: MainScreen()
  - Remove debug banner
  - Set title: "INav"

**Tests**: App launches with saved theme, theme persists across restarts

**Demo**: Complete working application with persistent theme, reusable header and navigation system matching HTML reference design

---

## Summary
This plan builds a production-ready navigation system with proper separation of concerns, reusable components, and centralized state management. Each task builds incrementally on previous work, ensuring no orphaned code and enabling demonstration at each step.
