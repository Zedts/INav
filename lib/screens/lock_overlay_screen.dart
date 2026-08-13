import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../core/theme/app_colors.dart';
import '../core/models/unlock_config.dart';
import '../core/providers/streak_provider.dart';
import '../core/providers/focus_lock_provider.dart';

class LockOverlayScreen extends StatefulWidget {
  final String? blockedAppName;
  final String? blockedPackageName;
  final UnlockConfig unlockConfig;
  final String? currentPrayerName;
  final bool isDarkMode;
  final VoidCallback? onUnlock;
  final Future<bool> Function()? onUseSkip;
  final VoidCallback? onOpenInav;
  final Future<void> Function()? onHome;

  const LockOverlayScreen({
    super.key,
    this.blockedAppName,
    this.blockedPackageName,
    this.unlockConfig = const UnlockConfig(method: UnlockMethod.waitItOut),
    this.currentPrayerName,
    this.isDarkMode = true,
    this.onUnlock,
    this.onUseSkip,
    this.onOpenInav,
    this.onHome,
  });

  @override
  State<LockOverlayScreen> createState() => _LockOverlayScreenState();
}

class _LockOverlayScreenState extends State<LockOverlayScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  Timer? _countdownTimer;
  Timer? _lockWindowTimer;
  int _remainingSeconds = 0;
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;

  final TextEditingController _phraseController = TextEditingController();
  bool _phraseError = false;
  int _phraseAttempts = 0;

  bool _prayerMarked = false;

  String _breathingPhase = 'Breathe In';
  int _breathingCycles = 0;
  final int _requiredCycles = 3;

  bool _isUnlocking = false;
  String _lockWindowRemainingStr = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _refreshLockWindowRemaining();
    _lockWindowTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) _refreshLockWindowRemaining();
    });

    if (widget.unlockConfig.method == UnlockMethod.waitItOut) {
      _remainingSeconds = widget.unlockConfig.waitDurationSeconds;
      _startCountdown();
    }

    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );

    _breathingAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.7,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 0.7,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_breathingController);

    if (widget.unlockConfig.method == UnlockMethod.mindfulPause) {
      _startBreathingCycle();
    }

    if (widget.unlockConfig.method == UnlockMethod.markPrayed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final streakProvider = context.read<StreakProvider>();
        _prayerMarked = streakProvider.isCurrentPrayerCompleted;

        if (_prayerMarked) {
          Future.delayed(const Duration(milliseconds: 500), _unlock);
        } else {
          _startPrayerCheckTimer();
        }
      });
    }
  }

  void _refreshLockWindowRemaining() {
    try {
      final flp = context.read<FocusLockProvider>();
      final val = flp.getRemainingLockWindowFormatted();
      if (mounted && val != _lockWindowRemainingStr) {
        setState(() => _lockWindowRemainingStr = val);
      }
    } catch (_) {}
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      debugPrint('LockOverlay: Lifecycle $state — user pressed home/switch. Going home + suppress reblock');
      _goHome();
    } else if (state == AppLifecycleState.inactive) {
      debugPrint('LockOverlay: Lifecycle inactive — app going background');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _countdownTimer?.cancel();
    _lockWindowTimer?.cancel();
    _breathingController.dispose();
    _phraseController.dispose();
    super.dispose();
  }

  void _startBreathingCycle() {
    _breathingController.repeat();

    Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (_breathingPhase == 'Breathe In') {
          _breathingPhase = 'Breathe Out';
        } else {
          _breathingPhase = 'Breathe In';
          _breathingCycles++;
        }
      });

      if (_breathingCycles >= _requiredCycles) {
        timer.cancel();
      }
    });
  }

  void _startPrayerCheckTimer() {
    Timer.periodic(const Duration(seconds: 2), (timer) {
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

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        timer.cancel();
        _unlock();
      }
    });
  }

  Future<void> _unlock() async {
    if (_isUnlocking || !mounted) return;
    _isUnlocking = true;
    widget.onUnlock?.call();
  }

  Future<void> _tryUseSkip() async {
    if (widget.onUseSkip == null) return;
    final ok = await widget.onUseSkip!();
    if (ok && mounted) {
      _unlock();
    }
  }

  Future<void> _tryOpenInav() async {
    widget.onOpenInav?.call();
  }

  Future<void> _goHome() async {
    if (_isUnlocking) return;
    if (widget.onHome != null) {
      await widget.onHome!();
    }
  }

  void _validatePhrase() {
    final input = _phraseController.text.trim();
    final target = widget.unlockConfig.unlockPhrase.trim();

    if (input.toLowerCase() == target.toLowerCase()) {
      _unlock();
    } else {
      setState(() {
        _phraseError = true;
        _phraseAttempts++;
      });

      HapticFeedback.vibrate();

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _phraseError = false);
        }
      });
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final dark = widget.isDarkMode;

    final bgColor = dark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final cardColor = dark ? AppColors.cardDark : AppColors.cardLight;
    final textMain = dark ? AppColors.textMainDark : AppColors.textMainLight;
    final textMuted = dark ? AppColors.textMutedDark : AppColors.textMutedLight;
    final hairline = dark ? AppColors.hairlineDark : AppColors.hairlineLight;
    final primary = dark ? AppColors.primaryDark : AppColors.primary;
    final rose = AppColors.roseAccent;

    final themeData = ThemeData(
      useMaterial3: true,
      brightness: dark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: bgColor,
      colorSchemeSeed: primary,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeData,
      home: AnnotatedRegion<SystemUiOverlayStyle>(
        value: dark
            ? SystemUiOverlayStyle.light.copyWith(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: bgColor,
                systemNavigationBarIconBrightness: Brightness.light,
              )
            : SystemUiOverlayStyle.dark.copyWith(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: bgColor,
                systemNavigationBarIconBrightness: Brightness.dark,
              ),
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (bool didPop, _) async {
            if (didPop) return;
            await _goHome();
          },
          child: Scaffold(
            backgroundColor: bgColor,
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: dark
                      ? [AppColors.surfaceDark, AppColors.cardDark]
                      : [AppColors.surfaceLight, AppColors.cardLight],
                ),
              ),
              child: SafeArea(
                bottom: true,
                top: true,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                _buildChipButton(
                                  onTap: _goHome,
                                  bgColor:
                                      textMuted.withValues(alpha: 0.08),
                                  icon: Icons.home_rounded,
                                  label: 'Home',
                                  color: textMuted,
                                ),
                                const SizedBox(width: 8),
                                _buildChipButton(
                                  onTap: _tryOpenInav,
                                  bgColor: primary.withValues(alpha: 0.08),
                                  icon: Icons.open_in_new_rounded,
                                  label: 'Open INav',
                                  color: primary,
                                ),
                              ],
                            ),
                            Consumer<FocusLockProvider>(
                              builder: (context, flp, _) {
                                final canSkip = flp.canSkip;
                                final remaining = flp.remainingSkips;
                                return _buildChipButton(
                                  onTap: canSkip ? _tryUseSkip : null,
                                  bgColor: (canSkip ? rose : textMuted)
                                      .withValues(alpha: 0.08),
                                  icon: canSkip
                                      ? Icons.flash_on_rounded
                                      : Icons.flash_off_rounded,
                                  label: canSkip
                                      ? 'Skip ($remaining)'
                                      : 'No skips',
                                  color: canSkip ? rose : textMuted,
                                  disabled: !canSkip,
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        if (_lockWindowRemainingStr.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: primary.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.schedule_rounded,
                                  size: 14,
                                  color: primary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Focus ends in $_lockWindowRemainingStr',
                                  style: GoogleFonts.plusJakartaSans().copyWith(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 10),
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: rose.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.lock_rounded,
                            size: 34,
                            color: rose,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'App Locked',
                          style: GoogleFonts.plusJakartaSans().copyWith(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: textMain,
                          ),
                        ),
                        const SizedBox(height: 6),
                        if (widget.blockedAppName != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: rose.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              widget.blockedAppName!,
                              style: GoogleFonts.plusJakartaSans().copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: rose,
                              ),
                            ),
                          ),
                        const SizedBox(height: 12),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Text(
                            'This app is locked during focus time.\nTap Home to exit or choose an unlock method.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans().copyWith(
                              fontSize: 13,
                              color: textMuted,
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildUnlockMethodUI(
                          dark: dark,
                          cardColor: cardColor,
                          textMain: textMain,
                          textMuted: textMuted,
                          hairline: hairline,
                          primary: primary,
                          rose: rose,
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: hairline.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.format_quote,
                                color: primary,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Prayer is better than sleep',
                                  style: GoogleFonts.plusJakartaSans().copyWith(
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                    color: textMuted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChipButton({
    required VoidCallback? onTap,
    required Color bgColor,
    required IconData icon,
    required String label,
    required Color color,
    bool disabled = false,
  }) {
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans().copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnlockMethodUI({
    required bool dark,
    required Color cardColor,
    required Color textMain,
    required Color textMuted,
    required Color hairline,
    required Color primary,
    required Color rose,
  }) {
    switch (widget.unlockConfig.method) {
      case UnlockMethod.waitItOut:
        return _buildWaitItOutUI(
          cardColor: cardColor,
          textMuted: textMuted,
          primary: primary,
          hairline: hairline,
        );
      case UnlockMethod.markPrayed:
        return _buildMarkPrayedUI(
          textMain: textMain,
          textMuted: textMuted,
          primary: primary,
        );
      case UnlockMethod.mindfulPause:
        return _buildMindfulPauseUI(
          cardColor: cardColor,
          textMain: textMain,
          textMuted: textMuted,
          primary: primary,
        );
      case UnlockMethod.typePhrase:
        return _buildTypePhraseUI(
          cardColor: cardColor,
          textMain: textMain,
          textMuted: textMuted,
          hairline: hairline,
          primary: primary,
        );
    }
  }

  Widget _buildWaitItOutUI({
    required Color cardColor,
    required Color textMuted,
    required Color primary,
    required Color hairline,
  }) {
    return Column(
      children: [
        Text(
          'TIME REMAINING',
          style: GoogleFonts.plusJakartaSans().copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: textMuted,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: primary.withValues(alpha: 0.35),
              width: 2,
            ),
          ),
          child: Text(
            _formatTime(_remainingSeconds),
            style: GoogleFonts.plusJakartaSans().copyWith(
              fontSize: 44,
              fontWeight: FontWeight.w800,
              color: primary,
              fontFeatures: [const FontFeature.tabularFigures()],
            ),
          ),
        ),
        const SizedBox(height: 18),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: _remainingSeconds /
                widget.unlockConfig.waitDurationSeconds
                    .clamp(1, 1 << 30),
            backgroundColor: hairline,
            valueColor: AlwaysStoppedAnimation<Color>(primary),
            minHeight: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildMarkPrayedUI({
    required Color textMain,
    required Color textMuted,
    required Color primary,
  }) {
    return Consumer<StreakProvider>(
      builder: (context, streakProvider, child) {
        final isPrayerCompleted =
            _prayerMarked || streakProvider.isCurrentPrayerCompleted;

        return Column(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                isPrayerCompleted ? Icons.check_circle : Icons.mosque,
                key: ValueKey(isPrayerCompleted),
                size: 60,
                color: isPrayerCompleted ? Colors.green : primary,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              isPrayerCompleted ? 'Prayer Completed!' : 'Mark Prayer as Prayed',
              style: GoogleFonts.plusJakartaSans().copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: textMain,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isPrayerCompleted
                  ? 'Unlocking app...'
                  : widget.currentPrayerName != null
                  ? 'Mark ${widget.currentPrayerName} prayer as completed\nin INav to unlock'
                  : 'Mark your current prayer as completed\nin INav to unlock',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans().copyWith(
                fontSize: 12,
                color: textMuted,
                height: 1.5,
              ),
            ),
            if (isPrayerCompleted) ...[
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

  Widget _buildMindfulPauseUI({
    required Color cardColor,
    required Color textMain,
    required Color textMuted,
    required Color primary,
  }) {
    final canContinue = _breathingCycles >= _requiredCycles;

    return Column(
      children: [
        AnimatedBuilder(
          animation: _breathingAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _breathingAnimation.value,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      primary.withValues(alpha: 0.4),
                      primary.withValues(alpha: 0.08),
                    ],
                  ),
                  border: Border.all(color: primary, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withValues(alpha: 0.25),
                      blurRadius: 16,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.air,
                    size: 48,
                    color: primary,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 26),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            _breathingPhase,
            key: ValueKey(_breathingPhase),
            style: GoogleFonts.plusJakartaSans().copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: primary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Breathing cycles: $_breathingCycles / $_requiredCycles',
          style: GoogleFonts.plusJakartaSans().copyWith(
            fontSize: 13,
            color: textMuted,
          ),
        ),
        const SizedBox(height: 20),
        AnimatedOpacity(
          opacity: canContinue ? 1.0 : 0.5,
          duration: const Duration(milliseconds: 300),
          child: ElevatedButton(
            onPressed: canContinue ? _unlock : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: canContinue ? 4 : 0,
            ),
            child: Text(
              canContinue ? 'Continue' : 'Complete breathing cycles',
              style: GoogleFonts.plusJakartaSans().copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypePhraseUI({
    required Color cardColor,
    required Color textMain,
    required Color textMuted,
    required Color hairline,
    required Color primary,
  }) {
    return Column(
      children: [
        Text(
          'TYPE TO CONTINUE',
          style: GoogleFonts.plusJakartaSans().copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: textMuted,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _phraseError ? Colors.red : hairline,
              width: 2,
            ),
          ),
          child: Text(
            '"${widget.unlockConfig.unlockPhrase}"',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans().copyWith(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 18),
        TextField(
          controller: _phraseController,
          autofocus: true,
          style: GoogleFonts.plusJakartaSans().copyWith(
            color: textMain,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: 'Type the phrase...',
            hintStyle: TextStyle(color: textMuted),
            filled: true,
            fillColor: cardColor,
            errorText: _phraseError ? 'Incorrect phrase. Try again.' : null,
            errorStyle: GoogleFonts.plusJakartaSans().copyWith(
              color: Colors.red,
              fontSize: 11,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: hairline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: hairline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
          ),
          onSubmitted: (_) => _validatePhrase(),
        ),
        if (_phraseAttempts > 0) ...[
          const SizedBox(height: 6),
          Text(
            'Attempts: $_phraseAttempts',
            style: GoogleFonts.plusJakartaSans().copyWith(
              fontSize: 11,
              color: textMuted,
            ),
          ),
        ],
        const SizedBox(height: 14),
        ElevatedButton(
          onPressed: _validatePhrase,
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            padding:
                const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Unlock',
            style: GoogleFonts.plusJakartaSans().copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
