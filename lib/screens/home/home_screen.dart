import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/prayer_provider.dart';
import '../../core/providers/verse_provider.dart';
import '../../core/providers/streak_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/common/section_skeleton.dart';
import '../../widgets/home/glass_banner.dart';
import '../../widgets/home/horizontal_prayer_stepper.dart';
import '../../widgets/home/services_tools_grid.dart';
import '../../widgets/home/verse_of_day_card.dart';
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
      final streakProvider = context.read<StreakProvider>();
      await prayerProvider.initialize();
      if (!mounted) return;
      await verseProvider.loadDailyVerse();
      if (!mounted) return;
      if (prayerProvider.prayerTimes != null) {
        await streakProvider.initialize(
              currentDate: DateTime.now(),
              currentPrayer: prayerProvider.currentPrayer,
            );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final prayerProvider = context.watch<PrayerProvider>();
    final verseProvider = context.watch<VerseProvider>();
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
        if (prayerProvider.prayerTimes != null) {
          await streakProvider.initialize(
                currentDate: DateTime.now(),
                currentPrayer: prayerProvider.currentPrayer,
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
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red.withValues(alpha: 0.7),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load prayer times',
                        style: TextStyle(
                          color: isDark
                              ? AppColors.textMainDark
                              : AppColors.textMainLight,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        prayerProvider.errorMessage!,
                        style: TextStyle(
                          color: isDark
                              ? AppColors.textMutedDark
                              : AppColors.textMutedLight,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => prayerProvider.refresh(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark
                              ? AppColors.primaryDark
                              : AppColors.primaryLight,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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

                // Verse of the Day Card
                const VerseOfTheDayCard(),

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
