import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../core/theme/app_colors.dart';
import '../core/theme/theme_provider.dart';
import '../core/models/unlock_config.dart';
import '../core/models/lock_schedule.dart';
import '../core/providers/focus_lock_provider.dart';
import '../core/providers/streak_provider.dart';
import '../core/providers/verse_provider.dart';
import '../core/providers/hadith_provider.dart';

class _ThemedColors {
  final Color surface;
  final Color card;
  final Color textMain;
  final Color textMuted;
  final Color hairline;
  final Color primary;
  final Color roseAccent;

  const _ThemedColors({
    required this.surface,
    required this.card,
    required this.textMain,
    required this.textMuted,
    required this.hairline,
    required this.primary,
    required this.roseAccent,
  });

  factory _ThemedColors.resolve(bool isDark) => isDark
      ? const _ThemedColors(
          surface: AppColors.surfaceDark,
          card: AppColors.cardDark,
          textMain: AppColors.textMainDark,
          textMuted: AppColors.textMutedDark,
          hairline: AppColors.hairlineDark,
          primary: AppColors.primaryDark,
          roseAccent: AppColors.roseAccent,
        )
      : const _ThemedColors(
          surface: AppColors.surfaceLight,
          card: AppColors.cardLight,
          textMain: AppColors.textMainLight,
          textMuted: AppColors.textMutedLight,
          hairline: AppColors.hairlineLight,
          primary: AppColors.primaryLight,
          roseAccent: AppColors.roseAccent,
        );
}

/// Full-screen lock overlay that blocks access to apps
class LockOverlayScreen extends StatefulWidget {
  final ActiveLockInfo? activeLockInfo;
  final int dailySkipAllowance;
  final int remainingSkips;
  final bool canSkip;
  final Future<bool> Function()? onSkip;
  final VoidCallback? onCloseViewWithCooldown;
  final VoidCallback? onOpenInav;
  final String? blockedAppName;
  final String? blockedPackageName;
  final UnlockConfig unlockConfig;
  final String? currentPrayerName;
  final VoidCallback? onUnlock;

  const LockOverlayScreen({
    super.key,
    this.activeLockInfo,
    this.dailySkipAllowance = 1,
    this.remainingSkips = 0,
    this.canSkip = false,
    this.onSkip,
    this.onCloseViewWithCooldown,
    this.onOpenInav,
    this.blockedAppName,
    this.blockedPackageName,
    this.unlockConfig = const UnlockConfig(method: UnlockMethod.waitItOut),
    this.currentPrayerName,
    this.onUnlock,
  });

  @override
  State<LockOverlayScreen> createState() => _LockOverlayScreenState();
}

class _LockOverlayScreenState extends State<LockOverlayScreen> {
  Timer? _countdownTimer;
  Timer? _headerTickTimer;
  int _waitRemainingSeconds = 0;
  int _waitTotalSeconds = 0;

  // Mark prayer state
  bool _prayerMarked = false;
  Timer? _prayerPollTimer;

  // Mindful pause choice (50/50 verse vs hadith)
  late final bool _mpUseVerse;

  @override
  void initState() {
    super.initState();
    _mpUseVerse = Random().nextBool();

    final info = widget.activeLockInfo;
    switch (widget.unlockConfig.method) {
      case UnlockMethod.waitItOut:
        final infoSecs = info?.remainingSeconds ?? 0;
        final cfgSecs = widget.unlockConfig.waitDurationSeconds;
        _waitTotalSeconds = (infoSecs > 0) ? infoSecs : cfgSecs;
        _waitRemainingSeconds = _waitTotalSeconds;
        _startCountdown();
        break;
      case UnlockMethod.markPrayed:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final streakProvider = context.read<StreakProvider>();
          final isPrayerLock =
              widget.activeLockInfo?.reason == LockReason.prayer;
          _prayerMarked = isPrayerLock && streakProvider.isCurrentPrayerCompleted;
          if (_prayerMarked) {
            Future.delayed(const Duration(milliseconds: 500), _unlock);
          } else if (isPrayerLock) {
            _startPrayerPoll();
          }
        });
        break;
      case UnlockMethod.mindfulPause:
      case UnlockMethod.typePhrase:
        break;
    }

    // Periodically rebuild header so countdown/progress updates
    _headerTickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_waitRemainingSeconds > 0) {
        setState(() => _waitRemainingSeconds--);
      } else {
        timer.cancel();
        _unlock();
      }
    });
  }

  void _startPrayerPoll() {
    _prayerPollTimer?.cancel();
    _prayerPollTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final streakProvider = context.read<StreakProvider>();
      if (streakProvider.isCurrentPrayerCompleted && !_prayerMarked) {
        setState(() => _prayerMarked = true);
        timer.cancel();
        Future.delayed(const Duration(milliseconds: 800), _unlock);
      }
    });
  }

  void _unlock() => widget.onUnlock?.call();

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _headerTickTimer?.cancel();
    _prayerPollTimer?.cancel();
    super.dispose();
  }

  TextStyle _textStyle({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w500,
    required Color color,
    double? height,
    FontStyle? fontStyle,
  }) =>
      GoogleFonts.plusJakartaSans().copyWith(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
        fontStyle: fontStyle,
      );

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().themeMode == ThemeMode.system
        ? MediaQuery.of(context).platformBrightness == Brightness.dark
        : context.watch<ThemeProvider>().isDarkMode;
    final colors = _ThemedColors.resolve(isDark);

    return Scaffold(
      backgroundColor: colors.surface,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [colors.surface, colors.card],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              _buildXButton(colors),
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 80, 24, 24),
                  child: Center(
                    // Reactive wrapper: FocusLockProvider's tick timer fires
                    // every 1s (in lock window) → this Consumer rebuilds,
                    // so header countdown, progress, skip stats all update.
                    child: Consumer<FocusLockProvider>(
                      builder: (context, flp, _) => Column(
                        children: [
                          _buildHeader(colors, flp),
                          const SizedBox(height: 8),
                          _buildBlockedAppLabel(colors),
                          const SizedBox(height: 24),
                          Expanded(
                            child: SingleChildScrollView(
                              child: _buildUnlockMethodUI(colors),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildBottomButtons(colors, flp),
                          const SizedBox(height: 16),
                          _buildQuote(colors),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildXButton(_ThemedColors colors) => Positioned(
        top: 4,
        right: 8,
        child: GestureDetector(
          onTap: () => widget.onCloseViewWithCooldown?.call(),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.close,
                  color: colors.textMuted,
                  size: 28,
                ),
                const SizedBox(height: 2),
                Text(
                  'Close 3s',
                  style: _textStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: colors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildHeader(_ThemedColors colors, FocusLockProvider flp) {
    final info = flp.getActiveLockInfo();
    final isPrayer = info?.reason == LockReason.prayer;
    final String label;
    final IconData icon;
    if (info != null) {
      label = info.label;
      icon = isPrayer ? Icons.mosque : Icons.menu_book;
    } else {
      label = 'Focus Time';
      icon = Icons.lock;
    }

    final remainingSecs = info?.remainingSeconds ?? 0;
    final String remainingText;
    final double progress;
    if (info != null) {
      remainingText = info.formattedRemaining;
      final total = info.endTime.difference(info.startTime).inSeconds;
      progress = total > 0
          ? (1 - (remainingSecs / total)).clamp(0.0, 1.0)
          : 0.0;
    } else {
      remainingText = '—';
      progress = 0.0;
    }

    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: colors.roseAccent.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.lock_rounded,
            size: 40,
            color: colors.roseAccent,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'LOCKED',
          style: _textStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: colors.textMain,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: colors.primary.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: colors.primary),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  isPrayer ? 'Prayer Time — $label' : label,
                  overflow: TextOverflow.ellipsis,
                  style: _textStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: colors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Unlocks in:  $remainingText',
          style: _textStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: colors.textMain,
          ),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: colors.hairline,
            valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildBlockedAppLabel(_ThemedColors colors) =>
      widget.blockedAppName != null
          ? Text(
              widget.blockedAppName!,
              style: _textStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.roseAccent,
              ),
            )
          : const SizedBox.shrink();

  Widget _buildBottomButtons(_ThemedColors colors, FocusLockProvider flp) {
    final canSkip = flp.canSkip;
    final remainingSkips = flp.remainingSkips;
    final allowance = flp.dailySkipAllowance;
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: OutlinedButton(
            onPressed: canSkip
                ? () async {
                    await widget.onSkip?.call();
                  }
                : null,
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.textMuted,
              side: BorderSide(color: colors.hairline, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              disabledForegroundColor: colors.textMuted.withValues(alpha: 0.4),
            ),
            child: Text(
              'Skip ($remainingSkips/$allowance)',
              style: _textStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: canSkip ? colors.textMain : colors.textMuted,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: () => widget.onOpenInav?.call(),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 4,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.open_in_new, size: 18),
                const SizedBox(width: 6),
                Text(
                  'Open INav',
                  style: _textStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuote(_ThemedColors colors) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colors.hairline.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.format_quote,
            color: colors.primary,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Prayer is better than sleep',
              style: _textStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: colors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnlockMethodUI(_ThemedColors colors) {
    switch (widget.unlockConfig.method) {
      case UnlockMethod.waitItOut:
        return _buildWaitItOutUI(colors);
      case UnlockMethod.markPrayed:
        return _buildMarkPrayedUI(colors);
      case UnlockMethod.mindfulPause:
        return _buildMindfulPauseUI(colors);
      case UnlockMethod.typePhrase:
        return _buildTypePhraseUI(colors);
    }
  }

  Widget _buildWaitItOutUI(_ThemedColors colors) {
    final total = _waitTotalSeconds > 0 ? _waitTotalSeconds : 1;
    final progress =
        (_waitTotalSeconds > 0 ? (_waitRemainingSeconds / total) : 0.0)
            .clamp(0.0, 1.0);
    return Column(
      children: [
        Text(
          'TIME REMAINING',
          style: _textStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: colors.textMuted,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: colors.primary.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Text(
            _formatWaitTime(_waitRemainingSeconds),
            style: _textStyle(
              fontSize: 42,
              fontWeight: FontWeight.w800,
              color: colors.primary,
            ).copyWith(fontFeatures: [const FontFeature.tabularFigures()]),
          ),
        ),
        const SizedBox(height: 20),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: 1.0 - progress,
            backgroundColor: colors.hairline,
            valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
            minHeight: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildMarkPrayedUI(_ThemedColors colors) {
    final isPrayerLock = widget.activeLockInfo?.reason == LockReason.prayer;
    return Consumer<StreakProvider>(
      builder: (context, streakProvider, _) {
        final completed = isPrayerLock &&
            (_prayerMarked || streakProvider.isCurrentPrayerCompleted);
        final String title;
        final String subtitle;
        final IconData icon;
        final Color iconColor;
        if (isPrayerLock) {
          title = completed ? 'Prayer Completed!' : 'Mark Prayer as Prayed';
          icon = completed ? Icons.check_circle : Icons.mosque;
          iconColor = completed ? Colors.green : colors.primary;
          subtitle = completed
              ? 'Unlocking app...'
              : widget.currentPrayerName != null
                  ? 'Mark ${widget.currentPrayerName} prayer as completed\nin INav to auto-unlock'
                  : 'Mark your current prayer as completed\nin INav to auto-unlock';
        } else {
          title = 'Custom Focus Session Active';
          icon = Icons.menu_book;
          iconColor = colors.primary;
          subtitle =
              'Auto-unlock by prayer streak is DISABLED during custom focus.\nUse Skip, wait for timer, or open INav to manage.';
        }

        return Column(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                icon,
                key: ValueKey<bool>(completed),
                size: 60,
                color: iconColor,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: _textStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: colors.textMain,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: _textStyle(
                fontSize: 12.5,
                color: colors.textMuted,
                height: 1.5,
              ),
            ),
            if (completed) ...[
              const SizedBox(height: 14),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildMindfulPauseUI(_ThemedColors colors) {
    if (_mpUseVerse) {
      final verse = context.watch<VerseProvider>().verse;
      final loading = context.watch<VerseProvider>().isLoading;
      return _buildContentCard(
        colors: colors,
        label: 'RANDOM VERSE',
        arabic: verse?.arabic,
        translation: verse?.translation,
        reference: verse != null
            ? '${verse.surahName} ${verse.ayahNumber}'
            : null,
        fallbackArabic: 'إِنَّ مَعَ الْعُسْرِ يُسْرًا',
        fallbackTranslation:
            'Indeed, with hardship comes ease.',
        fallbackReference: 'Surah Ash-Sharh 94:6',
        loading: loading,
      );
    } else {
      final hadith = context.watch<HadithProvider>().hadith;
      final loading = context.watch<HadithProvider>().isLoading;
      return _buildContentCard(
        colors: colors,
        label: 'RANDOM HADITH',
        arabic: hadith?.arabic,
        translation: hadith?.translation,
        reference: hadith != null
            ? '${hadith.narrator} — ${hadith.number}'
            : null,
        fallbackArabic:
            'إِنَّمَا الْأَعْمَالُ بِالنِّيَّاتِ',
        fallbackTranslation:
            'Actions are judged by intentions.',
        fallbackReference: 'Sahih al-Bukhari 1',
        loading: loading,
      );
    }
  }

  Widget _buildContentCard({
    required _ThemedColors colors,
    required String label,
    required String? arabic,
    required String? translation,
    required String? reference,
    required String fallbackArabic,
    required String fallbackTranslation,
    required String fallbackReference,
    required bool loading,
  }) {
    final ar = arabic ?? fallbackArabic;
    final tr = translation ?? fallbackTranslation;
    final ref = reference ?? fallbackReference;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: _textStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: colors.textMuted,
          ),
        ),
        const SizedBox(height: 10),
        if (loading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.hairline.withValues(alpha: 0.6)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  ar,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: _textStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: colors.textMain,
                    height: 1.8,
                  ),
                ),
                const SizedBox(height: 14),
                Divider(color: colors.hairline.withValues(alpha: 0.5), height: 1),
                const SizedBox(height: 14),
                Text(
                  '"$tr"',
                  textAlign: TextAlign.left,
                  style: _textStyle(
                    fontSize: 13.5,
                    fontStyle: FontStyle.italic,
                    color: colors.textMain,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '— $ref',
                  textAlign: TextAlign.left,
                  style: _textStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: colors.primary,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 10),
        Text(
          'Use buttons below to continue.',
          textAlign: TextAlign.center,
          style: _textStyle(
            fontSize: 11.5,
            color: colors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildTypePhraseUI(_ThemedColors colors) {
    final phrase = widget.unlockConfig.unlockPhrase.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'YOUR REMINDER',
          style: _textStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: colors.textMuted,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: colors.primary.withValues(alpha: 0.35),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.record_voice_over,
                size: 36,
                color: colors.primary,
              ),
              const SizedBox(height: 14),
              if (phrase.isNotEmpty)
                Text(
                  '"$phrase"',
                  textAlign: TextAlign.center,
                  style: _textStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.italic,
                    color: colors.primary,
                    height: 1.5,
                  ),
                )
              else
                Text(
                  '"Stay committed to what matters."',
                  textAlign: TextAlign.center,
                  style: _textStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                    color: colors.primary,
                    height: 1.5,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Remember why this focus session matters. Stay committed!',
          textAlign: TextAlign.center,
          style: _textStyle(
            fontSize: 12.5,
            color: colors.textMuted,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  String _formatWaitTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
