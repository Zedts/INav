import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/models/app_definition.dart';
import '../../core/services/installed_apps_service.dart';
import '../../core/constants/default_apps.dart';
import '../../core/constants/app_constants.dart';

/// Dialog for selecting apps to lock
class AppSelectionDialog extends StatefulWidget {
  final List<AppDefinition> currentlyLockedApps;

  const AppSelectionDialog({super.key, required this.currentlyLockedApps});

  @override
  State<AppSelectionDialog> createState() => _AppSelectionDialogState();
}

class _AppSelectionDialogState extends State<AppSelectionDialog> {
  List<AppDefinition> _allApps = [];
  List<AppDefinition> _filteredApps = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadApps();
  }

  Future<void> _loadApps() async {
    setState(() => _isLoading = true);

    final installedApps = await InstalledAppsService.getInstalledApps();

    final byPkg = <String, AppDefinition>{};
    for (final app in installedApps) {
      byPkg[app.packageName] = app;
    }

    final merged = <String, AppDefinition>{};

    for (final app in installedApps) {
      if (AppConstants.kEmergencyNonLockablePackages.contains(app.packageName)) {
        continue;
      }
      merged[app.packageName] = app;
    }

    for (final defaultApp in DefaultApps.apps.values) {
      final inInstalled = byPkg.containsKey(defaultApp.packageName) ||
          (defaultApp.packageAliases?.any((a) => byPkg.containsKey(a)) ?? false);

      if (inInstalled || AppConstants.kEmergencyNonLockablePackages.contains(defaultApp.packageName)) {
        if (AppConstants.kEmergencyNonLockablePackages.contains(defaultApp.packageName)) {
          continue;
        }
      }

      String? canonicalKey;
      if (byPkg.containsKey(defaultApp.packageName)) {
        canonicalKey = defaultApp.packageName;
      } else if (defaultApp.packageAliases != null) {
        for (final alias in defaultApp.packageAliases!) {
          if (byPkg.containsKey(alias)) {
            canonicalKey = alias;
            break;
          }
        }
      }

      if (canonicalKey != null) {
        final pkgToUse = canonicalKey;
        final existing = merged[pkgToUse];
        if (existing != null || !AppConstants.kEmergencyNonLockablePackages.contains(pkgToUse)) {
          if (!AppConstants.kEmergencyNonLockablePackages.contains(pkgToUse)) {
            merged[pkgToUse] = AppDefinition(
              packageName: pkgToUse,
              packageAliases: defaultApp.packageAliases,
              name: defaultApp.name,
              iconCodePoint: defaultApp.iconCodePoint,
              iconFontFamily: defaultApp.iconFontFamily,
              iconFontPackage: defaultApp.iconFontPackage,
              iconMatchTextDirection: defaultApp.iconMatchTextDirection,
              colorARGB: defaultApp.colorARGB,
              isDefault: defaultApp.isDefault,
            );
          }
        }
      } else {
        final pkg = defaultApp.packageName;
        if (!AppConstants.kEmergencyNonLockablePackages.contains(pkg)) {
          merged.putIfAbsent(pkg, () => defaultApp);
        }
      }
    }

    final lockedPackages = <String>{};
    for (final locked in widget.currentlyLockedApps) {
      lockedPackages.add(locked.packageName);
      if (locked.packageAliases != null) {
        lockedPackages.addAll(locked.packageAliases!);
      }
    }

    final availableApps = merged.values.where((app) {
      if (lockedPackages.contains(app.packageName)) return false;
      if (app.packageAliases != null &&
          app.packageAliases!.any((a) => lockedPackages.contains(a))) {
        return false;
      }
      return true;
    }).toList();

    availableApps.sort((a, b) {
      const order = [
        'com.instagram.android',
        'com.ss.android.ugc.trill',
        'com.zhiliaoapp.musically',
        'com.google.android.youtube',
      ];
      final ia = order.indexOf(a.packageName);
      final ib = order.indexOf(b.packageName);
      final iaAlias = a.packageAliases != null
          ? order.indexWhere((o) => a.packageAliases!.contains(o))
          : -1;
      final ibAlias = b.packageAliases != null
          ? order.indexWhere((o) => b.packageAliases!.contains(o))
          : -1;
      final finalIa = ia != -1 ? ia : (iaAlias != -1 ? iaAlias : 999);
      final finalIb = ib != -1 ? ib : (ibAlias != -1 ? ibAlias : 999);
      if (finalIa != 999 || finalIb != 999) {
        return finalIa.compareTo(finalIb);
      }
      return a.name.compareTo(b.name);
    });

    setState(() {
      _allApps = availableApps;
      _filteredApps = availableApps;
      _isLoading = false;
    });
  }

  void _filterApps(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredApps = _allApps;
      } else {
        final lowerQuery = query.toLowerCase();
        _filteredApps = _allApps
            .where((app) => app.name.toLowerCase().contains(lowerQuery))
            .toList();
      }
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
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
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

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                onChanged: _filterApps,
                style: GoogleFonts.plusJakartaSans().copyWith(
                  color: isDark
                      ? AppColors.textMainDark
                      : AppColors.textMainLight,
                ),
                decoration: InputDecoration(
                  hintText: 'Search apps...',
                  prefixIcon: Icon(
                    Icons.search,
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

            const SizedBox(height: 16),

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
                  : _filteredApps.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _searchQuery.isEmpty
                                ? Icons.apps
                                : Icons.search_off,
                            size: 48,
                            color: isDark
                                ? AppColors.textMutedDark
                                : AppColors.textMutedLight,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty
                                ? 'No apps available'
                                : 'No apps found',
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
                      itemCount: _filteredApps.length,
                      itemBuilder: (context, index) {
                        final app = _filteredApps[index];
                        return _buildAppItem(context, app, isDark);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppItem(BuildContext context, AppDefinition app, bool isDark) {
    return InkWell(
      onTap: () => Navigator.pop(context, app),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            // Generic app icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: (isDark ? AppColors.primaryDark : AppColors.primaryLight)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.apps,
                color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    app.name,
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
                  const SizedBox(height: 2),
                  Text(
                    app.packageName,
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
}
