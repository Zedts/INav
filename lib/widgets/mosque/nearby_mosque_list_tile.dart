import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/models/mosque_model.dart';
import '../../core/theme/app_colors.dart';

class NearbyMosqueListTile extends StatelessWidget {
  final MosqueModel mosque;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onNavigate;

  const NearbyMosqueListTile({
    super.key,
    required this.mosque,
    this.isSelected = false,
    this.onTap,
    this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent =
        isSelected ? AppColors.roseAccent : AppColors.success;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            color:
                isDark
                    ? AppColors.cardDark
                    : AppColors.cardLight,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color:
                  isDark
                      ? Colors.white.withValues(alpha: 0.10)
                      : AppColors.cardDark.withValues(alpha: 0.06),
              width: 1,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildIcon(accent),
                const SizedBox(width: 12),
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mosque.name,
                        style: GoogleFonts.plusJakartaSans().copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color:
                              isDark
                                  ? Colors.white
                                  : AppColors.textMainLight,
                          height: 1.2,
                          letterSpacing: -0.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 11,
                            color:
                                isDark
                                    ? AppColors.textMutedDark
                                    : AppColors.textMutedLight,
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              mosque.address,
                              style: GoogleFonts.plusJakartaSans().copyWith(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color:
                                    isDark
                                        ? AppColors.textMutedDark
                                        : AppColors.textMutedLight,
                                height: 1.25,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _buildTrailing(isDark, accent),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(Color accent) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        Icons.mosque,
        color: accent,
        size: 18,
      ),
    );
  }

  Widget _buildTrailing(bool isDark, Color accent) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
          decoration: BoxDecoration(
            color:
                isDark
                    ? AppColors.cardDark.withValues(alpha: 0.2)
                    : AppColors.cardLight,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color:
                  isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : AppColors.cardDark.withValues(alpha: 0.05),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.directions_walk_rounded,
                size: 11,
                color: accent,
              ),
              const SizedBox(width: 4),
              Text(
                mosque.formattedDistance,
                style: GoogleFonts.plusJakartaSans().copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: accent,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (mosque.rating != null) ...[
              const Icon(
                Icons.star_rounded,
                size: 12,
                color: AppColors.roseAccent,
              ),
              const SizedBox(width: 2),
              Text(
                mosque.rating!.toStringAsFixed(1),
                style: GoogleFonts.plusJakartaSans().copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color:
                      isDark ? const Color(0xFFFCD34D) : const Color(0xFFB45309),
                ),
              ),
              const SizedBox(width: 8),
            ],
            if (onNavigate != null)
              GestureDetector(
                onTap: onNavigate,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: accent,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
