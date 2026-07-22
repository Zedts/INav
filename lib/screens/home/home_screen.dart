import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/prayer_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/home/liquid_glass_banner.dart';
import '../../widgets/home/horizontal_prayer_stepper.dart';

/// Home screen - displays prayer times, countdown, and Qibla direction
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize prayer data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PrayerProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final prayerProvider = context.watch<PrayerProvider>();

    return RefreshIndicator(
      onRefresh: () => prayerProvider.refresh(),
      color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
      child: CustomScrollView(
        slivers: [
          // Loading or Error State
          if (prayerProvider.isLoading)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: isDark
                          ? AppColors.primaryDark
                          : AppColors.primaryLight,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading prayer times...',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textMutedDark
                            : AppColors.textMutedLight,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
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

                // Liquid Glass Banner with animated blobs and carousel
                const LiquidGlassBanner(),

                const SizedBox(height: 16),

                // Horizontal Prayer Stepper Timeline
                const HorizontalPrayerStepper(),

                const SizedBox(height: 24),
              ]),
            ),
        ],
      ),
    );
  }
}
