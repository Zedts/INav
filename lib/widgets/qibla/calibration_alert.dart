import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class CalibrationAlert extends StatefulWidget {
  const CalibrationAlert({super.key});

  @override
  State<CalibrationAlert> createState() => _CalibrationAlertState();
}

class _CalibrationAlertState extends State<CalibrationAlert>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.roseAccent.withValues(alpha: 0.1)
              : const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? AppColors.roseAccent.withValues(alpha: 0.3)
                : AppColors.roseAccent.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final t = _controller.value;
                final phase = (t * 4) % 4;
                double dx = 0, dy = 0, angle = 0;
                if (phase < 1) {
                  dx = 6 * phase;
                  dy = -4 * phase;
                  angle = 0.26 * phase;
                } else if (phase < 2) {
                  dx = 6 * (2 - phase);
                  dy = -4 * (2 - phase);
                  angle = 0.26 * (2 - phase);
                } else if (phase < 3) {
                  dx = -6 * (phase - 2);
                  dy = -4 * (phase - 2);
                  angle = -0.26 * (phase - 2);
                } else {
                  dx = -6 * (4 - phase);
                  dy = -4 * (4 - phase);
                  angle = -0.26 * (4 - phase);
                }
                return Transform.translate(
                  offset: Offset(dx, dy),
                  child: Transform.rotate(angle: angle, child: child),
                );
              },
              child: Icon(
                Icons.sync,
                size: 26,
                color: AppColors.roseAccent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Compass needs calibration',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.roseAccent
                          : AppColors.textMainLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Move your phone in a figure-8 motion a few times.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.roseAccent.withValues(alpha: 0.7)
                          : AppColors.roseAccent.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
