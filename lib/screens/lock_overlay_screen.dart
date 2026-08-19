import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../core/theme/app_colors.dart';
import '../core/models/unlock_config.dart';
import '../core/providers/streak_provider.dart';

/// Full-screen lock overlay that blocks access to apps
class LockOverlayScreen extends StatefulWidget {
  final String? blockedAppName;
  final String? blockedPackageName;
  final UnlockConfig unlockConfig;
  final String? currentPrayerName;
  final VoidCallback? onUnlock;

  const LockOverlayScreen({
    super.key,
    this.blockedAppName,
    this.blockedPackageName,
    this.unlockConfig = const UnlockConfig(method: UnlockMethod.waitItOut),
    this.currentPrayerName,
    this.onUnlock,
  });

  @override
  State<LockOverlayScreen> createState() => _LockOverlayScreenState();
}

class _LockOverlayScreenState extends State<LockOverlayScreen>
    with SingleTickerProviderStateMixin {
  Timer? _countdownTimer;
  int _remainingSeconds = 0;
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;

  // Type phrase state
  final TextEditingController _phraseController = TextEditingController();
  bool _phraseError = false;
  int _phraseAttempts = 0;

  // Mark prayer state
  bool _prayerMarked = false;

  // Mindful pause state
  String _breathingPhase = 'Breathe In';
  int _breathingCycles = 0;
  final int _requiredCycles = 3;

  @override
  void initState() {
    super.initState();

    // Initialize countdown for waitItOut method
    if (widget.unlockConfig.method == UnlockMethod.waitItOut) {
      _remainingSeconds = widget.unlockConfig.waitDurationSeconds;
      _startCountdown();
    }

    // Initialize breathing animation for mindfulPause (4s inhale, 4s exhale)
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

    // Listen for prayer completion (markPrayed method)
    if (widget.unlockConfig.method == UnlockMethod.markPrayed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final streakProvider = context.read<StreakProvider>();
        _prayerMarked = streakProvider.isCurrentPrayerCompleted;

        if (_prayerMarked) {
          // Prayer already marked, unlock immediately
          Future.delayed(const Duration(milliseconds: 500), _unlock);
        } else {
          // ponytail: poll every 2s for prayer completion (no stream available in StreakProvider)
          _startPrayerCheckTimer();
        }
      });
    }
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

  void _unlock() {
    widget.onUnlock?.call();
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

      // Reset error after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _phraseError = false);
        }
      });
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _breathingController.dispose();
    _phraseController.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Scaffold(
        backgroundColor: AppColors.surfaceDark,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.surfaceDark, AppColors.cardDark],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Lock icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.roseAccent.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lock_rounded,
                        size: 40,
                        color: AppColors.roseAccent,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Title
                    Text(
                      'App Locked',
                      style: GoogleFonts.plusJakartaSans().copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textMainDark,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Blocked app name
                    if (widget.blockedAppName != null)
                      Text(
                        widget.blockedAppName!,
                        style: GoogleFonts.plusJakartaSans().copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.roseAccent,
                        ),
                      ),

                    const SizedBox(height: 16),

                    // Message
                    Text(
                      'This app is locked during focus time.\nStay focused on what matters.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans().copyWith(
                        fontSize: 14,
                        color: AppColors.textMutedDark,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Unlock method UI
                    _buildUnlockMethodUI(),

                    const Spacer(),

                    // Motivational quote
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cardDark,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.hairlineDark.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.format_quote,
                            color: AppColors.primaryDark,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Prayer is better than sleep',
                              style: GoogleFonts.plusJakartaSans().copyWith(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                color: AppColors.textMutedDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUnlockMethodUI() {
    switch (widget.unlockConfig.method) {
      case UnlockMethod.waitItOut:
        return _buildWaitItOutUI();
      case UnlockMethod.markPrayed:
        return _buildMarkPrayedUI();
      case UnlockMethod.mindfulPause:
        return _buildMindfulPauseUI();
      case UnlockMethod.typePhrase:
        return _buildTypePhraseUI();
    }
  }

  Widget _buildWaitItOutUI() {
    return Column(
      children: [
        Text(
          'TIME REMAINING',
          style: GoogleFonts.plusJakartaSans().copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textMutedDark,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primaryDark.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Text(
            _formatTime(_remainingSeconds),
            style: GoogleFonts.plusJakartaSans().copyWith(
              fontSize: 48,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryDark,
              fontFeatures: [const FontFeature.tabularFigures()],
            ),
          ),
        ),
        const SizedBox(height: 24),
        LinearProgressIndicator(
          value: _remainingSeconds / widget.unlockConfig.waitDurationSeconds,
          backgroundColor: AppColors.hairlineDark,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryDark),
          minHeight: 4,
          borderRadius: BorderRadius.circular(2),
        ),
      ],
    );
  }

  Widget _buildMarkPrayedUI() {
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
                size: 64,
                color: isPrayerCompleted ? Colors.green : AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isPrayerCompleted ? 'Prayer Completed!' : 'Mark Prayer as Prayed',
              style: GoogleFonts.plusJakartaSans().copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textMainDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isPrayerCompleted
                  ? 'Unlocking app...'
                  : widget.currentPrayerName != null
                  ? 'Mark ${widget.currentPrayerName} prayer as completed\nin the app to unlock'
                  : 'Mark your current prayer as completed\nin the app to unlock',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans().copyWith(
                fontSize: 13,
                color: AppColors.textMutedDark,
                height: 1.5,
              ),
            ),
            if (isPrayerCompleted) ...[
              const SizedBox(height: 16),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildMindfulPauseUI() {
    final canContinue = _breathingCycles >= _requiredCycles;

    return Column(
      children: [
        AnimatedBuilder(
          animation: _breathingAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _breathingAnimation.value,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primaryDark.withValues(alpha: 0.4),
                      AppColors.primaryDark.withValues(alpha: 0.1),
                    ],
                  ),
                  border: Border.all(color: AppColors.primaryDark, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryDark.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.air,
                    size: 56,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 32),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            _breathingPhase,
            key: ValueKey(_breathingPhase),
            style: GoogleFonts.plusJakartaSans().copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Breathing cycles: $_breathingCycles / $_requiredCycles',
          style: GoogleFonts.plusJakartaSans().copyWith(
            fontSize: 14,
            color: AppColors.textMutedDark,
          ),
        ),
        const SizedBox(height: 24),
        AnimatedOpacity(
          opacity: canContinue ? 1.0 : 0.5,
          duration: const Duration(milliseconds: 300),
          child: ElevatedButton(
            onPressed: canContinue ? _unlock : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: canContinue ? 4 : 0,
            ),
            child: Text(
              canContinue ? 'Continue' : 'Complete breathing cycles',
              style: GoogleFonts.plusJakartaSans().copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypePhraseUI() {
    return Column(
      children: [
        Text(
          'TYPE TO CONTINUE',
          style: GoogleFonts.plusJakartaSans().copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textMutedDark,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _phraseError ? Colors.red : AppColors.hairlineDark,
              width: 2,
            ),
          ),
          child: Text(
            '"${widget.unlockConfig.unlockPhrase}"',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans().copyWith(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: AppColors.primaryDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _phraseController,
          autofocus: true,
          style: GoogleFonts.plusJakartaSans().copyWith(
            color: AppColors.textMainDark,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: 'Type the phrase...',
            filled: true,
            fillColor: AppColors.cardDark,
            errorText: _phraseError ? 'Incorrect phrase. Try again.' : null,
            errorStyle: GoogleFonts.plusJakartaSans().copyWith(
              color: Colors.red,
              fontSize: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.hairlineDark),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.hairlineDark),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primaryDark, width: 2),
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
          const SizedBox(height: 8),
          Text(
            'Attempts: $_phraseAttempts',
            style: GoogleFonts.plusJakartaSans().copyWith(
              fontSize: 12,
              color: AppColors.textMutedDark,
            ),
          ),
        ],
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _validatePhrase,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryDark,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Unlock',
            style: GoogleFonts.plusJakartaSans().copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
