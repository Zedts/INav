import 'package:flutter/material.dart';

/// Pill badge used as a section label on cards and banners
class GlassPillBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? textColor;
  final bool showPulsingDot;
  final Color? pulsingDotColor;

  const GlassPillBadge({
    super.key,
    required this.label,
    this.icon,
    this.textColor,
    this.showPulsingDot = false,
    this.pulsingDotColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultTextColor = textColor ??
        (isDark
            ? const Color(0xFF93C5FD) // blue-300
            : const Color(0xFF1E3A8A)); // blue-900

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.15)
              : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showPulsingDot) ...[
            _PulsingDot(
              color: pulsingDotColor ?? const Color(0xFF10B981), // emerald-500
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
              fontWeight: FontWeight.w800,
              color: defaultTextColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Pulsing dot animation for badge
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
                color: widget.color.withValues(alpha: 0.6),
                blurRadius: 4 * _animation.value,
                spreadRadius: 1 * _animation.value,
              ),
            ],
          ),
        );
      },
    );
  }
}
