import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/prayer_provider.dart';
import '../../core/providers/verse_provider.dart';
import '../../core/providers/hadith_provider.dart';
import '../../core/providers/streak_provider.dart';
import '../../core/providers/prayer_settings_provider.dart';
import '../../core/providers/focus_lock_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/common/error_state_view.dart';
import '../../widgets/common/section_skeleton.dart';
import '../../widgets/home/banner.dart';
import '../../widgets/home/focus_lock_card.dart';
import '../../widgets/home/horizontal_prayer_stepper.dart';
import '../../widgets/home/services_tools_grid.dart';
import '../../widgets/home/random_content_card.dart';
import '../../widgets/home/streak_card.dart';

/// Home screen - displays prayer times, countdown, and Qibla direction
class HomeScreen extends StatefulWidget {
  final Function(int) onNavigate;

  const HomeScreen({super.key, required this.onNavigate});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize prayer data and verse when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prayerProvider = context.read<PrayerProvider>();
      final verseProvider = context.read<VerseProvider>();
      final hadithProvider = context.read<HadithProvider>();
      final streakProvider = context.read<StreakProvider>();
      final settingsProvider = context.read<PrayerSettingsProvider>();
      final focusLockProvider = context.read<FocusLockProvider>();

      await settingsProvider.initialize();
      if (!mounted) return;
      await prayerProvider.initialize();
      if (!mounted) return;

      // Sync prayer times with Focus Lock
      if (prayerProvider.prayerTimes != null) {
        focusLockProvider.updatePrayerTimes(
          prayerProvider.prayerTimes!.getAllPrayerTimes(),
        );
      }

      await verseProvider.loadDailyVerse();
      if (!mounted) return;
      await hadithProvider.loadDailyHadith();
      if (!mounted) return;
      if (prayerProvider.prayerTimes != null) {
        await streakProvider.initialize(
          currentDate: DateTime.now(),
          currentPrayer: prayerProvider.currentPrayer,
          fajrTime: prayerProvider.prayerTimes!.fajr,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final prayerProvider = context.watch<PrayerProvider>();
    final verseProvider = context.watch<VerseProvider>();
    final hadithProvider = context.read<HadithProvider>();
    final streakProvider = context.watch<StreakProvider>();

    // Update streak provider when current prayer changes
    if (prayerProvider.prayerTimes != null && streakProvider.isInitialized) {
      Future.microtask(() {
        streakProvider.updatePrayerWindow(prayerProvider.currentPrayer);
      });
    }

    return RefreshIndicator.adaptive(
      onRefresh: () async {
        await prayerProvider.refresh();
        if (!mounted) return;
        await verseProvider.refresh();
        if (!mounted) return;
        await hadithProvider.refresh();
        if (!mounted) return;
        if (prayerProvider.prayerTimes != null) {
          await streakProvider.initialize(
            currentDate: DateTime.now(),
            currentPrayer: prayerProvider.currentPrayer,
            fajrTime: prayerProvider.prayerTimes!.fajr,
          );
        }
      },
      edgeOffset: 4,
      color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
      backgroundColor: isDark ? AppColors.cardDark : Colors.white,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Loading or Error State
          if (prayerProvider.isLoading)
            const SliverToBoxAdapter(
              child: ScreenSkeleton(
                children: [
                  // Glass banner
                  SectionSkeleton(height: 240),
                  SizedBox(height: 16),
                  // Prayer stepper
                  SectionSkeleton(height: 100),
                  SizedBox(height: 24),
                  // Services & tools grid
                  SectionSkeleton(height: 150),
                  SizedBox(height: 24),
                  // Verse of the day card
                  SectionSkeleton(height: 180),
                  SizedBox(height: 14),
                  // Streak card
                  SectionSkeleton(height: 120),
                ],
              ),
            )
          else if (prayerProvider.errorMessage != null)
            SliverFillRemaining(
              child: ErrorStateView(
                message: prayerProvider.errorMessage!,
                onRetry: () => prayerProvider.refresh(),
              ),
            )
          else
            // Main Content
            SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 8),

                // Glass Banner with animated blobs and carousel
                const GlassBanner(),

                const SizedBox(height: 16),

                // Horizontal Prayer Stepper Timeline
                const HorizontalPrayerStepper(),

                const SizedBox(height: 24),

                // Services & Tools Grid
                ServicesToolsGrid(onNavigate: widget.onNavigate),

                const SizedBox(height: 24),

                // Focus Lock Card
                const FocusLockCard(),

                const SizedBox(height: 24),

                // Random Verse / Random Hadist swipeable card
                const RandomContentCard(),

                const SizedBox(height: 14),

                // Streak Card
                const StreakCard(),

                const SizedBox(height: 24),
              ]),
            ),
        ],
      ),
    );
  }
}
