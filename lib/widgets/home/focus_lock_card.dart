import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/prayer_provider.dart';
import '../../screens/settings/focus_lock_config_screen.dart';

/// Focus Lock summary card - entire card is tappable to open configuration
/// Shows lock status, number of apps locked, and next lock window
class FocusLockCard extends StatelessWidget {
  const FocusLockCard({super.key});

  /// Formats countdown to show only minutes to hours (no seconds, no days)
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

    // Get next prayer info for countdown
    final nextPrayer = prayerProvider.nextPrayer;
    final timeUntilNext = prayerProvider.timeRemaining;
    final formattedCountdown = _formatNextLockCountdown(timeUntilNext);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? AppColors.borderDark.withValues(alpha: 0.8)
              : AppColors.borderLight.withValues(alpha: 0.8),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.grey).withValues(alpha: 0.1),
            blurRadius: 10,
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
                  // Header row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lock_rounded,
                            size: 16,
                            color: const Color(0xFFE11D48), // rose
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'FOCUS LOCK',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFE11D48),
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

                  // Main content row
                  Row(
                    children: [
                      // Left side: Status and info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Status indicator
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF10B981), // emerald-500
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Active',
                                  style: TextStyle(
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

                            // Summary text
                            Text(
                              '3 apps locked during all 5 prayers',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.textMutedDark
                                    : AppColors.textMutedLight,
                                height: 1.5,
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Next lock window - real-time countdown
                            Text(
                              'Next lock: $nextPrayer in $formattedCountdown',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? const Color(0xFF64748B) // slate-500
                                    : const Color(0xFF94A3B8), // slate-400
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Right side: App preview stack with overlapping icons
                      SizedBox(
                        width: 72, // 32 + 24 + 16 (3 icons with overlap)
                        height: 32,
                        child: Stack(
                          children: [
                            Positioned(
                              left: 0,
                              child: _buildAppIcon(
                                Icons.photo_camera,
                                const Color(0xFFD946EF), // fuchsia-500
                                isDark,
                              ),
                            ),
                            Positioned(
                              left: 24,
                              child: _buildAppIcon(
                                Icons.music_note,
                                isDark
                                    ? const Color(0xFFE2E8F0) // slate-200
                                    : const Color(0xFF475569), // slate-600
                                isDark,
                              ),
                            ),
                            Positioned(
                              left: 48,
                              child: _buildAppIcon(
                                Icons.play_circle_filled,
                                const Color(0xFFEF4444), // red-500
                                isDark,
                              ),
                            ),
                          ],
                        ),
                      ),
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
