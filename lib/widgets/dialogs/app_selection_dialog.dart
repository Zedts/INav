import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/models/app_definition.dart';
import '../../core/services/installed_apps_service.dart';
import '../../core/constants/default_apps.dart';
import '../../core/constants/app_constants.dart';
import '../common/async_app_icon.dart';

enum _AppFilter {
  all(label: 'All', icon: Icons.apps_rounded),
  launchable(label: 'Launchable', icon: Icons.open_in_new_rounded),
  user(label: 'User only', icon: Icons.person_rounded);

  final String label;
  final IconData icon;
  const _AppFilter({required this.label, required this.icon});
}

/// Dialog for selecting apps to lock. Shows the FULL list of packages
/// installed under the current Android profile (equivalent to
/// `adb shell pm list packages`). Uses the 2-tier Perplexity-recommended
/// pattern: metadata first (fast) + lazy per-row PNG icon loads.
class AppSelectionDialog extends StatefulWidget {
  final List<AppDefinition> currentlyLockedApps;

  const AppSelectionDialog({super.key, required this.currentlyLockedApps});

  @override
  State<AppSelectionDialog> createState() => _AppSelectionDialogState();
}

class _AppSelectionDialogState extends State<AppSelectionDialog> {
  List<InstalledAppInfo> _allInstalled = [];
  List<InstalledAppInfo> _filtered = [];
  bool _isLoading = true;
  String _searchQuery = '';
  _AppFilter _filter = _AppFilter.all;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadApps();
  }

  /// Full, unfiltered load: `includeSystemApps: true, onlyLaunchable: false`
  /// → genuine adb-equivalent list. Filter chips then slice into view, so
  /// switching between "All / Launchable / User" does NOT re-hit native.
  Future<void> _loadApps() async {
    setState(() => _isLoading = true);

    final installed = await InstalledAppsService.getInstalledApps(
      includeSystemApps: true,
      onlyLaunchable: false,
    );

    // Enrich known DefaultApps (Instagram/TikTok/YouTube) with their
    // hand-tuned Flutter icons + brand colors, for a consistent "premium"
    // look on the top pinned rows. Real PNG icons from native are still
    // shown when available; DefaultApps metadata is a graceful fallback.
    final enriched = <InstalledAppInfo>[];
    for (final info in installed) {
      final defaultApp = DefaultApps.getApp(info.app.packageName);
      if (defaultApp == null) {
        enriched.add(info);
        continue;
      }
      enriched.add(InstalledAppInfo(
        app: AppDefinition(
          packageName: info.app.packageName,
          packageAliases: defaultApp.packageAliases,
          name: defaultApp.name,
          iconCodePoint: defaultApp.iconCodePoint,
          iconFontFamily: defaultApp.iconFontFamily,
          iconFontPackage: defaultApp.iconFontPackage,
          iconMatchTextDirection: defaultApp.iconMatchTextDirection,
          colorARGB: defaultApp.colorARGB,
          isDefault: defaultApp.isDefault,
        ),
        activityName: info.activityName,
        hasLauncherActivity: info.hasLauncherActivity,
        isEnabled: info.isEnabled,
        isSuspended: info.isSuspended,
        isSystemApp: info.isSystemApp,
        isUpdatedSystemApp: info.isUpdatedSystemApp,
      ));
    }

    final lockedPackages = <String>{};
    for (final locked in widget.currentlyLockedApps) {
      lockedPackages.add(locked.packageName);
      if (locked.packageAliases != null) {
        lockedPackages.addAll(locked.packageAliases!);
      }
    }

    final available = enriched.where((info) {
      final pkg = info.app.packageName;
      if (AppConstants.kEmergencyNonLockablePackages.contains(pkg)) return false;
      if (lockedPackages.contains(pkg)) return false;
      final aliases = info.app.packageAliases;
      if (aliases != null && aliases.any((a) => lockedPackages.contains(a))) {
        return false;
      }
      return true;
    }).toList();

    // Pinned-sort: Instagram / TikTok / YouTube first (they are the default
    // "distracting apps" the app ships with). Then the native sort order
    // (launchable first, then user before system, then alphabetical) is
    // preserved for the rest.
    const pinnedOrder = [
      'com.instagram.android',
      'com.ss.android.ugc.trill',
      'com.zhiliaoapp.musically',
      'com.google.android.youtube',
    ];
    int pinnedRankFor(InstalledAppInfo info) {
      final direct = pinnedOrder.indexOf(info.app.packageName);
      if (direct != -1) return direct;
      final viaAlias = info.app.packageAliases != null
          ? pinnedOrder.indexWhere((o) => info.app.packageAliases!.contains(o))
          : -1;
      return viaAlias != -1 ? viaAlias : 999;
    }
    available.sort((a, b) {
      final ra = pinnedRankFor(a);
      final rb = pinnedRankFor(b);
      if (ra != 999 || rb != 999) return ra.compareTo(rb);
      // Native already ordered by: !launchable then system then name; keep it.
      return 0;
    });

    setState(() {
      _allInstalled = available;
      _applyFilters();
      _isLoading = false;
    });
  }

  /// Apply current [_filter] chip + text search against the in-memory
  /// [_allInstalled] list. Runs synchronously because the list is small
  /// (~50-500 entries). Never re-queries PackageManager.
  void _applyFilters() {
    final query = _searchQuery.trim().toLowerCase();
    Iterable<InstalledAppInfo> list = _allInstalled;

    switch (_filter) {
      case _AppFilter.all:
        break;
      case _AppFilter.launchable:
        list = list.where((i) => i.hasLauncherActivity);
        break;
      case _AppFilter.user:
        list = list.where((i) => !i.isSystemApp);
        break;
    }
    if (query.isNotEmpty) {
      list = list.where((i) {
        // Search against display name AND package name, so headless
        // packages like "com.android.bluetooth" can still be found by
        // partial package-id substring.
        return i.app.name.toLowerCase().contains(query) ||
            i.app.packageName.toLowerCase().contains(query);
      });
    }

    _filtered = list.toList();
  }

  void _updateFilters({_AppFilter? filter, String? query}) {
    setState(() {
      if (filter != null) _filter = filter;
      if (query != null) _searchQuery = query;
      _applyFilters();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 8, 8),
              child: Row(
                children: [
                  Icon(
                    Icons.apps,
                    color: isDark
                        ? AppColors.primaryDark
                        : AppColors.primaryLight,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Select Apps to Lock',
                      style: GoogleFonts.plusJakartaSans().copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.textMainDark
                            : AppColors.textMainLight,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    color: isDark
                        ? AppColors.textMutedDark
                        : AppColors.textMutedLight,
                  ),
                ],
              ),
            ),

            // Filter chips + count summary
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _AppFilter.values
                          .map((f) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: _FilterChip(
                                  filter: f,
                                  selected: _filter == f,
                                  isDark: isDark,
                                  onTap: () => _updateFilters(filter: f),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isLoading
                        ? 'Loading installed apps…'
                        : '${_filtered.length} of ${_allInstalled.length} apps'
                            '  ·  ${_allInstalled.where((i) => !i.hasLauncherActivity).length} non-launchable',
                    style: GoogleFonts.plusJakartaSans().copyWith(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.textMutedDark
                          : AppColors.textMutedLight,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                onChanged: (q) => _updateFilters(query: q),
                style: GoogleFonts.plusJakartaSans().copyWith(
                  color: isDark
                      ? AppColors.textMainDark
                      : AppColors.textMainLight,
                ),
                decoration: InputDecoration(
                  hintText: 'Search by name or package…',
                  prefixIcon: Icon(
                    Icons.search,
                    color: isDark
                        ? AppColors.textMutedDark
                        : AppColors.textMutedLight,
                  ),
                  suffixIcon: _searchQuery.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.cancel),
                          onPressed: () {
                            _searchController.clear();
                            _updateFilters(query: '');
                          },
                          color: isDark
                              ? AppColors.textMutedDark
                              : AppColors.textMutedLight,
                        ),
                  filled: true,
                  fillColor: isDark
                      ? AppColors.surfaceDark
                      : AppColors.surfaceLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Apps list
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isDark
                              ? AppColors.primaryDark
                              : AppColors.primaryLight,
                        ),
                      ),
                    )
                  : _filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _searchQuery.isEmpty
                                ? Icons.check_circle_outline_rounded
                                : Icons.search_off,
                            size: 48,
                            color: isDark
                                ? AppColors.textMutedDark
                                : AppColors.textMutedLight,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty
                                ? 'All installed apps are already locked'
                                : 'No apps match your search',
                            style: GoogleFonts.plusJakartaSans().copyWith(
                              fontSize: 14,
                              color: isDark
                                  ? AppColors.textMutedDark
                                  : AppColors.textMutedLight,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _filtered.length,
                      itemBuilder: (context, index) {
                        final info = _filtered[index];
                        return _buildAppItem(context, info, isDark);
                      },
                    ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildAppItem(
    BuildContext context,
    InstalledAppInfo info,
    bool isDark,
  ) {
    final pkg = info.app.packageName;
    final defaultColor = Color(info.app.colorARGB);
    final IconData? fallbackIcon = info.app.isDefault
        ? _iconFromAppDefinition(info.app)
        : null;

    return InkWell(
      onTap: () => Navigator.pop(context, info.app),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: AsyncAppIcon(
                packageName: pkg,
                activityName: info.activityName,
                fallbackColor: defaultColor,
                fallbackIcon: fallbackIcon ?? Icons.apps,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          info.app.name,
                          style: GoogleFonts.plusJakartaSans().copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.textMainDark
                                : AppColors.textMainLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _BadgeRow(info: info, isDark: isDark),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    pkg,
                    style: GoogleFonts.plusJakartaSans().copyWith(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.textMutedDark
                          : AppColors.textMutedLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.add_circle_outline,
              color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconFromAppDefinition(AppDefinition app) {
    return app.icon;
  }
}

// ============================================================================
// UI helpers (private, local to this file only)
// ============================================================================

class _FilterChip extends StatelessWidget {
  final _AppFilter filter;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  const _FilterChip({
    required this.filter,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fg = selected
        ? (isDark ? Colors.black : Colors.white)
        : (isDark ? AppColors.textMainDark : AppColors.textMainLight);
    final bg = selected
        ? (isDark ? AppColors.primaryDark : AppColors.primaryLight)
        : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight);
    final border = BorderSide(
      color: selected
          ? (isDark ? AppColors.primaryDark : AppColors.primaryLight)
          : (isDark ? AppColors.hairlineDark : AppColors.hairlineLight),
    );

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.fromBorderSide(border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(filter.icon, size: 16, color: fg),
              const SizedBox(width: 6),
              Text(
                filter.label,
                style: GoogleFonts.plusJakartaSans().copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BadgeRow extends StatelessWidget {
  final InstalledAppInfo info;
  final bool isDark;

  const _BadgeRow({required this.info, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final items = <_Badge>[];
    if (!info.isEnabled) {
      items.add(_Badge(
        label: 'disabled',
        color: isDark ? const Color(0xFFF59E0B) : const Color(0xFFB45309),
      ));
    }
    if (info.isSuspended) {
      items.add(_Badge(
        label: 'suspended',
        color: isDark ? const Color(0xFFF43F5E) : const Color(0xFFBE123C),
      ));
    }
    if (info.isSystemApp) {
      items.add(_Badge(
        label: 'system',
        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
      ));
    }
    if (!info.hasLauncherActivity) {
      items.add(_Badge(
        label: 'no-launcher',
        color: isDark ? AppColors.hairlineDark : AppColors.hairlineLight,
      ));
    }
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Wrap(
        alignment: WrapAlignment.end,
        spacing: 4,
        runSpacing: 2,
        children: items,
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans().copyWith(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
          color: color,
        ),
      ),
    );
  }
}
