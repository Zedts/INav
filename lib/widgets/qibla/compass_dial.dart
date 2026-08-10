import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/providers/qibla_provider.dart';
import '../../core/theme/app_colors.dart';

/// The Qibla compass dial: minimalist face, rotating ring with ticks, cardinal
/// labels and the Kaaba pin sitting on the dial's circumference, center
/// readout and the accuracy badge underneath.
///
/// The compass starts automatically — there is no enable overlay or
/// manual mode.
class CompassDial extends StatelessWidget {
  /// Diameter of the dial face
  static const double _dialSize = 260;

  /// Outer box size — extra room so the Kaaba pin can sit on the rim
  static const double _outerSize = 320;

  static const double _inset = (_outerSize - _dialSize) / 2;

  final double heading;
  final double? bearing;
  final CompassStatus status;
  final bool isAligned;
  final String guidanceText;

  const CompassDial({
    super.key,
    required this.heading,
    required this.bearing,
    required this.status,
    required this.isAligned,
    required this.guidanceText,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        SizedBox(
          width: _outerSize,
          height: _outerSize,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Fixed "current facing" pointer above the dial
              Positioned(
                top: _inset - 34,
                left: 0,
                right: 0,
                child: Icon(
                  Icons.arrow_drop_down,
                  size: 40,
                  color: isAligned
                      ? AppColors.primary
                      : (isDark
                          ? AppColors.textMutedDark
                          : AppColors.textMutedLight),
                ),
              ),

              // Minimalist dial face with decorative rings
              Center(
                child: SizedBox(
                  width: _dialSize,
                  height: _dialSize,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark
                                ? AppColors.cardDark
                                : AppColors.cardLight,
                            border: Border.all(
                              color: isDark
                                  ? AppColors.hairlineDark
                                  : AppColors.hairlineLight,
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
                        ),
                      ),

                      // Decorative dashed ring
                      Positioned.fill(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: CustomPaint(
                            painter: _DashedCirclePainter(
                              color: isDark
                                  ? AppColors.textMutedDark
                                      .withValues(alpha: 0.4)
                                  : AppColors.textMutedLight
                                      .withValues(alpha: 0.4),
                            ),
                          ),
                        ),
                      ),
                      // Decorative solid inner ring
                      Positioned.fill(
                        child: Container(
                          margin: const EdgeInsets.all(36),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark
                                  ? AppColors.hairlineDark
                                  : AppColors.hairlineLight,
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Rotating layer: ticks, cardinal labels, Kaaba pin
              Positioned.fill(
                child: Transform.rotate(
                  angle: -heading * math.pi / 180,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _TicksPainter(
                            isDark: isDark,
                            dialRadius: _dialSize / 2,
                          ),
                        ),
                      ),
                      ..._buildCardinalLabels(isDark),
                      if (bearing != null) _buildKaabaPin(),
                    ],
                  ),
                ),
              ),

              // Center readout
              Center(child: _buildCenterReadout(isDark)),
            ],
          ),
        ),

        // Accuracy status badge
        const SizedBox(height: 12),
        _buildAccuracyBadge(isDark),
      ],
    );
  }

  List<Widget> _buildCardinalLabels(bool isDark) {
    const labels = [
      (angle: 0.0, text: 'N', major: true),
      (angle: 45.0, text: 'NE', major: false),
      (angle: 90.0, text: 'E', major: true),
      (angle: 135.0, text: 'SE', major: false),
      (angle: 180.0, text: 'S', major: true),
      (angle: 225.0, text: 'SW', major: false),
      (angle: 270.0, text: 'W', major: true),
      (angle: 315.0, text: 'NW', major: false),
    ];

    return labels.map((label) {
      final angleRad = label.angle * math.pi / 180;
      final headingRad = heading * math.pi / 180;

      final Color color;
      final double fontSize;
      if (label.text == 'N') {
        color = AppColors.roseAccent;
        fontSize = 14;
      } else if (label.major) {
        color = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
        fontSize = 12;
      } else {
        color = isDark
            ? AppColors.textMutedDark.withValues(alpha: 0.65)
            : AppColors.textMutedLight.withValues(alpha: 0.65);
        fontSize = 10;
      }

      return Positioned.fill(
        child: Transform.rotate(
          angle: angleRad,
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: _inset + (label.major ? 14 : 18)),
              child: Transform.rotate(
                // Counter-rotation keeps the label upright
                angle: headingRad - angleRad,
                child: Text(
                  label.text,
                  style: GoogleFonts.plusJakartaSans().copyWith(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildKaabaPin() {
    final bearingRad = bearing! * math.pi / 180;
    final headingRad = heading * math.pi / 180;

    // The pin column is ~54px tall; a top padding of 3px places its center
    // at radius 130 — exactly on the dial's circumference.
    return Positioned.fill(
      child: Transform.rotate(
        angle: bearingRad,
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Transform.rotate(
              // Counter-rotation keeps the pin upright
              angle: headingRad - bearingRad,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.cardDark,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.roseAccent,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              Colors.black.withValues(alpha: 0.15),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.mosque,
                      size: 18,
                      color: AppColors.roseAccent,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.roseAccent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'KAABA',
                      style: GoogleFonts.plusJakartaSans().copyWith(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                        color: Colors.white,
                      ),
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

  Widget _buildCenterReadout(bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: 112,
      height: 112,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceDark
            : AppColors.surfaceLight,
        shape: BoxShape.circle,
        border: Border.all(
          color: isAligned
              ? AppColors.primary.withValues(alpha: 0.7)
              : isDark
                  ? AppColors.hairlineDark
                  : AppColors.hairlineLight,
          width: 1,
        ),
        boxShadow: isAligned
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  blurRadius: 3,
                  spreadRadius: 2,
                ),
              ]
            : [],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.explore,
            size: 20,
            color: isDark ? AppColors.primaryDark : AppColors.primary,
          ),
          const SizedBox(height: 2),
          Text(
            '${heading.round()}°',
            style: GoogleFonts.fraunces().copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
              color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              guidanceText.toUpperCase(),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans().copyWith(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                height: 1.2,
                color: isAligned
                    ? AppColors.primary
                    : isDark
                        ? AppColors.textMutedDark
                        : AppColors.textMutedLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccuracyBadge(bool isDark) {
    final (Color dotColor, Color textColor, String label) = switch (status) {
      CompassStatus.calibrated => (
          AppColors.primary,
          isDark ? AppColors.primaryDark : AppColors.primary,
          'Calibrated',
        ),
      CompassStatus.approximate => (
          AppColors.roseAccent,
          isDark ? AppColors.roseAccent.withValues(alpha: 0.9) : AppColors.roseAccent,
          'Approximate',
        ),
      CompassStatus.unavailable => (
          AppColors.roseAccent,
          isDark ? AppColors.roseAccent.withValues(alpha: 0.9) : AppColors.roseAccent,
          'Sensor unavailable',
        ),
      CompassStatus.initializing => (
          AppColors.textMutedLight,
          isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
          'Starting compass…',
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(999),
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans().copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Draws the 24 tick marks around the dial (every 15°, every 6th is major)
class _TicksPainter extends CustomPainter {
  final bool isDark;
  final double dialRadius;

  _TicksPainter({required this.isDark, required this.dialRadius});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = dialRadius - 6;

    final minorPaint = Paint()
      ..color = isDark
          ? AppColors.textMutedDark.withValues(alpha: 0.3)
          : AppColors.textMutedLight.withValues(alpha: 0.35)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final majorPaint = Paint()
      ..color = isDark
          ? AppColors.textMutedDark.withValues(alpha: 0.55)
          : AppColors.textMutedLight.withValues(alpha: 0.6)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 24; i++) {
      final angle = i * 15 * math.pi / 180;
      final major = i % 6 == 0;
      final length = major ? 14.0 : 10.0;
      final p1 = center +
          Offset(math.sin(angle), -math.cos(angle)) * outerRadius;
      final p2 = center +
          Offset(math.sin(angle), -math.cos(angle)) * (outerRadius - length);
      canvas.drawLine(p1, p2, major ? majorPaint : minorPaint);
    }
  }

  @override
  bool shouldRepaint(_TicksPainter oldDelegate) =>
      oldDelegate.isDark != isDark || oldDelegate.dialRadius != dialRadius;
}

/// Draws a dashed circular border
class _DashedCirclePainter extends CustomPainter {
  final Color color;

  _DashedCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const dashCount = 60;
    const dashRatio = 0.55;
    final step = 2 * math.pi / dashCount;
    for (var i = 0; i < dashCount; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * step,
        step * dashRatio,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DashedCirclePainter oldDelegate) =>
      oldDelegate.color != color;
}
