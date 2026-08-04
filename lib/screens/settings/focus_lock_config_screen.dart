import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Focus Lock Configuration Screen
/// Allows users to configure which apps to lock during prayer times or custom schedules
class FocusLockConfigScreen extends StatefulWidget {
  const FocusLockConfigScreen({super.key});

  @override
  State<FocusLockConfigScreen> createState() => _FocusLockConfigScreenState();
}

class _FocusLockConfigScreenState extends State<FocusLockConfigScreen> {
  // Master toggle
  bool _masterEnabled = true;

  // Apps to lock state
  final Map<String, bool> _lockedApps = {
    'instagram': true,
    'tiktok': true,
    'youtube': true,
    'facebook': false,
    'x': false,
  };

  // Lock schedule state
  bool _lockDuringPrayer = true;
  final Map<String, bool> _prayerTriggers = {
    'fajr': true,
    'dhuhr': true,
    'asr': true,
    'maghrib': true,
    'isha': true,
  };

  int _startOffsetMin = 0;
  int _lockDurationMin = 20;

  // Custom focus times
  final List<Map<String, dynamic>> _customSchedules = [];

  // Unlock method
  String _unlockMethod =
      'markPrayed'; // waitItOut, markPrayed, mindfulPause, typePhrase
  int _mindfulPauseSeconds = 60;
  String _unlockPhrase = 'Prayer comes first';

  // Exceptions & limits
  bool _allowEmergency = true;
  int _dailySkipAllowance = 1;
  bool _preventUninstall = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, isDark),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                children: [
                  // Master toggle
                  _buildMasterToggleCard(isDark),

                  const SizedBox(height: 20),

                  // Apps to lock section
                  _buildAppsToLockSection(isDark),

                  const SizedBox(height: 20),

                  // Lock schedule section
                  _buildLockScheduleSection(isDark),

                  const SizedBox(height: 20),

                  // Custom Focus Times section
                  _buildCustomFocusTimesSection(isDark),

                  const SizedBox(height: 20),

                  // Unlock Method section
                  _buildUnlockMethodSection(isDark),

                  const SizedBox(height: 20),

                  // Exceptions & limits section
                  _buildExceptionsSection(isDark),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Header with back button, title and reset action
  Widget _buildHeader(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          // Back button (Navigator.pop)
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark
                      ? AppColors.borderDark.withValues(alpha: 0.8)
                      : AppColors.borderLight.withValues(alpha: 0.8),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.arrow_back,
                size: 20,
                color: isDark
                    ? AppColors.textMainDark
                    : AppColors.textMainLight,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Focus Lock',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppColors.textMainDark
                        : AppColors.textMainLight,
                  ),
                ),
                Text(
                  'App blocking & focus schedules',
                  style: TextStyle(
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
            onTap: _resetToDefaults,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Text(
                'Reset',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.primaryDark
                      : AppColors.primaryLight,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMasterToggleCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? AppColors.borderDark.withValues(alpha: 0.8)
              : AppColors.borderLight.withValues(alpha: 0.8),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.grey).withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFE11D48).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.lock_rounded,
              color: Color(0xFFE11D48),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enable Focus Lock',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.textMainDark
                        : AppColors.textMainLight,
                  ),
                ),
                Text(
                  'Block distracting apps during focus windows',
                  style: TextStyle(
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
            value: _masterEnabled,
            activeTrackColor: isDark
                ? AppColors.primaryDark
                : AppColors.primaryLight,
            onChanged: (value) {
              setState(() => _masterEnabled = value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppsToLockSection(bool isDark) {
    final apps = [
      _AppItem(
        'instagram',
        'Instagram',
        Icons.photo_camera,
        const Color(0xFFD946EF),
      ),
      _AppItem('tiktok', 'TikTok', Icons.music_note, const Color(0xFF475569)),
      _AppItem(
        'youtube',
        'YouTube',
        Icons.play_circle_filled,
        const Color(0xFFEF4444),
      ),
      _AppItem('facebook', 'Facebook', Icons.thumb_up, const Color(0xFF2563EB)),
      _AppItem(
        'x',
        'X (Twitter)',
        Icons.chat_bubble_outline,
        const Color(0xFF64748B),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'APPS TO LOCK',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.textMutedDark
                      : AppColors.textMutedLight,
                  letterSpacing: 1.2,
                ),
              ),
              // Add Apps button
              ElevatedButton.icon(
                onPressed: _showAddAppsDialog,
                icon: const Icon(Icons.add_circle_outline, size: 16),
                label: const Text('Add Apps'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark
                      ? AppColors.primaryDark
                      : AppColors.primaryLight,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? AppColors.borderDark.withValues(alpha: 0.8)
                  : AppColors.borderLight.withValues(alpha: 0.8),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : Colors.grey).withValues(
                  alpha: 0.1,
                ),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: apps.asMap().entries.map((entry) {
              final index = entry.key;
              final app = entry.value;
              final isLocked = _lockedApps[app.key] ?? false;

              return Column(
                children: [
                  if (index > 0)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: isDark
                          ? const Color(0xFF1E293B).withValues(alpha: 0.8)
                          : const Color(0xFFF1F5F9),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: app.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(app.icon, color: app.color, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            app.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.textMainDark
                                  : AppColors.textMainLight,
                            ),
                          ),
                        ),
                        Switch.adaptive(
                          value: isLocked,
                          activeTrackColor: isDark
                              ? AppColors.primaryDark
                              : AppColors.primaryLight,
                          onChanged: (value) {
                            setState(() => _lockedApps[app.key] = value);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildLockScheduleSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'LOCK SCHEDULE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? AppColors.textMutedDark
                  : AppColors.textMutedLight,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? AppColors.borderDark.withValues(alpha: 0.8)
                  : AppColors.borderLight.withValues(alpha: 0.8),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : Colors.grey).withValues(
                  alpha: 0.1,
                ),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Lock during prayer times toggle
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color:
                            (isDark
                                    ? AppColors.primaryDark
                                    : AppColors.primaryLight)
                                .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.schedule,
                        color: isDark
                            ? AppColors.primaryDark
                            : AppColors.primaryLight,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lock During Prayer Times',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.textMainDark
                                  : AppColors.textMainLight,
                            ),
                          ),
                          Text(
                            'Uses today\'s Adhan schedule',
                            style: TextStyle(
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
                      value: _lockDuringPrayer,
                      activeTrackColor: isDark
                          ? AppColors.primaryDark
                          : AppColors.primaryLight,
                      onChanged: (value) {
                        setState(() => _lockDuringPrayer = value);
                      },
                    ),
                  ],
                ),
              ),

              // Prayer trigger chips and timing controls
              if (_lockDuringPrayer) ...[
                Divider(
                  height: 1,
                  thickness: 1,
                  color: isDark
                      ? const Color(0xFF1E293B).withValues(alpha: 0.8)
                      : const Color(0xFFF1F5F9),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LOCKS DURING',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.textMutedDark
                              : AppColors.textMutedLight,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildPrayerChip('fajr', 'Fajr', isDark),
                          _buildPrayerChip('dhuhr', 'Dhuhr', isDark),
                          _buildPrayerChip('asr', 'Asr', isDark),
                          _buildPrayerChip('maghrib', 'Maghrib', isDark),
                          _buildPrayerChip('isha', 'Isha', isDark),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Start offset control
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Starts before Adhan',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.textMainDark
                                  : AppColors.textMainLight,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove, size: 18),
                                onPressed: () {
                                  setState(() {
                                    _startOffsetMin = (_startOffsetMin - 5)
                                        .clamp(0, 60);
                                  });
                                },
                                style: IconButton.styleFrom(
                                  backgroundColor: isDark
                                      ? const Color(0xFF1E293B)
                                      : const Color(0xFFF1F5F9),
                                  minimumSize: const Size(28, 28),
                                ),
                              ),
                              SizedBox(
                                width: 64,
                                child: Text(
                                  '$_startOffsetMin min',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? AppColors.textMainDark
                                        : AppColors.textMainLight,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add, size: 18),
                                onPressed: () {
                                  setState(() {
                                    _startOffsetMin = (_startOffsetMin + 5)
                                        .clamp(0, 60);
                                  });
                                },
                                style: IconButton.styleFrom(
                                  backgroundColor: isDark
                                      ? const Color(0xFF1E293B)
                                      : const Color(0xFFF1F5F9),
                                  minimumSize: const Size(28, 28),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Lock duration control
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Lock duration',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.textMainDark
                                  : AppColors.textMainLight,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove, size: 18),
                                onPressed: () {
                                  setState(() {
                                    _lockDurationMin = (_lockDurationMin - 5)
                                        .clamp(5, 120);
                                  });
                                },
                                style: IconButton.styleFrom(
                                  backgroundColor: isDark
                                      ? const Color(0xFF1E293B)
                                      : const Color(0xFFF1F5F9),
                                  minimumSize: const Size(28, 28),
                                ),
                              ),
                              SizedBox(
                                width: 64,
                                child: Text(
                                  '$_lockDurationMin min',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? AppColors.textMainDark
                                        : AppColors.textMainLight,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add, size: 18),
                                onPressed: () {
                                  setState(() {
                                    _lockDurationMin = (_lockDurationMin + 5)
                                        .clamp(5, 120);
                                  });
                                },
                                style: IconButton.styleFrom(
                                  backgroundColor: isDark
                                      ? const Color(0xFF1E293B)
                                      : const Color(0xFFF1F5F9),
                                  minimumSize: const Size(28, 28),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCustomFocusTimesSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CUSTOM FOCUS TIMES',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.textMutedDark
                      : AppColors.textMutedLight,
                  letterSpacing: 1.2,
                ),
              ),
              // Add button styled like Add Apps
              ElevatedButton.icon(
                onPressed: _addCustomSchedule,
                icon: const Icon(Icons.add_circle_outline, size: 16),
                label: const Text('Add Custom Time'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark
                      ? AppColors.primaryDark
                      : AppColors.primaryLight,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (_customSchedules.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'No custom focus times yet — tap "Add Custom Time" for blocks like study time or bedtime.',
              style: TextStyle(
                fontSize: 11,
                color: isDark
                    ? AppColors.textMutedDark
                    : AppColors.textMutedLight,
              ),
            ),
          )
        else
          ..._customSchedules.asMap().entries.map((entry) {
            final index = entry.key;
            final schedule = entry.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.cardLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? AppColors.borderDark.withValues(alpha: 0.8)
                        : AppColors.borderLight.withValues(alpha: 0.8),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isDark ? Colors.black : Colors.grey).withValues(
                        alpha: 0.08,
                      ),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: schedule['label'],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.textMainDark
                              : AppColors.textMainLight,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Label',
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            color: isDark
                                ? AppColors.textMutedDark
                                : AppColors.textMutedLight,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _customSchedules[index]['label'] = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Time pickers
                    _buildTimeField(schedule['start'], isDark, (time) {
                      setState(() {
                        _customSchedules[index]['start'] = time;
                      });
                    }),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        'to',
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark
                              ? AppColors.textMutedDark
                              : AppColors.textMutedLight,
                        ),
                      ),
                    ),
                    _buildTimeField(schedule['end'], isDark, (time) {
                      setState(() {
                        _customSchedules[index]['end'] = time;
                      });
                    }),
                    const SizedBox(width: 8),
                    Transform.scale(
                      scale: 0.85,
                      child: Switch.adaptive(
                        value: schedule['enabled'],
                        activeTrackColor: isDark
                            ? AppColors.primaryDark
                            : AppColors.primaryLight,
                        onChanged: (value) {
                          setState(() {
                            _customSchedules[index]['enabled'] = value;
                          });
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      iconSize: 18,
                      color: const Color(0xFFE11D48),
                      onPressed: () {
                        setState(() {
                          _customSchedules.removeAt(index);
                        });
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildTimeField(String time, bool isDark, Function(String) onChanged) {
    return GestureDetector(
      onTap: () async {
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(
            hour: int.parse(time.split(':')[0]),
            minute: int.parse(time.split(':')[1]),
          ),
        );
        if (picked != null) {
          onChanged(
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}',
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          time,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
          ),
        ),
      ),
    );
  }

  Widget _buildUnlockMethodSection(bool isDark) {
    final dividerColor = isDark
        ? AppColors.borderDark.withValues(alpha: 0.8)
        : AppColors.borderLight.withValues(alpha: 0.8);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(isDark, 'UNLOCK METHOD'),
        const SizedBox(height: 8),
        Column(
          children: [
            _buildUnlockMethodCard(
              isDark,
              method: 'waitItOut',
              icon: Icons.hourglass_bottom,
              title: 'Wait It Out',
              description: 'A forced countdown — no early exit.',
              dividerColor: dividerColor,
            ),
            const SizedBox(height: 10),
            _buildUnlockMethodCard(
              isDark,
              method: 'markPrayed',
              icon: Icons.check_circle_outline,
              title: 'Mark Prayer as Prayed',
              description: 'Auto-unlocks once you log the prayer.',
              dividerColor: dividerColor,
            ),
            const SizedBox(height: 10),
            _buildUnlockMethodCard(
              isDark,
              method: 'mindfulPause',
              icon: Icons.air,
              title: 'Mindful Pause',
              description: 'A short breathing pause before you continue.',
              dividerColor: dividerColor,
              showExtraControl: _unlockMethod == 'mindfulPause',
              extraControl: _buildMindfulPauseControl(isDark),
            ),
            const SizedBox(height: 10),
            _buildUnlockMethodCard(
              isDark,
              method: 'typePhrase',
              icon: Icons.text_fields,
              title: 'Type a Reminder Phrase',
              description: 'Type a short phrase to confirm your intention.',
              dividerColor: dividerColor,
              showExtraControl: _unlockMethod == 'typePhrase',
              extraControl: _buildTypePhraseControl(isDark),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUnlockMethodCard(
    bool isDark, {
    required String method,
    required IconData icon,
    required String title,
    required String description,
    required Color dividerColor,
    bool showExtraControl = false,
    Widget? extraControl,
  }) {
    final isSelected = _unlockMethod == method;

    return GestureDetector(
      onTap: () {
        setState(() {
          _unlockMethod = method;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? (isDark ? AppColors.primaryDark : AppColors.primaryLight)
                : (isDark
                      ? AppColors.borderDark.withValues(alpha: 0.8)
                      : AppColors.borderLight.withValues(alpha: 0.8)),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.black : Colors.grey).withValues(
                alpha: 0.08,
              ),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark
                                ? AppColors.primaryDark
                                : AppColors.primaryLight)
                          : (isDark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFF1F5F9)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      size: 18,
                      color: isSelected
                          ? Colors.white
                          : (isDark
                                ? AppColors.textMutedDark
                                : AppColors.textMutedLight),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.textMainDark
                                : AppColors.textMainLight,
                          ),
                        ),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.textMutedDark
                                : AppColors.textMutedLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isSelected ? Icons.check_circle : Icons.circle_outlined,
                    size: 20,
                    color: isSelected
                        ? (isDark
                              ? AppColors.primaryDark
                              : AppColors.primaryLight)
                        : (isDark
                              ? const Color(0xFF475569)
                              : const Color(0xFFCBD5E1)),
                  ),
                ],
              ),
            ),
            if (showExtraControl && extraControl != null) ...[
              Divider(height: 1, thickness: 1, color: dividerColor),
              Padding(padding: const EdgeInsets.all(16), child: extraControl),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMindfulPauseControl(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Pause length',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove, size: 18),
              onPressed: () {
                setState(() {
                  _mindfulPauseSeconds = (_mindfulPauseSeconds - 15).clamp(
                    15,
                    300,
                  );
                });
              },
              style: IconButton.styleFrom(
                backgroundColor: isDark
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFF1F5F9),
                minimumSize: const Size(28, 28),
              ),
            ),
            SizedBox(
              width: 48,
              child: Text(
                '${_mindfulPauseSeconds}s',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.textMainDark
                      : AppColors.textMainLight,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add, size: 18),
              onPressed: () {
                setState(() {
                  _mindfulPauseSeconds = (_mindfulPauseSeconds + 15).clamp(
                    15,
                    300,
                  );
                });
              },
              style: IconButton.styleFrom(
                backgroundColor: isDark
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFF1F5F9),
                minimumSize: const Size(28, 28),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTypePhraseControl(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PHRASE TO TYPE',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: _unlockPhrase,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark
                ? const Color(0xFF1E293B)
                : const Color(0xFFF1F5F9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            hintText: 'Enter reminder phrase',
            hintStyle: TextStyle(
              color: isDark
                  ? AppColors.textMutedDark
                  : AppColors.textMutedLight,
            ),
          ),
          onChanged: (value) {
            setState(() {
              _unlockPhrase = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildSectionTitle(bool isDark, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
        ),
      ),
    );
  }

  Widget _buildExceptionsSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'EXCEPTIONS & LIMITS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? AppColors.textMutedDark
                  : AppColors.textMutedLight,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? AppColors.borderDark.withValues(alpha: 0.8)
                  : AppColors.borderLight.withValues(alpha: 0.8),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : Colors.grey).withValues(
                  alpha: 0.1,
                ),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Allow emergency calls
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.phone,
                        color: Color(0xFF10B981),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Allow Calls & Messages',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.textMainDark
                                  : AppColors.textMainLight,
                            ),
                          ),
                          Text(
                            'Emergency contact apps stay unlocked',
                            style: TextStyle(
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
                      value: _allowEmergency,
                      activeTrackColor: isDark
                          ? AppColors.primaryDark
                          : AppColors.primaryLight,
                      onChanged: (value) {
                        setState(() => _allowEmergency = value);
                      },
                    ),
                  ],
                ),
              ),

              Divider(
                height: 1,
                thickness: 1,
                color: isDark
                    ? const Color(0xFF1E293B).withValues(alpha: 0.8)
                    : const Color(0xFFF1F5F9),
              ),

              // Daily skip allowance
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Daily Skip Allowance',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.textMainDark
                                  : AppColors.textMainLight,
                            ),
                          ),
                          Text(
                            'Times you can skip per day',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.textMutedDark
                                  : AppColors.textMutedLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, size: 18),
                          onPressed: () {
                            setState(() {
                              _dailySkipAllowance = (_dailySkipAllowance - 1)
                                  .clamp(0, 5);
                            });
                          },
                          style: IconButton.styleFrom(
                            backgroundColor: isDark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFF1F5F9),
                            minimumSize: const Size(28, 28),
                          ),
                        ),
                        SizedBox(
                          width: 48,
                          child: Text(
                            '$_dailySkipAllowance',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.textMainDark
                                  : AppColors.textMainLight,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, size: 18),
                          onPressed: () {
                            setState(() {
                              _dailySkipAllowance = (_dailySkipAllowance + 1)
                                  .clamp(0, 5);
                            });
                          },
                          style: IconButton.styleFrom(
                            backgroundColor: isDark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFF1F5F9),
                            minimumSize: const Size(28, 28),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Divider(
                height: 1,
                thickness: 1,
                color: isDark
                    ? const Color(0xFF1E293B).withValues(alpha: 0.8)
                    : const Color(0xFFF1F5F9),
              ),

              // Prevent uninstall
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.security,
                        color: Color(0xFFF59E0B),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Prevent Uninstall During Lock',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.textMainDark
                                  : AppColors.textMainLight,
                            ),
                          ),
                          Text(
                            'Requires device admin permission',
                            style: TextStyle(
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
                      value: _preventUninstall,
                      activeTrackColor: isDark
                          ? AppColors.primaryDark
                          : AppColors.primaryLight,
                      onChanged: (value) {
                        setState(() => _preventUninstall = value);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPrayerChip(String key, String label, bool isDark) {
    final isSelected = _prayerTriggers[key] ?? false;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (value) {
        setState(() => _prayerTriggers[key] = value);
      },
      backgroundColor: isDark
          ? const Color(0xFF1E293B)
          : const Color(0xFFF1F5F9),
      selectedColor: (isDark ? AppColors.primaryDark : AppColors.primaryLight)
          .withValues(alpha: 0.2),
      checkmarkColor: isDark ? AppColors.primaryDark : AppColors.primaryLight,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: isSelected
            ? (isDark ? AppColors.primaryDark : AppColors.primaryLight)
            : (isDark ? AppColors.textMainDark : AppColors.textMainLight),
      ),
      side: BorderSide(
        color: isSelected
            ? (isDark ? AppColors.primaryDark : AppColors.primaryLight)
            : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
        width: 1,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  void _addCustomSchedule() {
    setState(() {
      _customSchedules.add({
        'label': 'Focus Time',
        'start': '21:00',
        'end': '22:00',
        'enabled': true,
      });
    });
  }

  void _showAddAppsDialog() {
    // Placeholder for future implementation
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Apps'),
        content: const Text(
          'App selection from device will be implemented in a future update.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _resetToDefaults() {
    setState(() {
      _masterEnabled = true;
      _lockedApps['instagram'] = true;
      _lockedApps['tiktok'] = true;
      _lockedApps['youtube'] = true;
      _lockedApps['facebook'] = false;
      _lockedApps['x'] = false;
      _lockDuringPrayer = true;
      _prayerTriggers['fajr'] = true;
      _prayerTriggers['dhuhr'] = true;
      _prayerTriggers['asr'] = true;
      _prayerTriggers['maghrib'] = true;
      _prayerTriggers['isha'] = true;
      _startOffsetMin = 0;
      _lockDurationMin = 20;
      _customSchedules.clear();
      _unlockMethod = 'markPrayed';
      _mindfulPauseSeconds = 60;
      _unlockPhrase = 'Prayer comes first';
      _allowEmergency = true;
      _dailySkipAllowance = 1;
      _preventUninstall = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reset to default settings'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

/// Helper class for app item data
class _AppItem {
  final String key;
  final String name;
  final IconData icon;
  final Color color;

  _AppItem(this.key, this.name, this.icon, this.color);
}
