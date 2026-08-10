import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../core/providers/prayer_provider.dart';
import '../../core/theme/app_colors.dart';
import '../common/pill_badge.dart';

class GlassBanner extends StatefulWidget {
  const GlassBanner({super.key});

  @override
  State<GlassBanner> createState() => _GlassBannerState();
}

class _GlassBannerState extends State<GlassBanner> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final prayerProvider = context.watch<PrayerProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 240,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            borderRadius: BorderRadius.circular(24),
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
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: PageView(
                  controller: _pageController,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: _buildCard(
                        context,
                        isDark,
                        child: _buildPrayerSlide(context, prayerProvider, isDark),
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: _buildCard(
                        context,
                        isDark,
                        child: _buildQuranSlide(context, isDark),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 12,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.surfaceDark.withValues(alpha: 0.2)
                          : AppColors.surfaceLight.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: isDark
                            ? AppColors.hairlineDark
                            : AppColors.hairlineLight,
                        width: 1,
                      ),
                    ),
                    child: SmoothPageIndicator(
                      controller: _pageController,
                      count: 2,
                      effect: ExpandingDotsEffect(
                        activeDotColor: isDark
                            ? AppColors.primaryDark
                            : AppColors.primary,
                        dotColor: isDark
                            ? AppColors.hairlineDark
                            : AppColors.hairlineLight,
                        dotHeight: 6,
                        dotWidth: 8,
                        expansionFactor: 2.8,
                        spacing: 6,
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

  Widget _buildCard(
    BuildContext context,
    bool isDark, {
    required Widget child,
  }) {
    return Stack(
      children: [
        Positioned(
          right: -20,
          bottom: -24,
          child: Icon(
            Icons.mosque,
            size: 110,
            color: isDark
                ? Colors.white.withValues(alpha: 0.04)
                : AppColors.primary.withValues(alpha: 0.06),
          ),
        ),
        Padding(padding: const EdgeInsets.all(24), child: child),
      ],
    );
  }

  Widget _buildPrayerSlide(
    BuildContext context,
    PrayerProvider provider,
    bool isDark,
  ) {
    final fraunces = GoogleFonts.fraunces();
    final plusJakarta = GoogleFonts.plusJakartaSans();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PillBadge(
                    label: 'CURRENT PRAYER',
                    icon: Icons.auto_awesome,
                    showPulsingDot: true,
                    textColor: isDark ? AppColors.primaryDark : AppColors.primary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${provider.currentPrayer} Prayer',
                    style: fraunces.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
                      height: 1.2,
                      letterSpacing: -0.02,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (provider.qiblaData != null)
                    Row(
                      children: [
                        Icon(
                          Icons.explore,
                          size: 12,
                          color: isDark ? AppColors.primaryDark : AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'Qibla: ${provider.qiblaData!.direction.toStringAsFixed(0)}° ${provider.qiblaData!.cardinalDirection} (Mecca) • ${provider.qiblaData!.formattedDistance}',
                            style: plusJakarta.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? AppColors.textMutedDark
                                  : AppColors.textMutedLight,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: isDark ? 0.18 : 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.hairlineDark : AppColors.hairlineLight,
                  width: 1,
                ),
              ),
              child: Icon(
                provider.getPrayerIcon(provider.currentPrayer),
                size: 32,
                color: isDark ? AppColors.primaryDark : AppColors.primary,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 1,
                width: double.infinity,
                color: isDark ? AppColors.hairlineDark : AppColors.hairlineLight,
              ),
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TIME REMAINING',
                    style: plusJakarta.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.textMutedDark
                          : AppColors.textMutedLight,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        provider.getFormattedCountdown(),
                        style: fraunces.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.textMainDark
                              : AppColors.textMainLight,
                          fontFeatures: const [FontFeature.tabularFigures()],
                          height: 1,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'left',
                        style: plusJakarta.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.primaryDark : AppColors.primary,
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
    );
  }

  Widget _buildQuranSlide(BuildContext context, bool isDark) {
    final plusJakarta = GoogleFonts.plusJakartaSans();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PillBadge(
          label: 'QURAN REFLECTION',
          icon: Icons.menu_book,
          textColor: isDark ? AppColors.primaryDark : AppColors.primary,
        ),
        const SizedBox(height: 12),
        Text(
          'إِنَّ مَعَ الْعُسْرِ يُسْرًا',
          textAlign: TextAlign.right,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            height: 1.6,
            fontFamily: 'serif',
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '"Indeed, with hardship comes ease."',
          style: plusJakarta.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppColors.textMainDark.withValues(alpha: 0.88)
                : AppColors.textMainLight.withValues(alpha: 0.88),
            fontStyle: FontStyle.italic,
          ),
        ),
        const Spacer(),
        Text(
          'Surah Ash-Sharh 94:6',
          style: plusJakarta.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
          ),
        ),
      ],
    );
  }
}
