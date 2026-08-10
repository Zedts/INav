import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../../core/providers/quran_provider.dart';
import '../../core/theme/app_colors.dart';

/// Quran Reading Screen (v3 API) - Full surah reading with Arabic + translation
/// ponytail: Uses scrollable_positioned_list for accurate ayah tracking (no height estimation)
/// Upgrade path: Add TextStyle theme with size multiplier (userFontSizeMultiplier)
class SurahReadingScreen extends StatefulWidget {
  final int surahNumber;
  final int? initialAyahNumber;

  const SurahReadingScreen({
    super.key,
    required this.surahNumber,
    this.initialAyahNumber,
  });

  @override
  State<SurahReadingScreen> createState() => _SurahReadingScreenState();
}

class _SurahReadingScreenState extends State<SurahReadingScreen> {
  // ponytail: scrollable_positioned_list handles scroll tracking automatically
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  bool _isDisposed = false;
  bool _isNearEnd = false;

  // ponytail: Font size ceiling - fixed values for now
  // Upgrade path: baseFontSize * userFontSizeMultiplier from settings
  static const double _arabicBaseFontSize = 24.0;
  static const double _translationBaseFontSize = 14.0;

  @override
  void initState() {
    super.initState();
    _loadSurahDetail();
    _itemPositionsListener.itemPositions.addListener(_onVisibleItemsChanged);
  }

  void _onVisibleItemsChanged() {
    if (_isDisposed) return;

    final provider = context.read<QuranProvider>();
    final detail = provider.currentSurahDetail;
    if (detail == null || detail.ayahs.isEmpty) return;

    final positions = _itemPositionsListener.itemPositions.value;
    if (positions.isEmpty) return;

    // ponytail: Get first visible item (topmost in viewport)
    // Upgrade path: Get center item or weighted average of visible items
    final firstVisible = positions
        .where((pos) => pos.itemTrailingEdge > 0)
        .reduce((a, b) => a.index < b.index ? a : b);

    final visibleAyahNumber = firstVisible.index + 1; // Convert to 1-indexed

    // Save last read position
    provider.setLastRead(widget.surahNumber, visibleAyahNumber);

    // Check if near end (last 15% of list)
    final totalItems = detail.ayahs.length;
    final lastVisibleIndex = positions.last.index;
    final wasNearEnd = _isNearEnd;
    _isNearEnd = (lastVisibleIndex / totalItems) >= 0.85;

    if (wasNearEnd != _isNearEnd && mounted) {
      setState(() {});
    }
  }

  Future<void> _loadSurahDetail() async {
    final provider = context.read<QuranProvider>();
    await provider.loadSurahDetail(widget.surahNumber);

    // Set last read on initial load (user opened the surah)
    final initialAyah = widget.initialAyahNumber ?? 1;
    provider.setLastRead(widget.surahNumber, initialAyah);

    // Scroll to initial ayah if specified
    if (widget.initialAyahNumber != null && mounted) {
      _scrollToAyah(widget.initialAyahNumber!);
    }
  }

  void _scrollToAyah(int ayahNumber) {
    // ponytail: scrollable_positioned_list handles positioning automatically
    // No manual offset calculation needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _isDisposed) return;

      if (_itemScrollController.isAttached) {
        _itemScrollController.scrollTo(
          index: ayahNumber - 1, // Convert to 0-indexed
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          alignment: 0.1, // Position item 10% from top of viewport
        );
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _itemPositionsListener.itemPositions.removeListener(_onVisibleItemsChanged);
    // ponytail: No need to dispose controllers - package handles it
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      appBar: _buildAppBar(context, isDark),
      body: _buildBody(context, isDark),
      bottomNavigationBar: _buildAudioControls(context, isDark),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDark) {
    return AppBar(
      backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      title: Consumer<QuranProvider>(
        builder: (context, provider, _) {
          final detail = provider.currentSurahDetail;
          if (detail == null) {
            return const Text('Loading...');
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                detail.nameLatin,
                style: GoogleFonts.plusJakartaSans().copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${detail.translation} • ${detail.revelationEn} • ${detail.numberOfAyahs} Ayahs',
                style: GoogleFonts.plusJakartaSans().copyWith(
                  fontSize: 11,
                  color: isDark
                      ? AppColors.textMutedDark
                      : AppColors.textMutedLight,
                ),
              ),
            ],
          );
        },
      ),
      actions: [
        // ponytail: Share button present but shows "Coming soon" snackbar
        // Upgrade path: Implement share functionality with ayah selection
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Share feature coming soon')),
            );
          },
        ),
        // ponytail: Settings button present but shows "Coming soon" snackbar
        // Upgrade path: Add settings for font size, translation toggle, etc.
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Settings coming soon')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, bool isDark) {
    return Consumer<QuranProvider>(
      builder: (context, provider, _) {
        // Loading state
        if (provider.isLoadingDetail) {
          return const Center(child: CircularProgressIndicator());
        }

        // Error state
        if (provider.errorMessageDetail != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: isDark
                      ? AppColors.textMutedDark
                      : AppColors.textMutedLight,
                ),
                const SizedBox(height: 16),
                Text(
                  provider.errorMessageDetail!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark
                        ? AppColors.textMutedDark
                        : AppColors.textMutedLight,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadSurahDetail,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        // Empty state (should not happen)
        final detail = provider.currentSurahDetail;
        if (detail == null || detail.ayahs.isEmpty) {
          return const Center(child: Text('No ayahs available'));
        }

        // Success state - show ayah list with scrollable_positioned_list
        return ScrollablePositionedList.builder(
          itemCount: detail.ayahs.length,
          itemBuilder: (context, index) {
            final ayah = detail.ayahs[index];
            return _buildAyahItem(context, isDark, ayah);
          },
          itemScrollController: _itemScrollController,
          itemPositionsListener: _itemPositionsListener,
          padding: const EdgeInsets.all(16),
        );
      },
    );
  }

  Widget _buildAyahItem(BuildContext context, bool isDark, ayah) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Ayah number badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.cardLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? AppColors.hairlineDark.withValues(alpha: 0.5)
                        : AppColors.hairlineLight.withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  ayah.ayahNumber.toString(),
                  style: GoogleFonts.plusJakartaSans().copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.teal,
                  ),
                ),
              ),
              const Spacer(),
              // ponytail: Tafsir icon - shows bottom sheet on tap
              // Upgrade path: Add full tafsir detail screen
              IconButton(
                icon: const Icon(Icons.info_outline, size: 20),
                onPressed: () => _showTafsirBottomSheet(context, isDark, ayah),
                color: isDark
                    ? AppColors.textMutedDark
                    : AppColors.textMutedLight,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Arabic text
          Text(
            ayah.arab,
            textAlign: TextAlign.right,
            style: GoogleFonts.fraunces().copyWith(
              fontSize: _arabicBaseFontSize,
              fontWeight: FontWeight.w600,
              height: 2.0,
              color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
            ),
          ),
          const SizedBox(height: 12),

          // Translation
          Text(
            ayah.translation,
            style: GoogleFonts.plusJakartaSans().copyWith(
              fontSize: _translationBaseFontSize,
              height: 1.6,
              color: isDark
                  ? AppColors.textMutedDark
                  : AppColors.textMutedLight,
            ),
          ),

          const SizedBox(height: 8),

          // Divider
          Divider(
            color: isDark
                ? AppColors.hairlineDark.withValues(alpha: 0.3)
                : AppColors.hairlineLight.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }

  void _showTafsirBottomSheet(BuildContext context, bool isDark, ayah) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.hairlineDark : AppColors.hairlineLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Tafsir - Ayah ${ayah.ayahNumber}',
                style: GoogleFonts.fraunces().copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            const Divider(height: 1),

            // Tafsir content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Kemenag Short
                  _buildTafsirSection(
                    'Kemenag (Short)',
                    ayah.tafsir.kemenag.short,
                    isDark,
                  ),
                  const SizedBox(height: 16),

                  // Quraish
                  _buildTafsirSection(
                    'Quraish Shihab',
                    ayah.tafsir.quraish,
                    isDark,
                  ),
                  const SizedBox(height: 16),

                  // Jalalayn
                  _buildTafsirSection('Jalalayn', ayah.tafsir.jalalayn, isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTafsirSection(String title, String content, bool isDark) {
    if (content.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans().copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: GoogleFonts.plusJakartaSans().copyWith(
            fontSize: 13,
            height: 1.6,
            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
          ),
        ),
      ],
    );
  }

  Widget? _buildAudioControls(BuildContext context, bool isDark) {
    return Consumer<QuranProvider>(
      builder: (context, provider, _) {
        final detail = provider.currentSurahDetail;

        // Only show audio controls if surah detail is loaded
        if (detail == null) return const SizedBox.shrink();

        final isPlaying = provider.isPlayingAudioFrom(
          AudioSourceId.banner,
          detail.number.toString(),
        );
        final isLoading = provider.isLoadingAudioFrom(
          AudioSourceId.banner,
          detail.number.toString(),
        );

        final canGoNext =
            detail.number < 114; // Can go to next surah if not at 114

        // ponytail: Simple audio controls - play/pause + next button
        // Upgrade path: Add per-ayah playback, loop mode, auto-advance settings
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            border: Border(
              top: BorderSide(
                color: isDark
                    ? AppColors.hairlineDark.withValues(alpha: 0.5)
                    : AppColors.hairlineLight.withValues(alpha: 0.5),
              ),
            ),
          ),
          child: Row(
            children: [
              // Play/Pause button
              IconButton(
                icon: Icon(
                  isLoading
                      ? Icons.hourglass_empty
                      : (isPlaying ? Icons.pause : Icons.play_arrow),
                  size: 32,
                ),
                onPressed: isLoading
                    ? null
                    : () async {
                        await provider.toggleAudio(
                          source: AudioSourceId.banner,
                          sourceKey: detail.number.toString(),
                          url: detail.audioUrl,
                        );
                      },
                color: AppColors.teal,
              ),
              const SizedBox(width: 12),

              // Surah info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      detail.nameLatin,
                      style: GoogleFonts.plusJakartaSans().copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      isPlaying
                          ? 'Now Playing'
                          : (isLoading ? 'Loading...' : 'Tap to play'),
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

              // Next button (enabled only when near end and can go next)
              IconButton(
                icon: Icon(
                  Icons.skip_next,
                  size: 32,
                  color: (_isNearEnd && canGoNext)
                      ? AppColors.teal
                      : (isDark
                            ? AppColors.textMutedDark.withValues(alpha: 0.3)
                            : AppColors.textMutedLight.withValues(alpha: 0.3)),
                ),
                onPressed: (_isNearEnd && canGoNext)
                    ? () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SurahReadingScreen(
                              surahNumber: detail.number + 1,
                            ),
                          ),
                        );
                      }
                    : null,
              ),
            ],
          ),
        );
      },
    );
  }
}
