import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/errors/error_messages.dart';
import '../../core/providers/mosque_provider.dart';
import '../../core/models/mosque_model.dart';
import '../../widgets/mosque/map_view_section.dart';
import '../../widgets/mosque/nearest_mosque_banner.dart';
import '../../widgets/mosque/nearby_mosque_list_tile.dart';
import '../../widgets/mosque/mosque_detail_sheet.dart';
import '../../widgets/common/pill_badge.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/common/error_state_view.dart';
import '../../widgets/common/section_skeleton.dart';

class MosqueScreen extends StatefulWidget {
  const MosqueScreen({super.key});

  @override
  State<MosqueScreen> createState() => _MosqueScreenState();
}

class _MosqueScreenState extends State<MosqueScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final mp = context.read<MosqueProvider>();
      if (!mp.isLoading && mp.userLatLng == null) {
        mp.initialize();
      }
    });
  }

  Future<void> _onRefresh() {
    return context.read<MosqueProvider>().refresh();
  }

  Future<void> _navigateTo(MosqueModel m) async {
    final ok = await context.read<MosqueProvider>().navigateTo(m);
    if (!mounted) return;
    if (!ok) {
      showErrorSnackBar(context, ErrorMessages.mapsUnavailable);
    }
  }

  void _onMapMosqueTap(MosqueModel m) {
    context.read<MosqueProvider>().setFeaturedMosque(m);
  }

  void _onListMosqueTap(MosqueModel m) {
    context.read<MosqueProvider>().setFeaturedMosque(m);
    MosqueDetailSheet.show(context, m);
  }

  void _onToggleMapExpand() {
    context.read<MosqueProvider>().toggleMapExpanded();
  }

  void _onResetToNearest() {
    context.read<MosqueProvider>().resetFeaturedToNearest();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mp = context.watch<MosqueProvider>();
    final loading = mp.isLoading;
    final error = mp.errorMessage;
    final expanded = mp.isMapExpanded;
    final selected = mp.selectedMosqueId;

    return SafeArea(
      top: false,
      bottom: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Positioned.fill(
                child: Column(
                  children: [
                    Expanded(
                      child:
                          loading
                              ? _buildLoadingView()
                              : error != null && mp.nearbyMosques.isEmpty
                              ? ErrorStateView(
                                  message: error,
                                  onRetry: _onRefresh,
                                  onOpenSettings: () =>
                                      mp.openLocationSettings(),
                                )
                              : _buildContent(
                                  isDark,
                                  mp,
                                  selected,
                                ),
                    ),
                  ],
                ),
              ),
              if (expanded)
                Positioned.fill(
                  child: IgnorePointer(
                    ignoring: false,
                    child: Container(
                      color: isDark
                          ? AppColors.surfaceDark.withValues(alpha: 0.8)
                          : AppColors.surfaceLight.withValues(alpha: 0.95),
                      child: SafeArea(
                        top: false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: MapViewSection(
                            mosques: mp.nearbyMosques,
                            selectedMosque: mp.selectedMosque,
                            userLatLng: mp.userLatLng,
                            isExpanded: true,
                            onToggleExpand: _onToggleMapExpand,
                            featuredMosque: mp.featuredMosque,
                            isOverridden: mp.isFeaturedOverridden,
                            onResetToNearest: _onResetToNearest,
                            onMosqueTap: _onMapMosqueTap,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoadingView() {
    return const ScreenSkeleton(
      children: [
        SectionSkeleton(height: 220),
        SizedBox(height: 20),
        SectionSkeleton(height: 150),
        SizedBox(height: 24),
        SectionSkeleton(height: 28, width: 140, borderRadius: 12),
        SizedBox(height: 12),
        SectionSkeleton(height: 84, borderRadius: 16),
        SizedBox(height: 10),
        SectionSkeleton(height: 84, borderRadius: 16),
        SizedBox(height: 10),
        SectionSkeleton(height: 84, borderRadius: 16),
      ],
    );
  }

  Widget _buildContent(
    bool isDark,
    MosqueProvider mp,
    String? selectedId,
  ) {
    return RefreshIndicator.adaptive(
      onRefresh: _onRefresh,
      edgeOffset: 4,
      color: isDark ? AppColors.primaryDark : AppColors.primary,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
      child: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: MapViewSection(
                mosques: mp.nearbyMosques,
                selectedMosque: mp.selectedMosque,
                userLatLng: mp.userLatLng,
                isExpanded: false,
                onToggleExpand: _onToggleMapExpand,
                featuredMosque: mp.featuredMosque,
                onMosqueTap: _onMapMosqueTap,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          SliverToBoxAdapter(
            child: NearestMosqueBanner(
              mosque: mp.featuredMosque,
              isOverridden: mp.isFeaturedOverridden,
              onResetToNearest: _onResetToNearest,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      PillBadge(
                        label: 'NEARBY',
                        icon: Icons.format_list_bulleted,
                        showPulsingDot: false,
                        textColor: isDark
                            ? AppColors.primaryDark
                            : AppColors.primary,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${mp.nearbyMosques.length} locations',
                        style: GoogleFonts.plusJakartaSans().copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color:
                              isDark
                                  ? AppColors.textMutedDark
                                  : AppColors.textMutedLight,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Filters coming soon'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.cardDark.withValues(alpha: 0.2)
                            : AppColors.cardLight.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? AppColors.hairlineDark
                              : AppColors.hairlineLight,
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
                      child: Icon(
                        Icons.tune,
                        size: 17,
                        color: isDark
                            ? AppColors.textMainDark
                            : AppColors.textMainLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          if (mp.nearbyMosques.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      size: 44,
                      color:
                          isDark
                              ? AppColors.textMutedDark
                              : AppColors.textMutedLight,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No mosques found nearby',
                      style: GoogleFonts.plusJakartaSans().copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color:
                            isDark
                                ? AppColors.textMainDark
                                : AppColors.textMainLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Pull down to refresh or expand search radius later.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans().copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color:
                            isDark
                                ? AppColors.textMutedDark
                                : AppColors.textMutedLight,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList.separated(
                itemCount: mp.nearbyMosques.length,
                itemBuilder: (ctx, i) {
                  final m = mp.nearbyMosques[i];
                  return NearbyMosqueListTile(
                    mosque: m,
                    isSelected: m.id == selectedId,
                    onTap: () => _onListMosqueTap(m),
                    onNavigate: () => _navigateTo(m),
                  );
                },
                separatorBuilder: (_, _) => const SizedBox(height: 10),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
