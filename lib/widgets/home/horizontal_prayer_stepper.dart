import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/providers/prayer_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../screens/settings/prayer_notification_settings_screen.dart';

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

    final plusJakarta = GoogleFonts.plusJakartaSans();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.hairlineDark : AppColors.hairlineLight,
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
                  builder: (_) => const PrayerNotificationSettingsScreen(),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                                  : AppColors.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'TODAY\'S SCHEDULE',
                              style: plusJakarta.copyWith(
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
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: isDark ? 0.18 : 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${prayerProvider.calendar!.hijri.dayOfMonth} ${prayerProvider.calendar!.hijri.monthName} ${prayerProvider.calendar!.hijri.year} AH',
                                  style: plusJakarta.copyWith(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? AppColors.primaryDark
                                        : AppColors.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.chevron_right,
                                size: 16,
                                color: isDark
                                    ? AppColors.textMutedDark
                                    : AppColors.textMutedLight,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    height: 90,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
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
                                    ? AppColors.hairlineDark
                                    : AppColors.hairlineLight,
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
                                    color: isDark
                                        ? AppColors.primaryDark
                                        : AppColors.primary,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
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
        ),
      ),
    );
  }

  double _calculateProgress(
    List<Map<String, dynamic>> prayers,
    PrayerProvider provider,
  ) {
    int currentPrayerIndex = -1;

    for (int i = 0; i < prayers.length; i++) {
      if (prayers[i]['name'] == provider.currentPrayer) {
        currentPrayerIndex = i;
        break;
      }
    }

    if (currentPrayerIndex == -1) {
      int completedCount = 0;
      for (var prayer in prayers) {
        if (provider.isPrayerPassed(prayer['time'] as String)) {
          completedCount++;
        }
      }
      return completedCount.toDouble() / prayers.length;
    }

    return ((currentPrayerIndex + 1) - 0.5) / prayers.length;
  }

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
        : AppColors.primary;
    final mutedColor = isDark
        ? AppColors.textMutedDark
        : AppColors.textMutedLight;
    final plusJakarta = GoogleFonts.plusJakartaSans();

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            time,
            style: plusJakarta.copyWith(
              fontSize: isActive ? 10 : 9,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
              color: isActive
                  ? primaryColor
                  : mutedColor.withValues(alpha: 0.8),
            ),
          ),

          const SizedBox(height: 6),

          SizedBox(
            height: isActive ? 32 : 24,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (isActive)
                  Positioned.fill(child: _PulsingRing(color: primaryColor)),
                Container(
                  width: isActive ? 32 : 24,
                  height: isActive ? 32 : 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isPassed || isActive
                        ? primaryColor
                        : (isDark
                            ? AppColors.cardDark
                            : AppColors.surfaceLight),
                    border: Border.all(
                      color: isActive || isPassed
                          ? (isDark ? AppColors.cardDark : AppColors.cardLight)
                          : (isDark
                              ? AppColors.hairlineDark
                              : AppColors.hairlineLight),
                      width: 4,
                    ),
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

          Text(
            name,
            style: plusJakarta.copyWith(
              fontSize: isActive ? 11 : 10,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
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

  Widget _getCircleContent({
    required bool isPassed,
    required bool isActive,
    required IconData icon,
    required Color primaryColor,
    required Color mutedColor,
  }) {
    if (isPassed) {
      return Icon(Icons.check, size: isActive ? 16 : 12, color: Colors.white);
    } else if (isActive) {
      return Icon(icon, size: 16, color: Colors.white);
    } else {
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
      begin: 0.5,
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
                color: widget.color.withValues(alpha: 0.35),
              ),
            ),
          ),
        );
      },
    );
  }
}
