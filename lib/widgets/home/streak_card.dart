import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/providers/streak_provider.dart';
import '../../core/theme/app_colors.dart';

class StreakCard extends StatefulWidget {
  const StreakCard({super.key});

  @override
  State<StreakCard> createState() => _StreakCardState();
}

class _StreakCardState extends State<StreakCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  double _currentProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutQuad),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = context.read<StreakProvider>();
    final newProgress = provider.completedCount / 5;
    if (newProgress != _currentProgress) {
      _progressAnimation = Tween<double>(begin: _currentProgress, end: newProgress).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOutQuad),
      );
      _currentProgress = newProgress;
      _animationController.forward(from: 0);
    }
  }

  @override
  void didUpdateWidget(StreakCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final provider = context.read<StreakProvider>();
    final newProgress = provider.completedCount / 5;
    if (newProgress != _currentProgress) {
      _progressAnimation = Tween<double>(begin: _currentProgress, end: newProgress).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOutQuad),
      );
      _currentProgress = newProgress;
      _animationController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final plusJakarta = GoogleFonts.plusJakartaSans();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
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
                  color: (isDark ? Colors.black : Colors.grey).withValues(
                    alpha: 0.1,
                  ),
                  blurRadius: 3,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Consumer<StreakProvider>(
                builder: (context, provider, child) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    final newProgress = provider.completedCount / 5;
                    if (newProgress != _currentProgress) {
                      _progressAnimation =
                          Tween<double>(begin: _currentProgress, end: newProgress)
                              .animate(CurvedAnimation(
                        parent: _animationController,
                        curve: Curves.easeOutQuad,
                      ));
                      _currentProgress = newProgress;
                      _animationController.forward(from: 0);
                    }
                  });

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'STREAK',
                            style: plusJakarta.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? AppColors.textMutedDark
                                  : AppColors.textMutedLight,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.roseAccent.withValues(
                                alpha: isDark ? 0.15 : 0.1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.local_fire_department,
                                  size: 12,
                                  color: AppColors.roseAccent,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '${provider.streakDays}d',
                                  style: plusJakarta.copyWith(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.roseAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            width: 80,
                            height: 80,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                AnimatedBuilder(
                                  animation: _progressAnimation,
                                  builder: (context, child) {
                                    return CustomPaint(
                                      painter: _DoughnutPainter(
                                        progress: _progressAnimation.value,
                                        isDark: isDark,
                                      ),
                                    );
                                  },
                                ),
                                Center(
                                  child: Text(
                                    '${provider.completedCount}/5',
                                    style: plusJakarta.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: isDark
                                          ? AppColors.textMainDark
                                          : AppColors.textMainLight,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _FireButton(
                            isActive: provider.isCurrentPrayerCompleted,
                            onTap: () => provider.markCurrentPrayerCompleted(),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
      ),
    );
  }
}

class _FireButton extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;

  const _FireButton({required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (isActive)
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.roseAccent.withValues(alpha: 0.6),
                    AppColors.roseAccent.withValues(alpha: 0.0),
                  ],
                  stops: const [0.3, 1],
                ),
              ),
            ),
          Icon(
            Icons.local_fire_department,
            size: 64,
            color: isActive
                ? AppColors.roseAccent
                : isDark
                    ? AppColors.textMutedLight
                    : AppColors.textMutedDark,
            shadows: isActive
                ? [
                    BoxShadow(
                      color: AppColors.roseAccent.withValues(alpha: 0.2),
                      blurRadius: 3,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
        ],
      ),
    );
  }
}

class _DoughnutPainter extends CustomPainter {
  final double progress;
  final bool isDark;

  _DoughnutPainter({required this.progress, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    const strokeWidth = 10.0;

    final bgPaint = Paint()
      ..color = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    if (progress > 0) {
      final progressPaint = Paint()
        ..color = AppColors.success
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      final sweepAngle = 2 * 3.14159 * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -3.14159 / 2,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_DoughnutPainter oldDelegate) {
    return progress != oldDelegate.progress || isDark != oldDelegate.isDark;
  }
}
