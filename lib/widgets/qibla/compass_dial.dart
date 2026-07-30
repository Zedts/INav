import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:glass/glass.dart';

import '../../core/providers/qibla_provider.dart';

/// The Qibla compass dial: glass face, rotating ring with ticks, cardinal
/// labels and the Kaaba pin sitting on the dial's circumference, center
/// readout and the accuracy badge underneath.
///
/// The compass starts automatically — there is no enable overlay or
/// manual mode.
class CompassDial extends StatelessWidget {
  /// Diameter of the glass dial face
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
                      ? const Color(0xFF10B981)
                      : const Color(0xFF94A3B8),
                ),
              ),

              // Glass dial face with decorative rings
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
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: isDark
                                  ? [
                                      const Color(0xFF0F172A)
                                          .withValues(alpha: 0.55),
                                      const Color(0xFF0F172A)
                                          .withValues(alpha: 0.25),
                                    ]
                                  : [
                                      Colors.white.withValues(alpha: 0.35),
                                      Colors.white.withValues(alpha: 0.12),
                                    ],
                            ),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.18)
                                  : Colors.white.withValues(alpha: 0.45),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isDark
                                    ? Colors.black.withValues(alpha: 0.5)
                                    : const Color(0xFF4F46E5)
                                        .withValues(alpha: 0.18),
                                blurRadius: 40,
                                offset: const Offset(0, 18),
                              ),
                            ],
                          ),
                          child: DecoratedBox(
                            // Diagonal specular reflection
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
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
                            ),
                          ),
                        ).asGlass(
                          blurX: isDark ? 32 : 28,
                          blurY: isDark ? 32 : 28,
                          tintColor: Colors.transparent,
                          frosted: true,
                          clipBorderRadius:
                              BorderRadius.circular(_dialSize / 2),
                        ),
                      ),

                      // Decorative dashed ring
                      Positioned.fill(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: CustomPaint(
                            painter: _DashedCirclePainter(
                              color: isDark
                                  ? const Color(0xFF334155)
                                      .withValues(alpha: 0.6)
                                  : const Color(0xFFCBD5E1)
                                      .withValues(alpha: 0.6),
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
                                  ? const Color(0xFF1E293B)
                                      .withValues(alpha: 0.5)
                                  : const Color(0xFFE2E8F0)
                                      .withValues(alpha: 0.7),
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
        color = const Color(0xFFF43F5E);
        fontSize = 14;
      } else if (label.major) {
        color = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
        fontSize = 12;
      } else {
        color = isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
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
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w900,
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
                      color: const Color(0xFF0F172A),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFFBBF24),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              const Color(0xFFF59E0B).withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.mosque,
                      size: 18,
                      color: Color(0xFFFBBF24),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'KAABA',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.3,
                        color: Color(0xFF0F172A),
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
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.3),
        shape: BoxShape.circle,
        border: Border.all(
          color: isAligned
              ? const Color(0xFF10B981).withValues(alpha: 0.7)
              : isDark
                  ? Colors.white.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.6),
          width: 1,
        ),
        boxShadow: isAligned
            ? [
                BoxShadow(
                  color: const Color(0xFF10B981).withValues(alpha: 0.35),
                  blurRadius: 24,
                  spreadRadius: 4,
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
            color: isDark ? const Color(0xFF818CF8) : const Color(0xFF4F46E5),
          ),
          const SizedBox(height: 2),
          Text(
            '${heading.round()}°',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              fontFeatures: const [FontFeature.tabularFigures()],
              color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
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
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                height: 1.2,
                color: isAligned
                    ? const Color(0xFF10B981)
                    : isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
              ),
            ),
          ),
        ],
      ),
    ).asGlass(
      blurX: 16,
      blurY: 16,
      tintColor: Colors.transparent,
      frosted: true,
      clipBorderRadius: BorderRadius.circular(56),
    );
  }

  Widget _buildAccuracyBadge(bool isDark) {
    final (Color dotColor, Color textColor, String label) = switch (status) {
      CompassStatus.calibrated => (
          const Color(0xFF10B981),
          isDark ? const Color(0xFF34D399) : const Color(0xFF059669),
          'Calibrated',
        ),
      CompassStatus.approximate => (
          const Color(0xFFF59E0B),
          isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706),
          'Approximate',
        ),
      CompassStatus.unavailable => (
          const Color(0xFFF43F5E),
          isDark ? const Color(0xFFFB7185) : const Color(0xFFE11D48),
          'Sensor unavailable',
        ),
      CompassStatus.initializing => (
          const Color(0xFF94A3B8),
          isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          'Starting compass…',
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
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
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
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
          ? const Color(0xFF94A3B8).withValues(alpha: 0.3)
          : const Color(0xFF64748B).withValues(alpha: 0.35)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final majorPaint = Paint()
      ..color = isDark
          ? const Color(0xFF94A3B8).withValues(alpha: 0.55)
          : const Color(0xFF64748B).withValues(alpha: 0.6)
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
