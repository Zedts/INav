// ignore_for_file: non_const_argument_for_const_parameter

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/prayer_provider.dart';
import '../../core/providers/focus_lock_provider.dart';
import '../../core/constants/default_apps.dart';
import '../../screens/settings/focus_lock_config_screen.dart';

class FocusLockCard extends StatelessWidget {
  const FocusLockCard({super.key});

  String _formatNextLockCountdown(Duration duration) {
    if (duration.isNegative) return 'Now';

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final prayerProvider = context.watch<PrayerProvider>();
    final focusLockProvider = context.watch<FocusLockProvider>();
    final plusJakarta = GoogleFonts.plusJakartaSans();

    final nextPrayer = prayerProvider.nextPrayer;
    final timeUntilNext = prayerProvider.timeRemaining;
    final formattedCountdown = _formatNextLockCountdown(timeUntilNext);

    // Get real-time status
    final isEnabled = focusLockProvider.masterEnabled;
    final lockedAppsCount = focusLockProvider.lockedApps.length;
    final prayerSchedule = focusLockProvider.prayerSchedule;
    final enabledPrayersCount = prayerSchedule?.enabledPrayers.length ?? 0;
    final isCurrentlyLocked = focusLockProvider.isInLockWindow();
    final activePrayer = focusLockProvider.getActivePrayerName();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
            color: (isDark ? Colors.black : Colors.grey).withValues(alpha: 0.1),
            blurRadius: 3,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FocusLockConfigScreen(),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lock_rounded,
                            size: 16,
                            color: AppColors.roseAccent,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'FOCUS LOCK',
                            style: plusJakarta.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.roseAccent,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: isDark
                            ? AppColors.textMutedDark
                            : AppColors.textMutedLight,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isEnabled
                                        ? (isCurrentlyLocked
                                              ? AppColors.warning
                                              : AppColors.success)
                                        : AppColors.textMutedDark,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  isEnabled
                                      ? (isCurrentlyLocked
                                            ? 'Locked'
                                            : 'Active')
                                      : 'Disabled',
                                  style: plusJakarta.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: isDark
                                        ? AppColors.textMainDark
                                        : AppColors.textMainLight,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            Text(
                              isEnabled
                                  ? isCurrentlyLocked
                                        ? 'Currently blocking $lockedAppsCount apps during ${activePrayer ?? "prayer"}'
                                        : '$lockedAppsCount ${lockedAppsCount == 1 ? "app" : "apps"} locked during $enabledPrayersCount ${enabledPrayersCount == 1 ? "prayer" : "prayers"}'
                                  : 'Tap to enable focus lock',
                              style: plusJakarta.copyWith(
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.textMutedDark
                                    : AppColors.textMutedLight,
                                height: 1.5,
                              ),
                            ),

                            const SizedBox(height: 12),

                            Text(
                              isEnabled && !isCurrentlyLocked
                                  ? 'Next lock: $nextPrayer in $formattedCountdown'
                                  : isCurrentlyLocked
                                  ? 'Lock active now'
                                  : 'Configure lock settings',
                              style: plusJakarta.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.textMutedLight
                                    : AppColors.textMutedDark,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 12),

                      if (lockedAppsCount > 0) ...[
                        SizedBox(
                          width: lockedAppsCount >= 3
                              ? 72
                              : (lockedAppsCount * 32.0),
                          height: 32,
                          child: Stack(
                            children: List.generate(
                              lockedAppsCount > 3 ? 3 : lockedAppsCount,
                              (index) {
                                final app = focusLockProvider.lockedApps[index];
                                final defaultApp = DefaultApps.getApp(
                                  app.packageName,
                                );

                                final iconData = defaultApp != null
                                    ? IconData(
                                        defaultApp.iconCodePoint,
                                        fontFamily: defaultApp.iconFontFamily,
                                        fontPackage: defaultApp.iconFontPackage,
                                        matchTextDirection:
                                            defaultApp.iconMatchTextDirection,
                                      )
                                    : Icons.apps;

                                return Positioned(
                                  left: index * 24.0,
                                  child: _buildAppIcon(
                                    iconData,
                                    defaultApp?.color ?? AppColors.primaryDark,
                                    isDark,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppIcon(IconData icon, Color color, bool isDark) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.cardDark : Colors.white,
          width: 2,
        ),
      ),
      child: Icon(icon, size: 16, color: color),
    );
  }
}
