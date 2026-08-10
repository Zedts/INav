import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class PillBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? textColor;
  final Color? backgroundColor;
  final bool showPulsingDot;
  final Color? pulsingDotColor;

  const PillBadge({
    super.key,
    required this.label,
    this.icon,
    this.textColor,
    this.backgroundColor,
    this.showPulsingDot = false,
    this.pulsingDotColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultTextColor = textColor ?? AppColors.primary;
    final defaultBgColor = backgroundColor ??
        (isDark
            ? AppColors.primaryDark.withValues(alpha: 0.12)
            : AppColors.primary.withValues(alpha: 0.08));
    final defaultBorderColor =
        isDark ? AppColors.hairlineDark : AppColors.hairlineLight;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: defaultBgColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: defaultBorderColor,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showPulsingDot) ...[
            _PulsingDot(
              color: pulsingDotColor ?? AppColors.primary,
            ),
            const SizedBox(width: 6),
          ],
          if (icon != null) ...[
            Icon(
              icon,
              size: 14,
              color: defaultTextColor,
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: defaultTextColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  final Color color;

  const _PulsingDot({required this.color});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _animation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color,
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.4),
                blurRadius: 3 * _animation.value,
                spreadRadius: 0.5 * _animation.value,
              ),
            ],
          ),
        );
      },
    );
  }
}
