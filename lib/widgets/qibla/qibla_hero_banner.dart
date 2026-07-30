import 'package:flutter/material.dart';
import 'package:glass/glass.dart';
import '../../core/models/qibla_model.dart';

/// Hero banner for the Qibla screen: bearing badge + headline + distance.
/// Glows emerald while the device is facing the Qibla.
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
                    color: const Color(0xFF10B981).withValues(alpha: 0.6),
                    blurRadius: 45,
                    spreadRadius: -5,
                  ),
                ]
              : [
                  // Indigo glow (top-left)
                  BoxShadow(
                    color: const Color(0xFF4F46E5).withValues(alpha: 0.3),
                    blurRadius: 60,
                    spreadRadius: -10,
                    offset: const Offset(-20, -20),
                  ),
                  // Amber glow (bottom-right)
                  BoxShadow(
                    color: const Color(0xFFD97706).withValues(alpha: 0.25),
                    blurRadius: 70,
                    spreadRadius: -10,
                    offset: const Offset(20, 20),
                  ),
                  // Teal glow (center)
                  BoxShadow(
                    color: const Color(0xFF0D9488).withValues(alpha: 0.15),
                    blurRadius: 50,
                    spreadRadius: -15,
                    offset: const Offset(0, 10),
                  ),
                ],
        ),
        child: Container(
          constraints: const BoxConstraints(minHeight: 110),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0xFF0F172A).withValues(alpha: 0.55),
                      const Color(0xFF0F172A).withValues(alpha: 0.25),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.35),
                      Colors.white.withValues(alpha: 0.12),
                    ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isAligned
                  ? const Color(0xFF10B981).withValues(alpha: 0.8)
                  : isDark
                      ? Colors.white.withValues(alpha: 0.18)
                      : Colors.white.withValues(alpha: 0.45),
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              // Diagonal specular reflection (glass sheen)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: const Alignment(-1.0, -1.0),
                      end: const Alignment(0.6, 0.6),
                      colors: isDark
                          ? [
                              Colors.white.withValues(alpha: 0.04),
                              Colors.white.withValues(alpha: 0.01),
                              Colors.transparent,
                            ]
                          : [
                              Colors.white.withValues(alpha: 0.45),
                              Colors.white.withValues(alpha: 0.1),
                              Colors.transparent,
                            ],
                      stops: const [0.0, 0.35, 0.6],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),

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
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF0F172A),
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            sublineText,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? const Color(0xFFCBD5E1)
                                  : const Color(0xFF334155),
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
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF475569),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          distanceText,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).asGlass(
          blurX: isDark ? 32 : 28,
          blurY: isDark ? 32 : 28,
          tintColor: Colors.transparent,
          frosted: true,
          clipBorderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }

  Widget _buildBadge(bool isDark) {
    if (isAligned) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFF10B981),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10B981).withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 8,
              height: 8,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            SizedBox(width: 6),
            Text(
              'ALIGNED WITH KAABA',
              style: TextStyle(
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
            : Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.4),
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
                color: Color(0xFFF59E0B),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'QIBLA BEARING',
            style: TextStyle(
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
