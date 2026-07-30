import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/prayer_provider.dart';
import '../../core/theme/app_colors.dart';

/// Horizontal prayer stepper timeline matching the reference design
/// Shows 5 prayers in a row with progress line and proper states
class HorizontalPrayerStepper extends StatelessWidget {
  const HorizontalPrayerStepper({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final prayerProvider = context.watch<PrayerProvider>();

    if (prayerProvider.prayerTimes == null) {
      return const SizedBox.shrink();
    }

    final prayers = [
      {
        'name': 'Fajr',
        'time': prayerProvider.prayerTimes!.fajr,
        'icon': Icons.wb_twilight,
      },
      {
        'name': 'Dhuhr',
        'time': prayerProvider.prayerTimes!.dhuhr,
        'icon': Icons.wb_sunny,
      },
      {
        'name': 'Asr',
        'time': prayerProvider.prayerTimes!.asr,
        'icon': Icons.wb_sunny_outlined,
      },
      {
        'name': 'Maghrib',
        'time': prayerProvider.prayerTimes!.maghrib,
        'icon': Icons.wb_twilight,
      },
      {
        'name': 'Isha',
        'time': prayerProvider.prayerTimes!.isha,
        'icon': Icons.nightlight_round,
      },
    ];

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
        child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 16,
                            color: isDark
                                ? AppColors.primaryDark
                                : AppColors.primaryLight,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'TODAY\'S SCHEDULE',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.textMutedDark
                                  : AppColors.textMutedLight,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      if (prayerProvider.calendar != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                (isDark
                                        ? AppColors.primaryDark
                                        : AppColors.primaryLight)
                                    .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${prayerProvider.calendar!.hijri.dayOfMonth} ${prayerProvider.calendar!.hijri.monthName} ${prayerProvider.calendar!.hijri.year} AH',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.primaryDark
                                  : AppColors.primaryLight,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Stepper Container
                SizedBox(
                  height: 90,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Progress line background - aligned at 31px to match HTML ref
                      Positioned(
                        top: 31,
                        left: 0,
                        right: 0,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF334155) // slate-700
                                  : const Color(0xFFE2E8F0), // slate-200
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: _calculateProgress(
                                prayers,
                                prayerProvider,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      isDark
                                          ? AppColors.primaryDark
                                          : AppColors.primaryLight,
                                      isDark
                                          ? const Color(0xFF3B82F6)
                                          : const Color(0xFF60A5FA),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          (isDark
                                                  ? AppColors.primaryDark
                                                  : AppColors.primaryLight)
                                              .withValues(alpha: 0.5),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Prayer steps
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: prayers.map((prayer) {
                            final name = prayer['name'] as String;
                            final time = prayer['time'] as String;
                            final icon = prayer['icon'] as IconData;
                            final isActive =
                                name == prayerProvider.currentPrayer;
                            final isPassed = prayerProvider.isPrayerPassed(
                              time,
                            );

                            return _buildPrayerStep(
                              context,
                              name: name,
                              time: time,
                              icon: icon,
                              isActive: isActive,
                              isPassed: isPassed,
                              isDark: isDark,
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ),
    );
  }

  /// Calculate progress percentage (0.0 to 1.0)
  /// Progress fills up to and stops at the current prayer dot
  double _calculateProgress(
    List<Map<String, dynamic>> prayers,
    PrayerProvider provider,
  ) {
    // Find the index of the current prayer
    int currentPrayerIndex = -1;

    for (int i = 0; i < prayers.length; i++) {
      if (prayers[i]['name'] == provider.currentPrayer) {
        currentPrayerIndex = i;
        break;
      }
    }

    // If current prayer not found, calculate based on passed prayers
    if (currentPrayerIndex == -1) {
      int completedCount = 0;
      for (var prayer in prayers) {
        if (provider.isPrayerPassed(prayer['time'] as String)) {
          completedCount++;
        }
      }
      return completedCount.toDouble() / prayers.length;
    }

    // Progress fills from start to current prayer position
    // Each prayer represents 1/5 of the total width (0.2)
    // We add 0.5 to reach the center of the current prayer dot
    return ((currentPrayerIndex + 1) - 0.5) / prayers.length;
  }

  /// Build individual prayer step
  Widget _buildPrayerStep(
    BuildContext context, {
    required String name,
    required String time,
    required IconData icon,
    required bool isActive,
    required bool isPassed,
    required bool isDark,
  }) {
    final primaryColor = isDark
        ? AppColors.primaryDark
        : AppColors.primaryLight;
    final mutedColor = isDark
        ? AppColors.textMutedDark
        : AppColors.textMutedLight;

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Time above circle
          Text(
            time,
            style: TextStyle(
              fontSize: isActive ? 10 : 9,
              fontWeight: isActive ? FontWeight.w900 : FontWeight.w700,
              color: isActive
                  ? primaryColor
                  : mutedColor.withValues(alpha: 0.8),
            ),
          ),

          const SizedBox(height: 6),

          // Circle with state - centered at line position
          SizedBox(
            height: isActive ? 32 : 24,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Pulsing animation for active prayer only
                if (isActive)
                  Positioned.fill(child: _PulsingRing(color: primaryColor)),

                // Main circle - w-6 h-6 (24px) normal, w-8 h-8 (32px) active
                Container(
                  width: isActive ? 32 : 24,
                  height: isActive ? 32 : 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isActive
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              primaryColor,
                              isDark
                                  ? const Color(0xFF3B82F6)
                                  : const Color(0xFF60A5FA),
                            ],
                          )
                        : null,
                    color: isPassed
                        ? primaryColor
                        : isDark
                        ? const Color(0xFF1E293B).withValues(alpha: 0.8)
                        : const Color(0xFFF1F5F9),
                    border: Border.all(
                      color: isActive || isPassed
                          ? Colors.white
                          : isDark
                          ? const Color(0xFF475569) // slate-600
                          : const Color(0xFFCBD5E1), // slate-300
                      width: 4,
                    ),
                    boxShadow: isActive || isPassed
                        ? [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: 0.3),
                              blurRadius: isActive ? 8 : 4,
                              spreadRadius: isActive ? 1 : 0,
                            ),
                          ]
                        : null,
                  ),
                  child: _getCircleContent(
                    isPassed: isPassed,
                    isActive: isActive,
                    icon: icon,
                    primaryColor: primaryColor,
                    mutedColor: mutedColor,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // Prayer name below circle
          Text(
            name,
            style: TextStyle(
              fontSize: isActive ? 11 : 10,
              fontWeight: isActive ? FontWeight.w900 : FontWeight.w600,
              color: isActive
                  ? primaryColor
                  : isPassed
                  ? mutedColor
                  : mutedColor.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  /// Get circle content based on state
  Widget _getCircleContent({
    required bool isPassed,
    required bool isActive,
    required IconData icon,
    required Color primaryColor,
    required Color mutedColor,
  }) {
    if (isPassed) {
      // Completed: Show checkmark
      return Icon(Icons.check, size: isActive ? 16 : 12, color: Colors.white);
    } else if (isActive) {
      // Active: Show prayer icon
      return Icon(icon, size: 16, color: Colors.white);
    } else {
      // Upcoming: Show small dot
      return Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: mutedColor.withValues(alpha: 0.3),
        ),
      );
    }
  }
}

/// Pulsing ring animation for active prayer
class _PulsingRing extends StatefulWidget {
  final Color color;

  const _PulsingRing({required this.color});

  @override
  State<_PulsingRing> createState() => _PulsingRingState();
}

class _PulsingRingState extends State<_PulsingRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _opacityAnimation = Tween<double>(
      begin: 0.6,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withValues(alpha: 0.4),
              ),
            ),
          ),
        );
      },
    );
  }
}
