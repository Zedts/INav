import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/errors/error_messages.dart';
import '../../core/providers/mosque_provider.dart';
import '../../core/models/mosque_model.dart';
import '../../core/theme/app_colors.dart';
import '../common/error_state_view.dart';
import '../common/pill_badge.dart';
import 'mosque_detail_sheet.dart';
import 'mosque_quick_actions.dart';

class NearestMosqueBanner extends StatelessWidget {
  final MosqueModel? mosque;
  final bool isOverridden;
  final VoidCallback? onResetToNearest;

  const NearestMosqueBanner({
    super.key,
    required this.mosque,
    this.isOverridden = false,
    this.onResetToNearest,
  });

  Future<void> _navigate(BuildContext context, MosqueModel m) async {
    final ok = await context.read<MosqueProvider>().navigateTo(m);
    if (!context.mounted) return;
    if (!ok) {
      showErrorSnackBar(context, ErrorMessages.mapsUnavailable);
    }
  }

  void _toggleFavorite(BuildContext context, MosqueModel m) {
    final provider = context.read<MosqueProvider>();
    final wasFavorite = provider.isFavorite(m.id);
    provider.toggleFavorite(m.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          wasFavorite ? 'Removed from favorites' : 'Added to favorites',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final m = mosque;
    final provider = context.watch<MosqueProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 170,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            borderRadius: BorderRadius.circular(24),
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                Positioned(
                  right: -16,
                  bottom: -24,
                  child: Icon(
                    Icons.mosque,
                    size: 110,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.04)
                        : AppColors.primary.withValues(alpha: 0.06),
                  ),
                ),
                if (isOverridden && onResetToNearest != null)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: onResetToNearest,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.surfaceDark.withValues(alpha: 0.6)
                              : Colors.white.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? AppColors.hairlineDark
                                : AppColors.hairlineLight,
                          ),
                        ),
                        child: Icon(
                          Icons.replay,
                          size: 17,
                          color: isDark
                              ? AppColors.primaryDark
                              : AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PillBadge(
                        label: isOverridden ? 'SELECTED MOSQUE' : 'NEAREST TO YOU',
                        icon: isOverridden
                            ? Icons.push_pin_outlined
                            : Icons.location_on,
                        showPulsingDot: !isOverridden,
                        textColor: isOverridden
                            ? AppColors.roseAccent
                            : (isDark
                                ? AppColors.primaryDark
                                : AppColors.primary),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: m == null
                            ? _buildEmptyContent(context, isDark)
                            : _buildContent(
                                context,
                                isDark,
                                m,
                                provider.isFavorite(m.id),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyContent(BuildContext context, bool isDark) {
    final fraunces = GoogleFonts.fraunces();
    final plusJakarta = GoogleFonts.plusJakartaSans();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Searching nearby…',
          style: fraunces.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
            height: 1.2,
            letterSpacing: -0.02,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Fetching nearest mosques',
          style: plusJakarta.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppColors.textMainDark.withValues(alpha: 0.88)
                : AppColors.textMainLight.withValues(alpha: 0.88),
          ),
        ),
        const Spacer(),
        const Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator.adaptive(strokeWidth: 2.2),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(
    BuildContext context,
    bool isDark,
    MosqueModel m,
    bool isFavorite,
  ) {
    final fraunces = GoogleFonts.fraunces();
    final plusJakarta = GoogleFonts.plusJakartaSans();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          m.name,
          style: fraunces.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
            height: 1.1,
            letterSpacing: -0.02,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(
              Icons.directions_walk_rounded,
              size: 14,
              color: isDark ? AppColors.primaryDark : AppColors.primary,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                '${m.estimatedWalkingTime} walk (${m.formattedDistance})',
                style: plusJakarta.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textMainDark.withValues(alpha: 0.88)
                      : AppColors.textMainLight.withValues(alpha: 0.88),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: isDark ? AppColors.hairlineDark : AppColors.hairlineLight,
              ),
            ),
          ),
          child: MosqueQuickActionsRow(
            onNavigate: () => _navigate(context, m),
            onToggleFavorite: () => _toggleFavorite(context, m),
            isFavorite: isFavorite,
            onInfo: () => MosqueDetailSheet.show(context, m),
          ),
        ),
      ],
    );
  }
}
