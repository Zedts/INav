import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:glass/glass.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../core/providers/prayer_provider.dart';
import '../common/glass_pill_badge.dart';

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
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    // Blue glow (top-left)
                    BoxShadow(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                      blurRadius: 60,
                      spreadRadius: -10,
                      offset: const Offset(-20, -20),
                    ),
                    // Teal glow (bottom-right)
                    BoxShadow(
                      color: const Color(0xFF0D9488).withValues(alpha: 0.25),
                      blurRadius: 70,
                      spreadRadius: -10,
                      offset: const Offset(20, 20),
                    ),
                    // Amber glow (center)
                    BoxShadow(
                      color: const Color(0xFFD97706).withValues(alpha: 0.2),
                      blurRadius: 50,
                      spreadRadius: -15,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
              ),
            ),

            // Glass card PageView - fills entire space
            Positioned.fill(
              child: PageView(
                controller: _pageController,
                children: [
                  _buildGlassCard(
                    context,
                    isDark,
                    child: _buildPrayerSlide(context, prayerProvider, isDark),
                  ),
                  _buildGlassCard(
                    context,
                    isDark,
                    child: _buildQuranSlide(context, isDark),
                  ),
                ],
              ),
            ),

            // Dot indicators at bottom
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
                        ? Colors.black.withValues(alpha: 0.2)
                        : Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.white.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: SmoothPageIndicator(
                    controller: _pageController,
                    count: 2,
                    effect: ExpandingDotsEffect(
                      activeDotColor: isDark
                          ? const Color(0xFF60A5FA)
                          : const Color(0xFF0D47A1),
                      dotColor: isDark
                          ? const Color(0xFF475569).withValues(alpha: 0.5)
                          : const Color(0xFF94A3B8).withValues(alpha: 0.5),
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
    );
  }

  Widget _buildGlassCard(
    BuildContext context,
    bool isDark, {
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF0F172A).withValues(alpha: 0.55),
                  const Color(0xFF0F172A).withValues(alpha: 0.25),
                ]
              : [
                  Colors.white.withValues(alpha: 0.35),
                  Colors.white.withValues(alpha: 0.12),
                ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          // Main outer shadow
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.65)
                : const Color(0xFF0D47A1).withValues(alpha: 0.22),
            blurRadius: 50,
            offset: isDark ? const Offset(0, 25) : const Offset(0, 20),
          ),
          // Inset top highlight
          BoxShadow(
            color: isDark
                ? Colors.white.withValues(alpha: 0.35)
                : Colors.white.withValues(alpha: 0.8),
            blurRadius: isDark ? 1 : 2,
            offset: const Offset(0, 1),
            spreadRadius: -1,
          ),
          // Inset bottom shadow (dark mode only)
          if (isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 2,
              offset: const Offset(0, -1),
              spreadRadius: -1,
            ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.18)
                : Colors.white.withValues(alpha: 0.45),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Stack(
          children: [
            // Diagonal specular reflection (glass sheen)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: const Alignment(-1.0, -1.0),
                    end: const Alignment(0.6, 0.6),
                    colors: isDark
                        ? [
                            Colors.white.withValues(alpha: 0.04),
                            Colors.white.withValues(alpha: 0.01),
                            Colors.transparent,
                          ]
                        : [
                            Colors.white.withValues(alpha: 0.45),
                            Colors.white.withValues(alpha: 0.1),
                            Colors.transparent,
                          ],
                    stops: const [0.0, 0.35, 0.6],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),

            // Mosque watermark icon
            Positioned(
              right: -20,
              bottom: -24,
              child: Icon(
                Icons.mosque,
                size: 110,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : const Color(0xFF0D47A1).withValues(alpha: 0.1),
              ),
            ),

            // Content with proper padding
            Padding(padding: const EdgeInsets.all(24), child: child),
          ],
        ),
      ),
    ).asGlass(
      blurX: isDark ? 32 : 28,
      blurY: isDark ? 32 : 28,
      tintColor: Colors.transparent,
      frosted: true,
      clipBorderRadius: BorderRadius.circular(24),
    );
  }

  /// Slide 1: Active Prayer & Live Countdown
  Widget _buildPrayerSlide(
    BuildContext context,
    PrayerProvider provider,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left side: Badge and prayer info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GlassPillBadge(
                    label: 'CURRENT PRAYER',
                    icon: Icons.auto_awesome,
                    showPulsingDot: true,
                    textColor: isDark
                        ? const Color(0xFF93C5FD)
                        : const Color(0xFF1E3A8A),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${provider.currentPrayer} Prayer',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (provider.qiblaData != null)
                    Row(
                      children: [
                        Icon(
                          Icons.explore,
                          size: 12,
                          color: isDark
                              ? const Color(0xFF60A5FA)
                              : const Color(0xFF0D47A1),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'Qibla: ${provider.qiblaData!.direction.toStringAsFixed(0)}° ${provider.qiblaData!.cardinalDirection} (Mecca)',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? const Color(0xFFCBD5E1)
                                  : const Color(0xFF334155),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            // Right side: Prayer icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.15)
                      : Colors.white.withValues(alpha: 0.5),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                provider.getPrayerIcon(provider.currentPrayer),
                size: 32,
                color: isDark
                    ? const Color(0xFF60A5FA)
                    : const Color(0xFF0D47A1),
              ),
            ).asGlass(
              blurX: 16,
              blurY: 16,
              tintColor: Colors.transparent,
              frosted: true,
              clipBorderRadius: BorderRadius.circular(16),
            ),
          ],
        ),

        // Countdown section - simplified without extra Container border
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top border line
              Container(
                height: 1,
                width: double.infinity,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.2),
              ),
              const SizedBox(height: 12),
              // Time remaining section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TIME REMAINING',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF475569),
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
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF0F172A),
                          fontFeatures: const [FontFeature.tabularFigures()],
                          height: 1,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'left',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? const Color(0xFF60A5FA)
                              : const Color(0xFF0D47A1),
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

  /// Slide 2: Daily Verse Insight
  Widget _buildQuranSlide(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassPillBadge(
          label: 'QURAN REFLECTION',
          icon: Icons.menu_book,
          textColor: isDark
              ? const Color(0xFF5EEAD4) // teal-300
              : const Color(0xFF134E4A), // teal-900
        ),
        const SizedBox(height: 12),

        // Arabic text
        Text(
          'إِنَّ مَعَ الْعُسْرِ يُسْرًا',
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
            height: 1.6,
            fontFamily: 'serif',
          ),
        ),

        const SizedBox(height: 12),

        // Translation
        Text(
          '"Indeed, with hardship comes ease."',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
            fontStyle: FontStyle.italic,
          ),
        ),

        const Spacer(),

        // Surah reference
        Text(
          'Surah Ash-Sharh 94:6',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }
}
