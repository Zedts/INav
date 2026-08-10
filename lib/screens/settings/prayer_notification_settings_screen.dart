import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/models/prayer_notification_settings_model.dart';
import '../../core/providers/prayer_provider.dart';
import '../../core/providers/prayer_settings_provider.dart';
import '../../core/theme/app_colors.dart';

class PrayerNotificationSettingsScreen extends StatefulWidget {
  const PrayerNotificationSettingsScreen({super.key});

  @override
  State<PrayerNotificationSettingsScreen> createState() =>
      _PrayerNotificationSettingsScreenState();
}

class _PrayerNotificationSettingsScreenState
    extends State<PrayerNotificationSettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PrayerSettingsProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settingsProvider = context.watch<PrayerSettingsProvider>();
    final prayerProvider = context.watch<PrayerProvider>();

    return Scaffold(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, isDark, settingsProvider),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                children: [
                  _buildMasterToggleCard(isDark, settingsProvider),
                  const SizedBox(height: 20),
                  _buildSectionTitle(isDark, 'PER-PRAYER SETTINGS'),
                  const SizedBox(height: 8),
                  ...settingsProvider.settings.map(
                    (setting) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildPrayerCard(
                        isDark,
                        settingsProvider,
                        prayerProvider,
                        setting,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildSectionTitle(isDark, 'ADHAN PLAYBACK'),
                  const SizedBox(height: 8),
                  _buildAdhanPlaybackCard(isDark, settingsProvider),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    bool isDark,
    PrayerSettingsProvider provider,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? AppColors.hairlineDark.withValues(alpha: 0.2)
                      : AppColors.hairlineLight.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.arrow_back,
                size: 20,
                color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Prayer Notifications',
                  style: GoogleFonts.plusJakartaSans().copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppColors.textMainDark
                        : AppColors.textMainLight,
                  ),
                ),
                Text(
                  'Adhan & alert preferences',
                  style: GoogleFonts.plusJakartaSans().copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.textMutedDark
                        : AppColors.textMutedLight,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              provider.resetToDefaults();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Prayer notification settings reset'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Text(
                'Reset',
                style: GoogleFonts.plusJakartaSans().copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(bool isDark, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: GoogleFonts.plusJakartaSans().copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration(bool isDark) {
    return BoxDecoration(
      color: isDark ? AppColors.cardDark : AppColors.cardLight,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: isDark
            ? AppColors.hairlineDark.withValues(alpha: 0.2)
            : AppColors.hairlineLight.withValues(alpha: 0.2),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
          blurRadius: 3,
          offset: const Offset(0, 1),
        ),
      ],
    );
  }

  Widget _buildMasterToggleCard(
    bool isDark,
    PrayerSettingsProvider provider,
  ) {
    final primaryColor = isDark ? AppColors.primaryDark : AppColors.primaryLight;

    return Container(
      decoration: _cardDecoration(isDark),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: isDark ? 0.15 : 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.notifications_active, size: 20, color: primaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'All Prayer Notifications',
                  style: GoogleFonts.plusJakartaSans().copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.textMainDark
                        : AppColors.textMainLight,
                  ),
                ),
                Text(
                  'Master switch for all 5 daily prayers',
                  style: GoogleFonts.plusJakartaSans().copyWith(
                    fontSize: 11,
                    color: isDark
                        ? AppColors.textMutedDark
                        : AppColors.textMutedLight,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: provider.masterEnabled,
            activeTrackColor: primaryColor,
            onChanged: (value) => provider.setMasterEnabled(value),
          ),
        ],
      ),
    );
  }

  Color _prayerAccent(String key, bool isDark) {
    switch (key) {
      case 'dhuhr':
        return AppColors.roseAccent;
      case 'asr':
        return AppColors.teal;
      case 'isha':
        return AppColors.primary;
      default:
        return isDark ? AppColors.primaryDark : AppColors.primaryLight;
    }
  }

  String? _prayerTime(PrayerProvider provider, String key) {
    final times = provider.prayerTimes;
    if (times == null) return null;
    switch (key) {
      case 'fajr':
        return times.fajr;
      case 'dhuhr':
        return times.dhuhr;
      case 'asr':
        return times.asr;
      case 'maghrib':
        return times.maghrib;
      case 'isha':
        return times.isha;
      default:
        return null;
    }
  }

  Widget _buildPrayerCard(
    bool isDark,
    PrayerSettingsProvider provider,
    PrayerProvider prayerProvider,
    PrayerNotificationSetting setting,
  ) {
    final accent = _prayerAccent(setting.key, isDark);
    final time = _prayerTime(prayerProvider, setting.key);
    final dividerColor = isDark
        ? AppColors.hairlineDark.withValues(alpha: 0.2)
        : AppColors.hairlineLight.withValues(alpha: 0.2);

    return Container(
      decoration: _cardDecoration(isDark),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: isDark ? 0.15 : 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    prayerProvider.getPrayerIcon(setting.name),
                    size: 20,
                    color: accent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        setting.name,
                        style: GoogleFonts.plusJakartaSans().copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.textMainDark
                              : AppColors.textMainLight,
                        ),
                      ),
                      if (time != null)
                        Text(
                          time,
                          style: GoogleFonts.plusJakartaSans().copyWith(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.textMutedDark
                                : AppColors.textMutedLight,
                          ),
                        ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: setting.enabled,
                  activeTrackColor: isDark
                      ? AppColors.primaryDark
                      : AppColors.primaryLight,
                  onChanged: (value) =>
                      provider.setPrayerEnabled(setting.key, value),
                ),
              ],
            ),
          ),
          if (setting.enabled) ...[
            Divider(height: 1, thickness: 1, color: dividerColor),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildReminderRow(isDark, provider, setting),
                  const SizedBox(height: 12),
                  _buildOptionSwitchRow(
                    isDark,
                    label: 'Play Adhan',
                    value: setting.playAdhan,
                    onChanged: (value) =>
                        provider.setPlayAdhan(setting.key, value),
                  ),
                  const SizedBox(height: 4),
                  _buildOptionSwitchRow(
                    isDark,
                    label: 'Vibrate',
                    value: setting.vibrate,
                    onChanged: (value) =>
                        provider.setVibrate(setting.key, value),
                  ),
                ],
              ),
            ),
          ] else ...[
            Divider(height: 1, thickness: 1, color: dividerColor),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Notifications off for ${setting.name}',
                  style: GoogleFonts.plusJakartaSans().copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textMutedDark
                        : AppColors.textMutedLight,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReminderRow(
    bool isDark,
    PrayerSettingsProvider provider,
    PrayerNotificationSetting setting,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Remind before',
          style: GoogleFonts.plusJakartaSans().copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
          ),
        ),
        Row(
          children: [
            _buildStepperButton(
              isDark,
              icon: Icons.remove,
              onTap: () => provider.adjustPreReminder(
                setting.key,
                -PrayerNotificationSetting.reminderStep,
              ),
            ),
            SizedBox(
              width: 56,
              child: Text(
                '${setting.preReminderMinutes} min',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans().copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.textMainDark
                      : AppColors.textMainLight,
                ),
              ),
            ),
            _buildStepperButton(
              isDark,
              icon: Icons.add,
              onTap: () => provider.adjustPreReminder(
                setting.key,
                PrayerNotificationSetting.reminderStep,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStepperButton(
    bool isDark, {
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark
              ? AppColors.hairlineDark.withValues(alpha: 0.2)
              : AppColors.cardLight,
        ),
        child: Icon(
          icon,
          size: 14,
          color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
        ),
      ),
    );
  }

  Widget _buildOptionSwitchRow(
    bool isDark, {
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans().copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
          ),
        ),
        Switch.adaptive(
          value: value,
          activeTrackColor: isDark
              ? AppColors.primaryDark
              : AppColors.primaryLight,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildAdhanPlaybackCard(
    bool isDark,
    PrayerSettingsProvider provider,
  ) {
    final primaryColor = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final dividerColor = isDark
        ? AppColors.hairlineDark.withValues(alpha: 0.2)
        : AppColors.hairlineLight.withValues(alpha: 0.2);

    return Container(
      decoration: _cardDecoration(isDark),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.volume_up, size: 16, color: primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          'Adhan Volume',
                          style: GoogleFonts.plusJakartaSans().copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.textMainDark
                                : AppColors.textMainLight,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${provider.adhanVolume}%',
                      style: GoogleFonts.plusJakartaSans().copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.textMutedDark
                            : AppColors.textMutedLight,
                      ),
                    ),
                  ],
                ),
                Slider.adaptive(
                  value: provider.adhanVolume.toDouble(),
                  min: 0,
                  max: 100,
                  divisions: 20,
                  activeColor: primaryColor,
                  onChanged: (value) => provider.setAdhanVolume(value.round()),
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: dividerColor),
          _buildPlaybackToggleRow(
            isDark,
            icon: Icons.notifications_on,
            iconColor: AppColors.roseAccent,
            title: 'Play Even On Silent',
            subtitle: "Overrides your phone's silent switch",
            value: provider.playOnSilent,
            onChanged: (value) => provider.setPlayOnSilent(value),
          ),
          Divider(height: 1, thickness: 1, color: dividerColor),
          _buildPlaybackToggleRow(
            isDark,
            icon: Icons.vibration,
            iconColor: AppColors.teal,
            title: 'Vibrate on Silent',
            subtitle: 'Buzz instead when phone is muted',
            value: provider.vibrateOnSilent,
            onChanged: (value) => provider.setVibrateOnSilent(value),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaybackToggleRow(
    bool isDark, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: isDark ? 0.15 : 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans().copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.textMainDark
                        : AppColors.textMainLight,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans().copyWith(
                    fontSize: 11,
                    color: isDark
                        ? AppColors.textMutedDark
                        : AppColors.textMutedLight,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeTrackColor: isDark
                ? AppColors.primaryDark
                : AppColors.primaryLight,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
