import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/streak_provider.dart';
import '../../core/theme/app_colors.dart';

/// Streak Card widget - shows doughnut progress and fire button in one card
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.cardDark.withValues(alpha: 0.7)
                  : AppColors.cardLight.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark
                    ? AppColors.borderDark.withValues(alpha: 0.8)
                    : AppColors.borderLight.withValues(alpha: 0.8),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? Colors.black : Colors.grey).withValues(
                    alpha: 0.1,
                  ),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Consumer<StreakProvider>(
                builder: (context, provider, child) {
                  // Update animation when provider changes
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
                            style: TextStyle(
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
                              color: const Color(0xFFD97706).withValues(
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
                                  color: Color(0xFFD97706),
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '${provider.streakDays}d',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFD97706),
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
                          // Doughnut chart
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
                                    style: TextStyle(
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
                          // Fire button
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
      ),
    );
  }
}

/// Fire button (no animations)
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
          // Static glow effect when active
          if (isActive)
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFD97706).withValues(alpha: 0.6),
                    const Color(0xFFD97706).withValues(alpha: 0.0),
                  ],
                  stops: const [0.3, 1],
                ),
              ),
            ),
          // Fire icon
          Icon(
            Icons.local_fire_department,
            size: 64,
            color: isActive
                ? const Color(0xFFD97706)
                : isDark
                    ? const Color(0xFF64748B)
                    : const Color(0xFFCBD5E1),
            shadows: isActive
                ? [
                    BoxShadow(
                      color: const Color(0xFFD97706).withValues(alpha: 0.8),
                      blurRadius: 20,
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

/// Custom painter for doughnut chart
class _DoughnutPainter extends CustomPainter {
  final double progress;
  final bool isDark;

  _DoughnutPainter({required this.progress, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    const strokeWidth = 10.0;

    // Background circle
    final bgPaint = Paint()
      ..color = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = AppColors.success
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      final sweepAngle = 2 * 3.14159 * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -3.14159 / 2, // Start at top
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
