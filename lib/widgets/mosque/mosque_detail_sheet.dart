import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/errors/error_messages.dart';
import '../../core/models/mosque_model.dart';
import '../../core/providers/mosque_provider.dart';
import '../../core/theme/app_colors.dart';
import '../common/error_state_view.dart';
import 'mosque_quick_actions.dart';

class MosqueDetailSheet extends StatelessWidget {
  final MosqueModel mosque;

  const MosqueDetailSheet({
    super.key,
    required this.mosque,
  });

  static void show(BuildContext context, MosqueModel mosque) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => MosqueDetailSheet(mosque: mosque),
    );
  }

  Future<void> _navigate(BuildContext context) async {
    final ok = await context.read<MosqueProvider>().navigateTo(mosque);
    if (!context.mounted) return;
    if (!ok) {
      showErrorSnackBar(context, ErrorMessages.mapsUnavailable);
    }
  }

  void _toggleFavorite(BuildContext context) {
    final provider = context.read<MosqueProvider>();
    final wasFavorite = provider.isFavorite(mosque.id);
    provider.toggleFavorite(mosque.id);
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
    final mediaQuery = MediaQuery.of(context);
    final maxHeight = mediaQuery.size.height * 0.92;
    final minHeight = mediaQuery.size.height * 0.5;
    final provider = context.watch<MosqueProvider>();
    final isFavorite = provider.isFavorite(mosque.id);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: maxHeight,
            minHeight: minHeight,
          ),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 3,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDragHandle(isDark),
                      _buildHeader(isDark),
                      _buildBadgesRow(isDark),
                      const SizedBox(height: 20),
                      _buildDetailsSection(isDark),
                    ],
                  ),
                ),
              ),
              _buildBottomActions(context, isDark, isFavorite),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDragHandle(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Center(
        child: Container(
          width: 48,
          height: 5,
          decoration: BoxDecoration(
            color: isDark ? AppColors.textMutedLight : AppColors.textMutedDark,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 16),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isDark
                  ? AppColors.hairlineDark.withValues(alpha: 0.8)
                  : AppColors.hairlineLight.withValues(alpha: 0.8),
              width: 1,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(
                    alpha: isDark ? 0.2 : 0.1,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.mosque,
                  color: AppColors.success,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mosque.name,
                      style: GoogleFonts.fraunces().copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppColors.textMainDark
                            : AppColors.textMainLight,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 13,
                          color: isDark
                              ? AppColors.textMutedDark
                              : AppColors.textMutedLight,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            mosque.address,
                            style: GoogleFonts.plusJakartaSans().copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.textMutedDark
                                  : AppColors.textMutedLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadgesRow(bool isDark) {
    final badges = <Widget>[
      _buildBadge(
        icon: Icons.directions_walk_rounded,
        bg: AppColors.success.withValues(alpha: 0.1),
        fg: AppColors.success,
        text: '${mosque.estimatedWalkingTime} walk',
      ),
      _buildBadge(
        icon: Icons.straighten,
        bg: AppColors.primary.withValues(alpha: 0.1),
        fg: isDark ? AppColors.primaryDark : AppColors.primary,
        text: mosque.formattedDistance,
      ),
    ];

    if (mosque.rating != null) {
      badges.add(
        _buildBadge(
          icon: Icons.star_rounded,
          bg: AppColors.roseAccent.withValues(alpha: 0.1),
          fg: const Color(0xFFD97706),
          text: mosque.rating!.toStringAsFixed(1),
        ),
      );
    }

    if (mosque.openNow != null) {
      final open = mosque.openNow!;
      badges.add(
        _buildBadge(
          icon: open ? Icons.check_circle_outline : Icons.cancel_outlined,
          bg: (open ? AppColors.success : AppColors.roseAccent)
              .withValues(alpha: 0.1),
          fg: open ? AppColors.success : AppColors.roseAccent,
          text: open ? 'Open now' : 'Closed',
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: badges,
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required Color bg,
    required Color fg,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.plusJakartaSans().copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.place_outlined,
              size: 13,
              color: AppColors.success,
            ),
            const SizedBox(width: 6),
            Text(
              'LOCATION DETAILS',
              style: GoogleFonts.plusJakartaSans().copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: isDark
                    ? AppColors.textMutedDark
                    : AppColors.textMutedLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          mosque.address,
          style: GoogleFonts.plusJakartaSans().copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: (isDark
                    ? AppColors.textMainDark
                    : AppColors.textMainLight)
                .withValues(alpha: 0.9),
            height: 1.65,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '${mosque.latitude.toStringAsFixed(5)}, ${mosque.longitude.toStringAsFixed(5)}',
          style: GoogleFonts.plusJakartaSans().copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textMutedLight : AppColors.textMutedDark,
          ),
        ),
        if (mosque.iconTag != null && mosque.iconTag!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'Category: ${mosque.iconTag}',
            style: GoogleFonts.plusJakartaSans().copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBottomActions(
    BuildContext context,
    bool isDark,
    bool isFavorite,
  ) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        16 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark
                ? AppColors.hairlineDark.withValues(alpha: 0.8)
                : AppColors.hairlineLight.withValues(alpha: 0.8),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: MosqueNavigateButton(
              onTap: () => _navigate(context),
            ),
          ),
          const SizedBox(width: 12),
          MosqueFavoriteButton(
            isFavorite: isFavorite,
            onTap: () => _toggleFavorite(context),
          ),
        ],
      ),
    );
  }
}
