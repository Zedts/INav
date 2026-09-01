import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/legal_texts.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_images.dart';
import '../../widgets/auth/profile_sheet.dart';
import '../../widgets/auth/terms_privacy_modal.dart';
import '../auth/auth_screen.dart';
import 'focus_lock_config_screen.dart';
import 'prayer_notification_settings_screen.dart';

/// Settings screen - displays app preferences, accounts, support, and legal policies
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open link: $url'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open link: $url'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _sendEmail(BuildContext context) async {
    final emailUri = Uri(
      scheme: 'mailto',
      path: LegalTexts.contactEmail,
      queryParameters: {
        'subject': 'INav Support / Inquiry',
      },
    );
    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        await Clipboard.setData(const ClipboardData(text: LegalTexts.contactEmail));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Email copied to clipboard: ${LegalTexts.contactEmail}',
                style: GoogleFonts.plusJakartaSans(fontSize: 13),
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (_) {
      await Clipboard.setData(const ClipboardData(text: LegalTexts.contactEmail));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Email copied: ${LegalTexts.contactEmail}',
              style: GoogleFonts.plusJakartaSans(fontSize: 13),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _confirmLogout(BuildContext context) async {
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
  }

  void _showAboutDialog(BuildContext context, bool isDark) {
    final cardBg = isDark ? AppColors.cardDark : AppColors.cardLight;
    final border = isDark ? AppColors.hairlineDark : AppColors.hairlineLight;
    final textMain = isDark ? AppColors.textMainDark : AppColors.textMainLight;
    final textMuted = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
    final primary = Theme.of(context).colorScheme.primary;

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: border),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Vertical Centered Assets Image Icon
              SizedBox(
                width: 140,
                height: 58,
                child: Image.asset(
                  isDark ? AppImages.iconDark : AppImages.iconWhite,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 12),

              // INav Title & Version (Vertical below icon)
              Text(
                AppConstants.appName,
                style: GoogleFonts.fraunces(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: textMain,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Version ${AppConstants.version}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: primary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                style: GoogleFonts.ibmPlexSansArabic(
                  fontSize: 13,
                  color: textMuted,
                ),
              ),
              const SizedBox(height: 16),
              Divider(height: 1, thickness: 1, color: border),
              const SizedBox(height: 16),

              // Description
              Text(
                'INav is an Islamic companion app providing prayer times, Qibla compass, mosque finder, and Qur’an reading.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: textMain.withValues(alpha: 0.85),
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 18),

              // Copyright / Legalese on the very bottom under description
              Text(
                AppConstants.legalese,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),

              // Actions (View Licenses & Close)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      showLicensePage(
                        context: context,
                        applicationName: AppConstants.appName,
                        applicationVersion: AppConstants.version,
                        applicationLegalese: AppConstants.legalese,
                        applicationIcon: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: 64,
                            height: 64,
                            child: Image.asset(
                              isDark ? AppImages.iconDark : AppImages.iconWhite,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      );
                    },
                    child: Text(
                      'View Licenses',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Close',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final cardBg = isDark ? AppColors.cardDark : AppColors.cardLight;
    final border = isDark ? AppColors.hairlineDark : AppColors.hairlineLight;
    final textMuted = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
    final textMain = isDark ? AppColors.textMainDark : AppColors.textMainLight;
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        children: [
          // Account Header Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: border),
            ),
            child: user != null
                ? Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: primary.withValues(alpha: 0.15),
                        child: Text(
                          user.fullName.isNotEmpty
                              ? user.fullName[0].toUpperCase()
                              : 'U',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.fullName,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: textMain,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user.email,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Account Profile',
                        icon: Icon(Icons.tune_rounded, color: primary),
                        onPressed: () => ProfileSheet.show(context),
                      ),
                      IconButton(
                        tooltip: 'Log Out',
                        icon: const Icon(Icons.logout_rounded, color: AppColors.roseAccent),
                        onPressed: () => _confirmLogout(context),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: primary.withValues(alpha: 0.12),
                        child: Icon(Icons.person_outline, color: primary, size: 26),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sign in to INav',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: textMain,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Save bookmarks and focus lock settings',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                color: textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      FilledButton.tonal(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AuthScreen()),
                        ),
                        child: const Text('Log In'),
                      ),
                    ],
                  ),
          ),

          const SizedBox(height: 24),

          // Preferences Section
          _SectionTitle(title: 'PREFERENCES'),
          const SizedBox(height: 8),
          _SettingsGroup(
            children: [
              _SettingsTile(
                icon: Icons.notifications_active_outlined,
                title: 'Prayer Notifications & Adhan',
                subtitle: 'Customize prayer call reminders and alert sounds',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PrayerNotificationSettingsScreen(),
                  ),
                ),
              ),
              _DividerLine(border: border),
              _SettingsTile(
                icon: Icons.lock_clock_outlined,
                title: 'Focus Lock & App Blocker',
                subtitle: 'Prevent distractions during prayer times',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const FocusLockConfigScreen(),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Legal & Policies Section
          _SectionTitle(title: 'LEGAL & COMPLIANCE'),
          const SizedBox(height: 8),
          _SettingsGroup(
            children: [
              _SettingsTile(
                icon: Icons.description_outlined,
                title: 'Terms of Service',
                subtitle: 'User agreement, location terms, and policies (Indonesia)',
                onTap: () => TermsPrivacyModal.show(
                  context,
                  title: 'Terms of Service',
                ),
              ),
              _DividerLine(border: border),
              _SettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                subtitle: 'Data usage, retention, and deletion rights',
                onTap: () => TermsPrivacyModal.show(
                  context,
                  title: 'Privacy Policy',
                ),
              ),
              _DividerLine(border: border),
              _SettingsTile(
                icon: Icons.open_in_new_rounded,
                title: 'TermsFeed Live Privacy Policy',
                subtitle: 'View live generated termsfeed.com document',
                onTap: () => _openUrl(context, LegalTexts.privacyPolicyUrl),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Support & Developer Section
          _SectionTitle(title: 'SUPPORT & ABOUT'),
          const SizedBox(height: 8),
          _SettingsGroup(
            children: [
              _SettingsTile(
                icon: Icons.mail_outline_rounded,
                title: 'Contact Support / Feedback',
                subtitle: LegalTexts.contactEmail,
                onTap: () => _sendEmail(context),
              ),
              _DividerLine(border: border),
              _SettingsTile(
                icon: Icons.public_rounded,
                title: 'Official Website',
                subtitle: LegalTexts.websiteUrl,
                onTap: () => _openUrl(context, LegalTexts.websiteUrl),
              ),
              _DividerLine(border: border),
              _SettingsTile(
                icon: Icons.info_outline_rounded,
                title: 'About ${AppConstants.appName}',
                subtitle: 'Islamic Reminder Companion • Version ${AppConstants.version} (Indonesia)',
                onTap: () => _showAboutDialog(context, isDark),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textMuted = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: textMuted,
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.cardDark : AppColors.cardLight;
    final border = isDark ? AppColors.hairlineDark : AppColors.hairlineLight;

    return Material(
      color: cardBg,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: border),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final textMain = isDark ? AppColors.textMainDark : AppColors.textMainLight;
    final textMuted = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: primary, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textMain,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11.5,
          color: textMuted,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        size: 20,
        color: textMuted,
      ),
    );
  }
}

class _DividerLine extends StatelessWidget {
  const _DividerLine({required this.border});
  final Color border;

  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, thickness: 1, color: border, indent: 56);
  }
}
