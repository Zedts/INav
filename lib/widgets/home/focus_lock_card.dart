import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/prayer_provider.dart';
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
    final plusJakarta = GoogleFonts.plusJakartaSans();

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
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.success,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Active',
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
                              '3 apps locked during all 5 prayers',
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
                              'Next lock: $nextPrayer in $formattedCountdown',
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

                      SizedBox(
                        width: 72,
                        height: 32,
                        child: Stack(
                          children: [
                            Positioned(
                              left: 0,
                              child: _buildAppIcon(
                                Icons.photo_camera,
                                const Color(0xFFD946EF),
                                isDark,
                              ),
                            ),
                            Positioned(
                              left: 24,
                              child: _buildAppIcon(
                                Icons.music_note,
                                isDark
                                    ? const Color(0xFFE2E8F0)
                                    : AppColors.textMutedLight,
                                isDark,
                              ),
                            ),
                            Positioned(
                              left: 48,
                              child: _buildAppIcon(
                                Icons.play_circle_filled,
                                const Color(0xFFEF4444),
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
