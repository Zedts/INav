import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class MosqueNavigateButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool compact;

  const MosqueNavigateButton({
    super.key,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: compact ? 40 : 48,
        padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [AppColors.success, AppColors.success]
                : [AppColors.success, AppColors.success],
          ),
          borderRadius: BorderRadius.circular(compact ? 12 : 16),
          boxShadow: [
            BoxShadow(
              color: AppColors.success.withValues(alpha: 0.2),
              blurRadius: 3,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: compact ? MainAxisSize.max : MainAxisSize.min,
          children: [
            Icon(Icons.navigation_rounded, size: compact ? 16 : 20, color: Colors.white),
            SizedBox(width: compact ? 6 : 8),
            Text(
              'Navigate',
              style: GoogleFonts.plusJakartaSans().copyWith(
                fontSize: compact ? 12 : 13,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MosqueFavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onTap;
  final bool compact;

  const MosqueFavoriteButton({
    super.key,
    required this.isFavorite,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = compact ? 40.0 : 48.0;
    final iconSize = compact ? 20.0 : 22.0;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isFavorite
              ? AppColors.roseAccent.withValues(alpha: isDark ? 0.2 : 0.12)
              : (isDark
                  ? AppColors.cardDark.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.2)),
          borderRadius: BorderRadius.circular(compact ? 12 : 16),
          border: Border.all(
            color: isFavorite
                ? AppColors.roseAccent.withValues(alpha: 0.45)
                : (isDark
                    ? Colors.white.withValues(alpha: 0.15)
                    : Colors.white.withValues(alpha: 0.4)),
          ),
        ),
        child: Icon(
          isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          size: iconSize,
          color: isFavorite
              ? AppColors.roseAccent
              : AppColors.roseAccent,
        ),
      ),
    );
  }
}

class MosqueInfoButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool compact;

  const MosqueInfoButton({
    super.key,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = compact ? 40.0 : 48.0;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.1),
          borderRadius: BorderRadius.circular(compact ? 12 : 16),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.25),
          ),
        ),
        child: Icon(
          Icons.info_outline_rounded,
          size: compact ? 20 : 22,
          color: isDark ? AppColors.primaryDark : AppColors.primary,
        ),
      ),
    );
  }
}

class MosqueQuickActionsRow extends StatelessWidget {
  final VoidCallback onNavigate;
  final VoidCallback onToggleFavorite;
  final bool isFavorite;
  final VoidCallback? onInfo;

  const MosqueQuickActionsRow({
    super.key,
    required this.onNavigate,
    required this.onToggleFavorite,
    required this.isFavorite,
    this.onInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: MosqueNavigateButton(onTap: onNavigate, compact: true),
        ),
        if (onInfo != null) ...[
          const SizedBox(width: 12),
          MosqueInfoButton(onTap: onInfo!, compact: true),
        ],
        const SizedBox(width: 12),
        MosqueFavoriteButton(
          isFavorite: isFavorite,
          onTap: onToggleFavorite,
          compact: true,
        ),
      ],
    );
  }
}
