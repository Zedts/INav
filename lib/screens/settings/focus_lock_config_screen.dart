// ignore_for_file: non_const_argument_for_const_parameter

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/focus_lock_provider.dart';
import '../../core/models/app_definition.dart';
import '../../core/models/lock_schedule.dart';
import '../../core/models/unlock_config.dart';
import '../../core/constants/default_apps.dart';
import '../../core/services/accessibility_service_helper.dart';
import '../../widgets/dialogs/app_selection_dialog.dart';
import '../../widgets/common/async_app_icon.dart';

class FocusLockConfigScreen extends StatefulWidget {
  const FocusLockConfigScreen({super.key});

  @override
  State<FocusLockConfigScreen> createState() => _FocusLockConfigScreenState();
}

class _FocusLockConfigScreenState extends State<FocusLockConfigScreen> {
  final GlobalKey _preventUninstallSwitchKey = GlobalKey();

  final List<String> _allPrayerKeys = const [
    'fajr',
    'dhuhr',
    'asr',
    'maghrib',
    'isha',
  ];
  final Map<String, String> _prayerLabels = const {
    'fajr': 'Fajr',
    'dhuhr': 'Dhuhr',
    'asr': 'Asr',
    'maghrib': 'Maghrib',
    'isha': 'Isha',
  };

  Future<void> _showAddAppsDialog(FocusLockProvider provider) async {
    final AppDefinition? result = await showDialog<AppDefinition>(
      context: context,
      builder: (context) =>
          AppSelectionDialog(currentlyLockedApps: provider.lockedApps),
    );

    if (result != null && mounted) {
      await provider.addLockedApp(result);
    }
  }

  Future<void> _addCustomSchedule(FocusLockProvider provider) async {
    final now = TimeOfDay.now();
    final TimeOfDay? pickedStart = await showTimePicker(
      context: context,
      initialTime: now,
      helpText: 'Select start time',
    );
    if (pickedStart == null) return;
    if (!mounted) return;

    final TimeOfDay? pickedEnd = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: (now.hour + 1) % 24, minute: now.minute),
      helpText: 'Select end time',
    );
    if (pickedEnd == null) return;
    if (!mounted) return;

    final TextEditingController labelController = TextEditingController(
      text: 'Focus Time',
    );
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.cardDark
            : AppColors.cardLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Name this focus block',
          style: GoogleFonts.plusJakartaSans().copyWith(
            fontWeight: FontWeight.w800,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.textMainDark
                : AppColors.textMainLight,
          ),
        ),
        content: TextField(
          autofocus: true,
          controller: labelController,
          style: GoogleFonts.plusJakartaSans().copyWith(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.textMainDark
                : AppColors.textMainLight,
          ),
          decoration: InputDecoration(
            hintText: 'e.g. Study, Bedtime, Work',
            hintStyle: GoogleFonts.plusJakartaSans().copyWith(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.textMutedDark
                  : AppColors.textMutedLight,
            ),
            filled: true,
            fillColor: Theme.of(context).brightness == Brightness.dark
                ? AppColors.surfaceDark
                : AppColors.surfaceLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.plusJakartaSans().copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.textMutedDark
                    : AppColors.textMutedLight,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.primaryDark
                  : AppColors.primaryLight,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Save',
              style: GoogleFonts.plusJakartaSans().copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final id = 'custom_${DateTime.now().millisecondsSinceEpoch}';
      await provider.addCustomSchedule(
        CustomLockSchedule(
          id: id,
          label: labelController.text.trim().isEmpty
              ? 'Focus Time'
              : labelController.text.trim(),
          enabled: true,
          startTime: pickedStart,
          endTime: pickedEnd,
        ),
      );
    }
  }

  Future<void> _updateCustomScheduleTime(
    FocusLockProvider provider,
    CustomLockSchedule schedule, {
    required bool isStart,
  }) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? schedule.startTime : schedule.endTime,
    );
    if (picked == null) return;
    await provider.updateCustomSchedule(
      schedule.copyWith(
        startTime: isStart ? picked : schedule.startTime,
        endTime: isStart ? schedule.endTime : picked,
      ),
    );
  }

  Future<void> _requestAccessibilityPermission() async {
    final bool enabled =
        await AccessibilityServiceHelper.isAccessibilityServiceEnabled();
    if (!mounted) return;

    if (enabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Accessibility is already enabled',
            style: GoogleFonts.plusJakartaSans().copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.success,
        ),
      );
      return;
    }
    await AccessibilityServiceHelper.openAccessibilitySettings();
  }

  Future<void> _requestUsagePermission() async {
    final bool granted =
        await AccessibilityServiceHelper.hasUsageStatsPermission();
    if (!mounted) return;
    if (granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Usage access is already granted',
            style: GoogleFonts.plusJakartaSans().copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.success,
        ),
      );
      return;
    }
    await AccessibilityServiceHelper.openUsageAccessSettings();
  }

  Future<void> _resetToDefaults(FocusLockProvider provider) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.cardDark
            : AppColors.cardLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Reset all settings?',
          style: GoogleFonts.plusJakartaSans().copyWith(
            fontWeight: FontWeight.w800,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.textMainDark
                : AppColors.textMainLight,
          ),
        ),
        content: Text(
          'This will reset lock apps, schedules, unlock methods, and other Focus Lock settings to their defaults.',
          style: GoogleFonts.plusJakartaSans().copyWith(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.textMutedDark
                : AppColors.textMutedLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.plusJakartaSans().copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.roseAccent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Reset',
              style: GoogleFonts.plusJakartaSans().copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await provider.resetToDefaults();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Reset to default settings',
              style: GoogleFonts.plusJakartaSans().copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? AppColors.primaryDark
                : AppColors.primaryLight,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final focusProvider = context.watch<FocusLockProvider>();
    final plus = GoogleFonts.plusJakartaSans();

    final masterEnabled = focusProvider.masterEnabled;
    final prayerSchedule = focusProvider.prayerSchedule;
    final lockedApps = focusProvider.lockedApps;
    final customSchedules = focusProvider.customSchedules;
    final unlockConfig = focusProvider.unlockConfig;
    final allowEmergency = focusProvider.allowEmergency;
    final dailySkipAllowance = focusProvider.dailySkipAllowance;
    final preventUninstall = focusProvider.preventUninstall;

    // Fallbacks if not initialized yet
    final prayerEnabled = prayerSchedule?.enabled ?? true;
    final prayerKeys =
        prayerSchedule?.enabledPrayers.toSet() ?? _allPrayerKeys.toSet();
    final startOffset = prayerSchedule?.startOffsetMinutes ?? 0;
    final duration = prayerSchedule?.durationMinutes ?? 20;

    final unlockMethodLabel = switch (unlockConfig.method) {
      UnlockMethod.waitItOut => 'waitItOut',
      UnlockMethod.markPrayed => 'markPrayed',
      UnlockMethod.mindfulPause => 'mindfulPause',
      UnlockMethod.typePhrase => 'typePhrase',
    };

    // Show default apps + any user-added ones from provider
    final List<_AppDisplayItem> appItems = lockedApps
        .map(
          (app) => _AppDisplayItem(
            key: app.packageName,
            name: app.name,
            icon: IconData(
              app.iconCodePoint,
              fontFamily: app.iconFontFamily,
              fontPackage: app.iconFontPackage,
              matchTextDirection: app.iconMatchTextDirection,
            ),
            color: app.color,
            packageName: app.packageName,
            fromProvider: true,
          ),
        )
        .toList();

    // can still quickly toggle them as in original design
    final defaultAdditions = <_AppDisplayItem>[];
    for (final d in defaultAdditions) {
      if (!appItems.any((a) => a.packageName == d.packageName)) {
        appItems.add(d);
      }
    }

    appItems.sort((a, b) {
      const order = [
        'com.instagram.android',
        'com.zhiliaoapp.musically',
        'com.google.android.youtube',
      ];
      final ia = order.indexOf(a.packageName);
      final ib = order.indexOf(b.packageName);
      if (ia != -1 || ib != -1) {
        final aOrd = ia == -1 ? 999 : ia;
        final bOrd = ib == -1 ? 999 : ib;
        return aOrd.compareTo(bOrd);
      }
      return a.name.compareTo(b.name);
    });

    return Scaffold(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, isDark, focusProvider),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                children: [
                  _buildMasterToggleCard(
                    isDark,
                    plus,
                    focusProvider,
                    masterEnabled,
                  ),
                  const SizedBox(height: 20),
                  _buildSectionTitle(isDark, plus, 'PERMISSIONS & ACCESS'),
                  const SizedBox(height: 8),
                  _buildPermissionsQuickCard(isDark, plus, focusProvider),
                  const SizedBox(height: 20),
                  _buildAppsToLockSection(
                    isDark,
                    plus,
                    focusProvider,
                    appItems,
                    lockedApps,
                  ),
                  const SizedBox(height: 20),
                  _buildLockScheduleSection(
                    isDark,
                    plus,
                    focusProvider,
                    prayerEnabled,
                    prayerKeys,
                    startOffset,
                    duration,
                  ),
                  const SizedBox(height: 20),
                  _buildCustomFocusTimesSection(
                    isDark,
                    plus,
                    focusProvider,
                    customSchedules,
                  ),
                  const SizedBox(height: 20),
                  _buildUnlockMethodSection(
                    isDark,
                    plus,
                    focusProvider,
                    unlockConfig,
                    unlockMethodLabel,
                  ),
                  const SizedBox(height: 20),
                  _buildExceptionsSection(
                    isDark,
                    plus,
                    focusProvider,
                    allowEmergency,
                    dailySkipAllowance,
                    preventUninstall,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    bool isDark,
    FocusLockProvider provider,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark
                      ? AppColors.hairlineDark.withValues(alpha: 0.8)
                      : AppColors.hairlineLight.withValues(alpha: 0.8),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.arrow_back,
                size: 20,
                color: isDark
                    ? AppColors.textMainDark
                    : AppColors.textMainLight,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Focus Lock',
                  style: GoogleFonts.plusJakartaSans().copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppColors.textMainDark
                        : AppColors.textMainLight,
                  ),
                ),
                Text(
                  'App blocking & focus schedules',
                  style: GoogleFonts.plusJakartaSans().copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.textMutedDark
                        : AppColors.textMutedLight,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _resetToDefaults(provider),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Text(
                'Reset',
                style: GoogleFonts.plusJakartaSans().copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.primaryDark
                      : AppColors.primaryLight,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMasterToggleCard(
    bool isDark,
    TextStyle plus,
    FocusLockProvider provider,
    bool masterEnabled,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? AppColors.hairlineDark.withValues(alpha: 0.8)
              : AppColors.hairlineLight.withValues(alpha: 0.8),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.roseAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.lock_rounded,
              color: AppColors.roseAccent,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enable Focus Lock',
                  style: plus.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.textMainDark
                        : AppColors.textMainLight,
                  ),
                ),
                Text(
                  'Block distracting apps during focus windows',
                  style: plus.copyWith(
                    fontSize: 11,
                    color: isDark
                        ? AppColors.textMutedDark
                        : AppColors.textMutedLight,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: masterEnabled,
            activeTrackColor: isDark
                ? AppColors.primaryDark
                : AppColors.primaryLight,
            onChanged: (value) => provider.setMasterEnabled(value),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionsQuickCard(
    bool isDark,
    TextStyle plus,
    FocusLockProvider provider,
  ) {
    final dividerColor = isDark
        ? AppColors.hairlineDark.withValues(alpha: 0.8)
        : AppColors.hairlineLight.withValues(alpha: 0.8);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: dividerColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: ListTile(
              onTap: _requestAccessibilityPermission,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              leading: Icon(
                Icons.visibility_outlined,
                color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
              ),
              title: Text(
                'Accessibility Service',
                style: plus.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.textMainDark
                      : AppColors.textMainLight,
                ),
              ),
              subtitle: Text(
                'Detects app launches to show overlay',
                style: plus.copyWith(
                  fontSize: 11,
                  color: isDark
                      ? AppColors.textMutedDark
                      : AppColors.textMutedLight,
                ),
              ),
              trailing: const Icon(Icons.open_in_new, size: 18),
            ),
          ),
          Divider(thickness: 1, height: 1, color: dividerColor),
          Material(
            color: Colors.transparent,
            child: ListTile(
              onTap: _requestUsagePermission,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              leading: Icon(
                Icons.timer_outlined,
                color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
              ),
              title: Text(
                'Usage Stats Access',
                style: plus.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.textMainDark
                      : AppColors.textMainLight,
                ),
              ),
              subtitle: Text(
                'Tracks blocked app attempts (optional)',
                style: plus.copyWith(
                  fontSize: 11,
                  color: isDark
                      ? AppColors.textMutedDark
                      : AppColors.textMutedLight,
                ),
              ),
              trailing: const Icon(Icons.open_in_new, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppsToLockSection(
    bool isDark,
    TextStyle plus,
    FocusLockProvider provider,
    List<_AppDisplayItem> appItems,
    List<AppDefinition> lockedApps,
  ) {
    final lockedSet = lockedApps.map((e) => e.packageName).toSet();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'APPS TO LOCK',
                style: plus.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.textMutedDark
                      : AppColors.textMutedLight,
                  letterSpacing: 1.2,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddAppsDialog(provider),
                icon: const Icon(Icons.add_circle_outline, size: 16),
                label: const Text('Add Apps'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark
                      ? AppColors.primaryDark
                      : AppColors.primaryLight,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  textStyle: plus.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? AppColors.hairlineDark.withValues(alpha: 0.8)
                  : AppColors.hairlineLight.withValues(alpha: 0.8),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            children: appItems.asMap().entries.map((entry) {
              final index = entry.key;
              final app = entry.value;

              final actuallyLocked = lockedSet.contains(app.packageName);

              return Column(
                children: [
                  if (index > 0)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: isDark
                          ? AppColors.hairlineDark
                          : AppColors.hairlineLight,
                    ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        AsyncAppIcon(
                          packageName: app.packageName,
                          fallbackColor: app.color,
                          fallbackIcon: app.icon,
                          isDark: isDark,
                          size: 36,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                app.name,
                                style: plus.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? AppColors.textMainDark
                                      : AppColors.textMainLight,
                                ),
                              ),
                              if (!app.fromProvider)
                                Text(
                                  app.packageName,
                                  style: plus.copyWith(
                                    fontSize: 10,
                                    color: isDark
                                        ? AppColors.textMutedDark
                                        : AppColors.textMutedLight,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (app.fromProvider) ...[
                          Switch.adaptive(
                            value: actuallyLocked,
                            activeTrackColor: isDark
                                ? AppColors.primaryDark
                                : AppColors.primaryLight,
                            onChanged: (value) async {
                              final AppDefinition target =
                                  await _resolveAppDefinition(app);
                              await provider.toggleLockedApp(target, value);
                            },
                          ),
                        ] else
                          Switch.adaptive(
                            value: actuallyLocked,
                            activeTrackColor: isDark
                                ? AppColors.primaryDark
                                : AppColors.primaryLight,
                            onChanged: (value) async {
                              final AppDefinition target =
                                  await _resolveAppDefinition(app);
                              await provider.toggleLockedApp(target, value);
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Future<AppDefinition> _resolveAppDefinition(_AppDisplayItem app) async {
    final existing = DefaultApps.getApp(app.packageName);
    if (existing != null) return existing;
    return AppDefinition(
      packageName: app.packageName,
      name: app.name,
      iconCodePoint: app.icon.codePoint,
      iconFontFamily: app.icon.fontFamily,
      iconFontPackage: app.icon.fontPackage,
      iconMatchTextDirection: app.icon.matchTextDirection,
      colorARGB: app.color.toARGB32(),
    );
  }

  Widget _buildLockScheduleSection(
    bool isDark,
    TextStyle plus,
    FocusLockProvider provider,
    bool prayerEnabled,
    Set<String> prayerKeys,
    int startOffsetMin,
    int lockDurationMin,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'LOCK SCHEDULE',
            style: plus.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? AppColors.textMutedDark
                  : AppColors.textMutedLight,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? AppColors.hairlineDark.withValues(alpha: 0.8)
                  : AppColors.hairlineLight.withValues(alpha: 0.8),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color:
                            (isDark
                                    ? AppColors.primaryDark
                                    : AppColors.primaryLight)
                                .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.schedule,
                        color: isDark
                            ? AppColors.primaryDark
                            : AppColors.primaryLight,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lock During Prayer Times',
                            style: plus.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.textMainDark
                                  : AppColors.textMainLight,
                            ),
                          ),
                          Text(
                            'Uses today\'s Adhan schedule',
                            style: plus.copyWith(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.textMutedDark
                                  : AppColors.textMutedLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: prayerEnabled,
                      activeTrackColor: isDark
                          ? AppColors.primaryDark
                          : AppColors.primaryLight,
                      onChanged: (value) {
                        final current =
                            provider.prayerSchedule ??
                            PrayerLockSchedule(
                              id: 'prayer_default',
                              label: 'Lock During Prayer Times',
                              enabled: value,
                              enabledPrayers: _allPrayerKeys,
                              startOffsetMinutes: 0,
                              durationMinutes: 20,
                            );
                        provider.updatePrayerSchedule(
                          current.copyWith(enabled: value),
                        );
                      },
                    ),
                  ],
                ),
              ),
              if (prayerEnabled) ...[
                Divider(
                  height: 1,
                  thickness: 1,
                  color: isDark
                      ? AppColors.hairlineDark
                      : AppColors.hairlineLight,
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LOCKS DURING',
                        style: plus.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.textMutedDark
                              : AppColors.textMutedLight,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _allPrayerKeys
                            .map(
                              (k) => _buildPrayerChip(
                                k,
                                _prayerLabels[k] ?? k,
                                isDark,
                                prayerKeys,
                                provider,
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Starts before Adhan',
                            style: plus.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.textMainDark
                                  : AppColors.textMainLight,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove, size: 18),
                                onPressed: () {
                                  final newStart = (startOffsetMin - 5).clamp(
                                    0,
                                    60,
                                  );
                                  final s = provider.prayerSchedule;
                                  if (s != null) {
                                    provider.updatePrayerSchedule(
                                      s.copyWith(startOffsetMinutes: newStart),
                                    );
                                  }
                                },
                                style: IconButton.styleFrom(
                                  backgroundColor: isDark
                                      ? AppColors.cardDark
                                      : AppColors.cardLight,
                                  minimumSize: const Size(28, 28),
                                ),
                              ),
                              SizedBox(
                                width: 64,
                                child: Text(
                                  '$startOffsetMin min',
                                  textAlign: TextAlign.center,
                                  style: plus.copyWith(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? AppColors.textMainDark
                                        : AppColors.textMainLight,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add, size: 18),
                                onPressed: () {
                                  final newStart = (startOffsetMin + 5).clamp(
                                    0,
                                    60,
                                  );
                                  final s = provider.prayerSchedule;
                                  if (s != null) {
                                    provider.updatePrayerSchedule(
                                      s.copyWith(startOffsetMinutes: newStart),
                                    );
                                  }
                                },
                                style: IconButton.styleFrom(
                                  backgroundColor: isDark
                                      ? AppColors.cardDark
                                      : AppColors.cardLight,
                                  minimumSize: const Size(28, 28),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Lock duration',
                            style: plus.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.textMainDark
                                  : AppColors.textMainLight,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove, size: 18),
                                onPressed: () {
                                  final newDur = (lockDurationMin - 5).clamp(
                                    5,
                                    120,
                                  );
                                  final s = provider.prayerSchedule;
                                  if (s != null) {
                                    provider.updatePrayerSchedule(
                                      s.copyWith(durationMinutes: newDur),
                                    );
                                  }
                                },
                                style: IconButton.styleFrom(
                                  backgroundColor: isDark
                                      ? AppColors.cardDark
                                      : AppColors.cardLight,
                                  minimumSize: const Size(28, 28),
                                ),
                              ),
                              SizedBox(
                                width: 64,
                                child: Text(
                                  '$lockDurationMin min',
                                  textAlign: TextAlign.center,
                                  style: plus.copyWith(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? AppColors.textMainDark
                                        : AppColors.textMainLight,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add, size: 18),
                                onPressed: () {
                                  final newDur = (lockDurationMin + 5).clamp(
                                    5,
                                    120,
                                  );
                                  final s = provider.prayerSchedule;
                                  if (s != null) {
                                    provider.updatePrayerSchedule(
                                      s.copyWith(durationMinutes: newDur),
                                    );
                                  }
                                },
                                style: IconButton.styleFrom(
                                  backgroundColor: isDark
                                      ? AppColors.cardDark
                                      : AppColors.cardLight,
                                  minimumSize: const Size(28, 28),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPrayerChip(
    String key,
    String label,
    bool isDark,
    Set<String> enabledPrayers,
    FocusLockProvider provider,
  ) {
    final isSelected = enabledPrayers.contains(key);

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (value) {
        final schedule =
            provider.prayerSchedule ??
            PrayerLockSchedule(
              id: 'prayer_default',
              label: 'Lock During Prayer Times',
              enabled: true,
              enabledPrayers: _allPrayerKeys,
              startOffsetMinutes: 0,
              durationMinutes: 20,
            );
        final set = Set<String>.from(schedule.enabledPrayers);
        if (value) {
          set.add(key);
        } else {
          set.remove(key);
        }
        provider.updatePrayerSchedule(
          schedule.copyWith(enabledPrayers: set.toList()),
        );
      },
      backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
      selectedColor: (isDark ? AppColors.primaryDark : AppColors.primaryLight)
          .withValues(alpha: 0.2),
      checkmarkColor: isDark ? AppColors.primaryDark : AppColors.primaryLight,
      labelStyle: GoogleFonts.plusJakartaSans().copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: isSelected
            ? (isDark ? AppColors.primaryDark : AppColors.primaryLight)
            : (isDark ? AppColors.textMainDark : AppColors.textMainLight),
      ),
      side: BorderSide(
        color: isSelected
            ? (isDark ? AppColors.primaryDark : AppColors.primaryLight)
            : (isDark ? AppColors.cardDark : AppColors.cardLight),
        width: 1,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildCustomFocusTimesSection(
    bool isDark,
    TextStyle plus,
    FocusLockProvider provider,
    List<CustomLockSchedule> customSchedules,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CUSTOM FOCUS TIMES',
                style: plus.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.textMutedDark
                      : AppColors.textMutedLight,
                  letterSpacing: 1.2,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _addCustomSchedule(provider),
                icon: const Icon(Icons.add_circle_outline, size: 16),
                label: const Text('Add Custom Time'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark
                      ? AppColors.primaryDark
                      : AppColors.primaryLight,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  textStyle: plus.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (customSchedules.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'No custom focus times yet — tap "Add Custom Time" for blocks like study time or bedtime.',
              style: plus.copyWith(
                fontSize: 11,
                color: isDark
                    ? AppColors.textMutedDark
                    : AppColors.textMutedLight,
              ),
            ),
          )
        else
          ...customSchedules.asMap().entries.map((entry) {
            final schedule = entry.value;
            final String startStr = _fmtTime(schedule.startTime);
            final String endStr = _fmtTime(schedule.endTime);

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.cardLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? AppColors.hairlineDark.withValues(alpha: 0.8)
                        : AppColors.hairlineLight.withValues(alpha: 0.8),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isDark ? Colors.black : Colors.grey).withValues(
                        alpha: 0.08,
                      ),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: schedule.label,
                        style: plus.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.textMainDark
                              : AppColors.textMainLight,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Label',
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                          hintStyle: plus.copyWith(
                            color: isDark
                                ? AppColors.textMutedDark
                                : AppColors.textMutedLight,
                          ),
                        ),
                        onChanged: (value) {
                          provider.updateCustomSchedule(
                            schedule.copyWith(label: value),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildTimeField(
                      startStr,
                      isDark,
                      () => _updateCustomScheduleTime(
                        provider,
                        schedule,
                        isStart: true,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        'to',
                        style: plus.copyWith(
                          fontSize: 10,
                          color: isDark
                              ? AppColors.textMutedDark
                              : AppColors.textMutedLight,
                        ),
                      ),
                    ),
                    _buildTimeField(
                      endStr,
                      isDark,
                      () => _updateCustomScheduleTime(
                        provider,
                        schedule,
                        isStart: false,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Transform.scale(
                      scale: 0.85,
                      child: Switch.adaptive(
                        value: schedule.enabled,
                        activeTrackColor: isDark
                            ? AppColors.primaryDark
                            : AppColors.primaryLight,
                        onChanged: (value) => provider.updateCustomSchedule(
                          schedule.copyWith(enabled: value),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      iconSize: 18,
                      color: AppColors.roseAccent,
                      onPressed: () =>
                          provider.removeCustomSchedule(schedule.id),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  String _fmtTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Widget _buildTimeField(String time, bool isDark, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          time,
          style: GoogleFonts.plusJakartaSans().copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
          ),
        ),
      ),
    );
  }

  Widget _buildUnlockMethodSection(
    bool isDark,
    TextStyle plus,
    FocusLockProvider provider,
    UnlockConfig unlockConfig,
    String currentMethodLabel,
  ) {
    final dividerColor = isDark
        ? AppColors.hairlineDark.withValues(alpha: 0.8)
        : AppColors.hairlineLight.withValues(alpha: 0.8);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(isDark, plus, 'UNLOCK METHOD'),
        const SizedBox(height: 8),
        Column(
          children: [
            _buildUnlockMethodCard(
              isDark,
              plus,
              dividerColor: dividerColor,
              method: 'waitItOut',
              icon: Icons.hourglass_bottom,
              title: 'Wait It Out',
              description: 'A forced countdown — no early exit.',
              isSelected: currentMethodLabel == 'waitItOut',
              onTap: () => provider.updateUnlockConfig(
                unlockConfig.copyWith(method: UnlockMethod.waitItOut),
              ),
            ),
            const SizedBox(height: 10),
            _buildUnlockMethodCard(
              isDark,
              plus,
              dividerColor: dividerColor,
              method: 'markPrayed',
              icon: Icons.check_circle_outline,
              title: 'Mark Prayer as Prayed',
              description: 'Auto-unlocks once you log the prayer.',
              isSelected: currentMethodLabel == 'markPrayed',
              onTap: () => provider.updateUnlockConfig(
                unlockConfig.copyWith(method: UnlockMethod.markPrayed),
              ),
            ),
            const SizedBox(height: 10),
            _buildUnlockMethodCard(
              isDark,
              plus,
              dividerColor: dividerColor,
              method: 'mindfulPause',
              icon: Icons.air,
              title: 'Mindful Pause',
              description: 'A short breathing pause before you continue.',
              isSelected: currentMethodLabel == 'mindfulPause',
              showExtraControl: currentMethodLabel == 'mindfulPause',
              extraControl: _buildMindfulPauseControl(
                isDark,
                plus,
                unlockConfig.mindfulPauseSeconds,
                (v) => provider.updateUnlockConfig(
                  unlockConfig.copyWith(mindfulPauseSeconds: v),
                ),
              ),
              onTap: () => provider.updateUnlockConfig(
                unlockConfig.copyWith(method: UnlockMethod.mindfulPause),
              ),
            ),
            const SizedBox(height: 10),
            _buildUnlockMethodCard(
              isDark,
              plus,
              dividerColor: dividerColor,
              method: 'typePhrase',
              icon: Icons.text_fields,
              title: 'Type a Reminder Phrase',
              description: 'Type a short phrase to confirm your intention.',
              isSelected: currentMethodLabel == 'typePhrase',
              showExtraControl: currentMethodLabel == 'typePhrase',
              extraControl: _buildTypePhraseControl(
                isDark,
                plus,
                unlockConfig.unlockPhrase,
                (v) => provider.updateUnlockConfig(
                  unlockConfig.copyWith(unlockPhrase: v),
                ),
              ),
              onTap: () => provider.updateUnlockConfig(
                unlockConfig.copyWith(method: UnlockMethod.typePhrase),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(bool isDark, TextStyle plus, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: plus.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
        ),
      ),
    );
  }

  Widget _buildUnlockMethodCard(
    bool isDark,
    TextStyle plus, {
    required String method,
    required IconData icon,
    required String title,
    required String description,
    required Color dividerColor,
    required bool isSelected,
    required VoidCallback onTap,
    bool showExtraControl = false,
    Widget? extraControl,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? (isDark ? AppColors.primaryDark : AppColors.primaryLight)
                : (isDark
                      ? AppColors.hairlineDark.withValues(alpha: 0.8)
                      : AppColors.hairlineLight.withValues(alpha: 0.8)),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.black : Colors.grey).withValues(
                alpha: 0.08,
              ),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark
                                ? AppColors.primaryDark
                                : AppColors.primaryLight)
                          : (isDark ? AppColors.cardDark : AppColors.cardLight),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      size: 18,
                      color: isSelected
                          ? Colors.white
                          : (isDark
                                ? AppColors.textMutedDark
                                : AppColors.textMutedLight),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: plus.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.textMainDark
                                : AppColors.textMainLight,
                          ),
                        ),
                        Text(
                          description,
                          style: plus.copyWith(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.textMutedDark
                                : AppColors.textMutedLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isSelected ? Icons.check_circle : Icons.circle_outlined,
                    size: 20,
                    color: isSelected
                        ? (isDark
                              ? AppColors.primaryDark
                              : AppColors.primaryLight)
                        : (isDark
                              ? AppColors.textMutedDark
                              : AppColors.textMutedLight),
                  ),
                ],
              ),
            ),
            if (showExtraControl && extraControl != null) ...[
              Divider(height: 1, thickness: 1, color: dividerColor),
              Padding(padding: const EdgeInsets.all(16), child: extraControl),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMindfulPauseControl(
    bool isDark,
    TextStyle plus,
    int value,
    ValueChanged<int> onChange,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Pause length',
          style: plus.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove, size: 18),
              onPressed: () => onChange((value - 15).clamp(15, 300)),
              style: IconButton.styleFrom(
                backgroundColor: isDark
                    ? AppColors.cardDark
                    : AppColors.cardLight,
                minimumSize: const Size(28, 28),
              ),
            ),
            SizedBox(
              width: 48,
              child: Text(
                '${value}s',
                textAlign: TextAlign.center,
                style: plus.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.textMainDark
                      : AppColors.textMainLight,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add, size: 18),
              onPressed: () => onChange((value + 15).clamp(15, 300)),
              style: IconButton.styleFrom(
                backgroundColor: isDark
                    ? AppColors.cardDark
                    : AppColors.cardLight,
                minimumSize: const Size(28, 28),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTypePhraseControl(
    bool isDark,
    TextStyle plus,
    String phrase,
    ValueChanged<String> onChange,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PHRASE TO TYPE',
          style: plus.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: phrase,
          style: plus.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark ? AppColors.cardDark : AppColors.cardLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            hintText: 'Enter reminder phrase',
            hintStyle: plus.copyWith(
              color: isDark
                  ? AppColors.textMutedDark
                  : AppColors.textMutedLight,
            ),
          ),
          onChanged: onChange,
        ),
      ],
    );
  }

  Widget _buildExceptionsSection(
    bool isDark,
    TextStyle plus,
    FocusLockProvider provider,
    bool allowEmergency,
    int dailySkipAllowance,
    bool preventUninstall,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'EXCEPTIONS & LIMITS',
            style: plus.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? AppColors.textMutedDark
                  : AppColors.textMutedLight,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? AppColors.hairlineDark.withValues(alpha: 0.8)
                  : AppColors.hairlineLight.withValues(alpha: 0.8),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.phone,
                        color: AppColors.success,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Allow Calls & Messages',
                            style: plus.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.textMainDark
                                  : AppColors.textMainLight,
                            ),
                          ),
                          Text(
                            'Emergency contact apps stay unlocked',
                            style: plus.copyWith(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.textMutedDark
                                  : AppColors.textMutedLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: allowEmergency,
                      activeTrackColor: isDark
                          ? AppColors.primaryDark
                          : AppColors.primaryLight,
                      onChanged: (value) => provider.setAllowEmergency(value),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                thickness: 1,
                color: isDark
                    ? AppColors.hairlineDark
                    : AppColors.hairlineLight,
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Daily Skip Allowance',
                            style: plus.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.textMainDark
                                  : AppColors.textMainLight,
                            ),
                          ),
                          Text(
                            'Times you can skip per day',
                            style: plus.copyWith(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.textMutedDark
                                  : AppColors.textMutedLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, size: 18),
                          onPressed: () => provider.setDailySkipAllowance(
                            (dailySkipAllowance - 1).clamp(0, 5),
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: isDark
                                ? AppColors.cardDark
                                : AppColors.cardLight,
                            minimumSize: const Size(28, 28),
                          ),
                        ),
                        SizedBox(
                          width: 48,
                          child: Text(
                            '$dailySkipAllowance',
                            textAlign: TextAlign.center,
                            style: plus.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.textMainDark
                                  : AppColors.textMainLight,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, size: 18),
                          onPressed: () => provider.setDailySkipAllowance(
                            (dailySkipAllowance + 1).clamp(0, 5),
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: isDark
                                ? AppColors.cardDark
                                : AppColors.cardLight,
                            minimumSize: const Size(28, 28),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                thickness: 1,
                color: isDark
                    ? AppColors.hairlineDark
                    : AppColors.hairlineLight,
              ),
              Padding(
                key: _preventUninstallSwitchKey,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.roseAccent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.security,
                        color: AppColors.roseAccent,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Prevent Uninstall During Lock',
                            style: plus.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.textMainDark
                                  : AppColors.textMainLight,
                            ),
                          ),
                          Text(
                            'Requires device admin permission',
                            style: plus.copyWith(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.textMutedDark
                                  : AppColors.textMutedLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: preventUninstall,
                      activeTrackColor: isDark
                          ? AppColors.primaryDark
                          : AppColors.primaryLight,
                      onChanged: (value) => provider.setPreventUninstall(value),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AppDisplayItem {
  final String key;
  final String name;
  final IconData icon;
  final Color color;
  final String packageName;
  final bool fromProvider;

  _AppDisplayItem({
    required this.key,
    required this.name,
    required this.icon,
    required this.color,
    required this.packageName,
    required this.fromProvider,
  });
}
