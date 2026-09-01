import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/prayer_provider.dart';
import '../../core/providers/mosque_provider.dart';
import '../../core/providers/qibla_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../auth/profile_sheet.dart';

enum HeaderMode { home, quran, mosque, qibla, settings }

class AppHeader extends StatelessWidget {
  final HeaderMode mode;
  final VoidCallback? onToggleBookmarks;
  final VoidCallback? onToggleFavorites;

  const AppHeader({
    super.key,
    this.mode = HeaderMode.home,
    this.onToggleBookmarks,
    this.onToggleFavorites,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.hairlineDark : AppColors.hairlineLight,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: _buildLeading(context, isDark)),
              _buildActions(context, themeProvider, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeading(BuildContext context, bool isDark) {
    switch (mode) {
      case HeaderMode.quran:
        return _buildStaticLeading(
          context,
          isDark,
          title: "Al-Qur'an",
          subtitle: 'Browse & Study',
          icon: Icons.menu_book,
        );
      case HeaderMode.mosque:
        return _buildMosqueLeading(context, isDark);
      case HeaderMode.qibla:
        return _buildQiblaLeading(context, isDark);
      case HeaderMode.settings:
        return _buildStaticLeading(
          context,
          isDark,
          title: 'Settings',
          subtitle: 'Set Your Preferences',
          icon: Icons.settings_outlined,
        );
      case HeaderMode.home:
        final provider = context.watch<PrayerProvider>();
        return _buildLocationLeading(
          context,
          isDark,
          title: 'Assalamualaikum',
          location: provider.locationName.isNotEmpty && provider.locationName != 'Loading...'
              ? provider.locationName
              : 'Jakarta, ID',
          onRefresh: provider.refresh,
        );
    }
  }

  Widget _buildStaticLeading(
    BuildContext context,
    bool isDark, {
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Row(
      children: [
        _buildProfileMenu(context, isDark),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.fraunces(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(icon, size: 12, color: isDark ? AppColors.primaryDark : AppColors.primary),
                  const SizedBox(width: 4),
                  Expanded(child: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w500, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight))),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationLeading(
    BuildContext context,
    bool isDark, {
    required String title,
    required String location,
    required Future<void> Function() onRefresh,
  }) {
    return Row(
      children: [
        _buildProfileMenu(context, isDark),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.fraunces(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(Icons.location_on, size: 12, color: isDark ? AppColors.primaryDark : AppColors.primary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(location, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w500, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight)),
                  ),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () async {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Refreshing location…'), duration: Duration(seconds: 1)));
                      await onRefresh();
                    },
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Icon(Icons.refresh, size: 12, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActions(
    BuildContext context,
    ThemeProvider themeProvider,
    bool isDark,
  ) {
    return Row(
      children: [
        if (mode == HeaderMode.quran)
          _buildQuranBookmarkButton(context, isDark)
        else if (mode == HeaderMode.mosque)
          _buildLikeButton(context, isDark)
        else
          _buildNotificationButton(context, isDark),
        const SizedBox(width: 8),
        _buildThemeButton(themeProvider, isDark),
      ],
    );
  }

  Widget _buildProfileMenu(BuildContext context, bool isDark) {
    return PopupMenuButton<String>(
      tooltip: 'Profile menu',
      padding: EdgeInsets.zero,
      offset: const Offset(0, 48),
      onSelected: (value) async {
        if (value == 'profile') {
          await ProfileSheet.show(context);
          return;
        }
        if (value != 'logout') return;

        final shouldLogout = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Log out?'),
            content: const Text('You can log back in to access your saved data.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Log out'),
              ),
            ],
          ),
        );
        if (shouldLogout == true && context.mounted) {
          await context.read<AuthProvider>().logout();
        }
      },
      itemBuilder: (_) => const [
        PopupMenuItem(
          value: 'profile',
          child: Row(
            children: [
              Icon(Icons.person_outline, size: 18),
              SizedBox(width: 10),
              Text('Profile'),
            ],
          ),
        ),
        PopupMenuDivider(),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, size: 18, color: AppColors.roseAccent),
              SizedBox(width: 10),
              Text('Log Out', style: TextStyle(color: AppColors.roseAccent)),
            ],
          ),
        ),
      ],
      child: SizedBox(
        width: 40,
        height: 40,
        child: Stack(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColors.primary,
              ),
              child: const Center(
                child: Icon(Icons.person, color: Colors.white, size: 20),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                    width: 2,
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.check, color: Colors.white, size: 8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationButton(BuildContext context, bool isDark) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notifications are up to date'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(12),
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
        child: Stack(
          children: [
            Center(
              child: Icon(
                Icons.notifications_outlined,
                size: 20,
                color: isDark
                    ? AppColors.textMainDark
                    : AppColors.textMainLight,
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.roseAccent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? AppColors.cardDark : AppColors.cardLight,
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuranBookmarkButton(BuildContext context, bool isDark) {
    return InkWell(
      onTap: onToggleBookmarks,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(12),
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
        child: Center(
          child: Icon(
            Icons.bookmark_border,
            size: 20,
            color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
          ),
        ),
      ),
    );
  }

  Widget _buildThemeButton(ThemeProvider themeProvider, bool isDark) {
    return InkWell(
      onTap: () => themeProvider.toggleTheme(),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(12),
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
        child: Center(
          child: isDark
              ? const Icon(Icons.wb_sunny_outlined, size: 20)
              : Transform.rotate(
                  angle: -0.4,
                  child: const Icon(Icons.nightlight_round, size: 20),
                ),
        ),
      ),
    );
  }

  Widget _buildLikeButton(BuildContext context, bool isDark) {
    final mosqueProvider = context.watch<MosqueProvider>();
    final hasFavorites = mosqueProvider.favoriteMosqueIds.isNotEmpty;
    final isSidebarOpen = mosqueProvider.isSidebarOpen;
    final isActive = hasFavorites || isSidebarOpen;

    return InkWell(
      onTap: onToggleFavorites,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.roseAccent.withValues(alpha: isDark ? 0.18 : 0.1)
              : (isDark ? AppColors.cardDark : AppColors.cardLight),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? AppColors.roseAccent.withValues(alpha: 0.35)
                : (isDark ? AppColors.hairlineDark : AppColors.hairlineLight),
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
        child: Center(
          child: Icon(
            isActive ? Icons.favorite : Icons.favorite_border,
            size: 20,
            color: AppColors.roseAccent,
          ),
        ),
      ),
    );
  }

  Widget _buildMosqueLeading(BuildContext context, bool isDark) {
    final mosqueProvider = context.watch<MosqueProvider>();
    final location =
        mosqueProvider.cityName.isNotEmpty &&
            mosqueProvider.cityName != 'Locating…'
        ? mosqueProvider.cityName
        : 'Jakarta, ID';

    return Row(
      children: [
        _buildProfileMenu(context, isDark),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Find Mosque',
              style: GoogleFonts.fraunces().copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.02,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 12,
                  color: isDark ? AppColors.primaryDark : AppColors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  location,
                  style: GoogleFonts.plusJakartaSans().copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.textMutedDark
                        : AppColors.textMutedLight,
                  ),
                ),
                const SizedBox(width: 4),
                InkWell(
                  onTap: () async {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Refreshing location…'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                    await mosqueProvider.refresh(forceRefreshLocation: true);
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Icon(
                      Icons.refresh,
                      size: 12,
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
      ],
    );
  }

  Widget _buildQiblaLeading(BuildContext context, bool isDark) {
    final qiblaProvider = context.watch<QiblaProvider>();
    final location =
        qiblaProvider.cityName.isNotEmpty &&
            qiblaProvider.cityName != 'Locating…'
        ? qiblaProvider.cityName
        : 'Jakarta, ID';

    return Row(
      children: [
        _buildProfileMenu(context, isDark),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Qibla Compass',
              style: GoogleFonts.fraunces().copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.02,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 12,
                  color: isDark ? AppColors.primaryDark : AppColors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  location,
                  style: GoogleFonts.plusJakartaSans().copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.textMutedDark
                        : AppColors.textMutedLight,
                  ),
                ),
                const SizedBox(width: 4),
                InkWell(
                  onTap: () async {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Refreshing location…'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                    await qiblaProvider.refresh(forceRefreshLocation: true);
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Icon(
                      Icons.refresh,
                      size: 12,
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
      ],
    );
  }
}
