import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/providers/mosque_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/models/mosque_model.dart';

class FavoritesSidebar extends StatelessWidget {
  final void Function(MosqueModel mosque) onOpenMosque;

  const FavoritesSidebar({
    super.key,
    required this.onOpenMosque,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mosqueProvider = context.watch<MosqueProvider>();
    final favorites = mosqueProvider.favoriteMosques;
    final isOpen = mosqueProvider.isSidebarOpen;

    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            ignoring: !isOpen,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              color: isOpen
                  ? Colors.black.withValues(alpha: 0.2)
                  : Colors.transparent,
              child: isOpen
                  ? GestureDetector(
                      onTap: () => mosqueProvider.closeSidebar(),
                      child: const SizedBox.expand(),
                    )
                  : null,
            ),
          ),
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          left: isOpen ? 0 : -280,
          top: 0,
          bottom: 0,
          child: IgnorePointer(
            ignoring: !isOpen,
            child: Container(
              width: 280,
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                border: Border(
                  right: BorderSide(
                    color: isDark
                        ? AppColors.hairlineDark.withValues(alpha: 0.5)
                        : AppColors.hairlineLight.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 3,
                    offset: const Offset(4, 0),
                  ),
                ],
              ),
              child: SafeArea(
                left: false,
                right: false,
                top: true,
                bottom: true,
                child: Column(
                  children: [
                    _buildHeader(context, isDark, mosqueProvider),
                    Expanded(
                      child: favorites.isEmpty
                          ? _buildEmptyState(isDark)
                          : _buildFavoritesList(
                              context,
                              isDark,
                              favorites,
                              mosqueProvider,
                            ),
                    ),
                    _buildFooter(isDark),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(
    BuildContext context,
    bool isDark,
    MosqueProvider mosqueProvider,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.roseAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.favorite,
              size: 20,
              color: AppColors.roseAccent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Favorites',
              style: GoogleFonts.fraunces().copyWith(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => mosqueProvider.closeSidebar(),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.close,
                size: 18,
                color: isDark
                    ? AppColors.textMutedDark
                    : AppColors.textMutedLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 40,
            color: isDark
                ? AppColors.textMutedLight.withValues(alpha: 0.4)
                : AppColors.textMutedDark.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 8),
          Text(
            'No favorites yet',
            style: GoogleFonts.plusJakartaSans().copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? AppColors.textMutedLight.withValues(alpha: 0.6)
                  : AppColors.textMutedDark.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList(
    BuildContext context,
    bool isDark,
    List<MosqueModel> favorites,
    MosqueProvider mosqueProvider,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: favorites.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final mosque = favorites[index];
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              mosqueProvider.closeSidebar();
              mosqueProvider.setFeaturedMosque(mosque);
              onOpenMosque(mosque);
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.cardDark.withValues(alpha: 0.2)
                    : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.roseAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.mosque,
                      size: 16,
                      color: AppColors.roseAccent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mosque.name,
                          style: GoogleFonts.plusJakartaSans().copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.textMainDark
                                : AppColors.textMainLight,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${mosque.formattedDistance} · ${mosque.address}',
                          style: GoogleFonts.plusJakartaSans().copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? AppColors.textMutedDark
                                : AppColors.textMutedLight,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: isDark
                        ? AppColors.textMutedDark
                        : AppColors.textMutedLight,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFooter(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark
                ? AppColors.hairlineDark.withValues(alpha: 0.8)
                : AppColors.hairlineLight.withValues(alpha: 0.8),
            width: 1,
          ),
        ),
      ),
      child: Center(
        child: Text(
          'SAVED MOSQUES',
          style: GoogleFonts.plusJakartaSans().copyWith(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
            color: isDark
                ? AppColors.textMutedDark.withValues(alpha: 0.6)
                : AppColors.textMutedLight.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }
}
