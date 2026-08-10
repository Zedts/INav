import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/models/qibla_model.dart';
import '../../core/theme/app_colors.dart';

class QiblaHeroBanner extends StatelessWidget {
  final QiblaModel? qiblaData;
  final String cityName;
  final bool isAligned;

  const QiblaHeroBanner({
    super.key,
    required this.qiblaData,
    required this.cityName,
    required this.isAligned,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bearingText = qiblaData != null
        ? '${qiblaData!.direction.round()}° ${qiblaData!.cardinalDirection}'
        : '--°';
    final distanceText = qiblaData != null ? qiblaData!.formattedDistance : '-- km';
    final sublineText = qiblaData != null
        ? 'Direction to Makkah from $cityName'
        : 'Calculating direction to Makkah...';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: isAligned
              ? [
                  BoxShadow(
                    color: AppColors.success.withValues(alpha: 0.2),
                    blurRadius: 3,
                    spreadRadius: -5,
                  ),
                ]
              : [
                  BoxShadow(
                    color: const Color(0xFF4F46E5).withValues(alpha: 0.2),
                    blurRadius: 3,
                    spreadRadius: -10,
                    offset: const Offset(-20, -20),
                  ),
                  BoxShadow(
                    color: AppColors.roseAccent.withValues(alpha: 0.2),
                    blurRadius: 3,
                    spreadRadius: -10,
                    offset: const Offset(20, 20),
                  ),
                  BoxShadow(
                    color: AppColors.teal.withValues(alpha: 0.15),
                    blurRadius: 3,
                    spreadRadius: -15,
                    offset: const Offset(0, 10),
                  ),
                ],
        ),
        child: Container(
          constraints: const BoxConstraints(minHeight: 110),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isAligned
                  ? AppColors.success.withValues(alpha: 0.8)
                  : isDark
                      ? AppColors.hairlineDark
                      : AppColors.hairlineLight,
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildBadge(isDark),
                          const SizedBox(height: 6),
                          Text(
                            bearingText,
                            style: GoogleFonts.fraunces(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                              color: isDark
                                  ? Colors.white
                                  : AppColors.textMainLight,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            sublineText,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.textMutedDark
                                  : AppColors.textMutedLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'DISTANCE',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                            color: isDark
                                ? AppColors.textMutedDark
                                : AppColors.textMutedLight,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          distanceText,
                          style: GoogleFonts.fraunces(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                            color: isDark
                                ? Colors.white
                                : AppColors.textMainLight,
                          ),
                        ),
                      ],
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

  Widget _buildBadge(bool isDark) {
    if (isAligned) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.success,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.success.withValues(alpha: 0.2),
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 8,
              height: 8,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'ALIGNED WITH KAABA',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 8,
            height: 8,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.roseAccent,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'QIBLA BEARING',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: isDark
                  ? const Color(0xFFE0E7FF)
                  : const Color(0xFF312E81),
            ),
          ),
        ],
      ),
    );
  }
}
