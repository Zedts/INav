import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/mosque_provider.dart';
import '../../core/models/mosque_model.dart';
import '../../widgets/mosque/map_view_section.dart';
import '../../widgets/mosque/nearest_mosque_banner.dart';
import '../../widgets/mosque/nearby_mosque_list_tile.dart';
import '../../widgets/mosque/mosque_detail_sheet.dart';
import '../../widgets/common/glass_pill_badge.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open Maps. Try again later.'),
          duration: Duration(seconds: 2),
        ),
      );
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
    final showRefreshOverlay = loading && mp.nearbyMosques.isNotEmpty;

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
                          loading && mp.nearbyMosques.isEmpty
                              ? _buildLoadingView(isDark, mp)
                              : error != null && mp.nearbyMosques.isEmpty
                              ? _buildErrorView(isDark, mp, error)
                              : _buildContent(
                                  isDark,
                                  mp,
                                  selected,
                                ),
                    ),
                  ],
                ),
              ),
              if (showRefreshOverlay)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      color: isDark
                          ? const Color(0xFF070B14).withValues(alpha: 0.55)
                          : Colors.white.withValues(alpha: 0.65),
                      child: const Center(
                        child: CircularProgressIndicator.adaptive(strokeWidth: 3),
                      ),
                    ),
                  ),
                ),
              if (expanded)
                Positioned.fill(
                  child: IgnorePointer(
                    ignoring: false,
                    child: Container(
                      color: isDark
                          ? const Color(0xFF070B14).withValues(alpha: 0.8)
                          : Colors.white.withValues(alpha: 0.95),
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

  Widget _buildLoadingView(bool isDark, MosqueProvider mp) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator.adaptive(strokeWidth: 3),
          const SizedBox(height: 18),
          Text(
            'Locating nearby mosques…',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color:
                  isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            mp.cityName,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color:
                  isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(bool isDark, MosqueProvider mp, String err) {
    final isPermissionOrGps = err.toLowerCase().contains('permission') ||
        err.toLowerCase().contains('disabled');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color:
                    isPermissionOrGps
                        ? const Color(0xFF2563EB).withValues(alpha: 0.15)
                        : const Color(0xFFEF4444).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                isPermissionOrGps
                    ? Icons.location_off_outlined
                    : Icons.warning_amber_rounded,
                color:
                    isPermissionOrGps
                        ? const Color(0xFF2563EB)
                        : const Color(0xFFEF4444),
                size: 30,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              isPermissionOrGps ? 'Location Unavailable' : 'Something went wrong',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              err,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.4,
                color:
                    isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: _onRefresh,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    side: BorderSide(
                      color: isDark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFCBD5E1),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text(
                    'Retry',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (isPermissionOrGps) ...[
                  const SizedBox(width: 10),
                  FilledButton.icon(
                    onPressed: () async {
                      await mp.openLocationSettings();
                    },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      backgroundColor: const Color(0xFF2563EB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.settings, size: 16),
                    label: const Text(
                      'Open Settings',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
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
      color: const Color(0xFF059669),
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
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
                      GlassPillBadge(
                        label: 'NEARBY',
                        icon: Icons.format_list_bulleted,
                        showPulsingDot: false,
                        textColor: isDark
                            ? const Color(0xFF93C5FD)
                            : const Color(0xFF2563EB),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${mp.nearbyMosques.length} locations',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color:
                              isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
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
                            ? Colors.black.withValues(alpha: 0.3)
                            : Colors.white.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : const Color(0xFF0F172A).withValues(alpha: 0.06),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.tune,
                        size: 17,
                        color: isDark
                            ? const Color(0xFFCBD5E1)
                            : const Color(0xFF0F172A),
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
                              ? const Color(0xFF475569)
                              : const Color(0xFF94A3B8),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No mosques found nearby',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color:
                            isDark
                                ? const Color(0xFFCBD5E1)
                                : const Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Pull down to refresh or expand search radius later.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color:
                            isDark
                                ? const Color(0xFF64748B)
                                : const Color(0xFF94A3B8),
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
