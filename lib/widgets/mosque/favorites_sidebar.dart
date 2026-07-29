import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/mosque_provider.dart';
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
                  ? Colors.black.withValues(alpha: 0.6)
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
                color: isDark ? const Color(0xFF0F172A) : Colors.white,
                border: Border(
                  right: BorderSide(
                    color: isDark
                        ? const Color(0xFF1E293B).withValues(alpha: 0.5)
                        : const Color(0xFFE2E8F0).withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 40,
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
                ? const Color(0xFF1E293B).withValues(alpha: 0.8)
                : const Color(0xFFE2E8F0).withValues(alpha: 0.8),
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
              color: const Color(0xFFEF4444).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.favorite,
              size: 20,
              color: Color(0xFFEF4444),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Favorites',
              style: TextStyle(
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
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.close,
                size: 18,
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B),
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
                ? const Color(0xFF64748B).withValues(alpha: 0.4)
                : const Color(0xFF94A3B8).withValues(alpha: 0.4),
          ),
          const SizedBox(height: 8),
          Text(
            'No favorites yet',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? const Color(0xFF64748B).withValues(alpha: 0.6)
                  : const Color(0xFF94A3B8).withValues(alpha: 0.6),
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
                    ? const Color(0xFF1E293B).withValues(alpha: 0.5)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.mosque,
                      size: 16,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mosque.name,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? const Color(0xFFF8FAFC)
                                : const Color(0xFF0F172A),
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${mosque.formattedDistance} · ${mosque.address}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
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
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
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
                ? const Color(0xFF1E293B).withValues(alpha: 0.8)
                : const Color(0xFFE2E8F0).withValues(alpha: 0.8),
            width: 1,
          ),
        ),
      ),
      child: Center(
        child: Text(
          'SAVED MOSQUES',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
            color: isDark
                ? const Color(0xFF94A3B8).withValues(alpha: 0.6)
                : const Color(0xFF64748B).withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }
}
