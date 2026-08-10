import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/errors/error_messages.dart';
import '../../core/models/surah_model.dart';
import '../../core/providers/quran_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../screens/quran/surah_reading_screen.dart';

class SurahDetailSheet extends StatefulWidget {
  final SurahModel surah;

  const SurahDetailSheet({super.key, required this.surah});

  static void show(BuildContext context, SurahModel surah) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => SurahDetailSheet(surah: surah),
    );
  }

  @override
  State<SurahDetailSheet> createState() => _SurahDetailSheetState();
}

class _SurahDetailSheetState extends State<SurahDetailSheet> {
  static const AudioSourceId _sourceId = AudioSourceId.sheet;

  Future<void> _toggleAudio() async {
    final quranProvider = context.read<QuranProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final url = widget.surah.audioUrl;
    if (url.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(ErrorMessages.audioUnavailableForSurah),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    try {
      await quranProvider.toggleAudio(
        source: _sourceId,
        sourceKey: widget.surah.number.toString(),
        url: url,
      );
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(ErrorMessages.audioPlaybackFailed),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);
    final maxHeight = mediaQuery.size.height * 0.92;
    final minHeight = mediaQuery.size.height * 0.5;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: maxHeight,
            minHeight: minHeight,
          ),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 3,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDragHandle(isDark),
                      _buildHeader(context, isDark),
                      _buildBadgesRow(isDark),
                      const SizedBox(height: 12),
                      _buildTranslationRow(isDark),
                      const SizedBox(height: 20),
                      _buildTafsirSection(isDark),
                    ],
                  ),
                ),
              ),
              _buildBottomActions(context, isDark),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDragHandle(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Center(
        child: Container(
          width: 48,
          height: 5,
          decoration: BoxDecoration(
            color: isDark ? AppColors.textMutedLight : AppColors.textMutedDark,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 16),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isDark
                  ? AppColors.textMainDark.withValues(alpha: 0.8)
                  : AppColors.hairlineLight.withValues(alpha: 0.8),
              width: 1,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(
                        alpha: isDark ? 0.2 : 0.1,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        '${widget.surah.number}',
                        style: GoogleFonts.plusJakartaSans().copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.surah.nameEn,
                          style: GoogleFonts.plusJakartaSans().copyWith(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? AppColors.textMainDark
                                : AppColors.textMainLight,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          widget.surah.nameId,
                          style: GoogleFonts.plusJakartaSans().copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.textMutedDark
                                : AppColors.textMutedLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        widget.surah.nameLong,
                        textAlign: TextAlign.right,
                        style: GoogleFonts.fraunces().copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.textMainDark
                              : AppColors.textMainLight,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadgesRow(bool isDark) {
    final isMeccan = widget.surah.isMeccan;
    final revelationBg = isMeccan
        ? const Color(0xFFD97706).withValues(alpha: 0.1)
        : AppColors.primary.withValues(alpha: 0.1);
    final revelationFg = isMeccan ? const Color(0xFFD97706) : AppColors.primary;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildBadge(
          icon: Icons.location_on,
          bg: revelationBg,
          fg: revelationFg,
          text: widget.surah.revelationEn,
          suffix: TextSpan(
            text:
                '  (${widget.surah.revelationId} · ${widget.surah.revelation})',
            style: GoogleFonts.plusJakartaSans().copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: revelationFg.withValues(alpha: 0.6),
            ),
          ),
        ),
        _buildBadge(
          icon: Icons.format_align_left,
          bg: AppColors.primary.withValues(alpha: 0.1),
          fg: AppColors.primary,
          text: '${widget.surah.numberOfVerses} Ayahs',
        ),
        _buildBadge(
          icon: Icons.sort,
          bg: AppColors.primary.withValues(alpha: 0.1),
          fg: AppColors.primary,
          text: 'Order ${widget.surah.sequence}',
        ),
      ],
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required Color bg,
    required Color fg,
    required String text,
    InlineSpan? suffix,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            WidgetSpan(
              child: Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Icon(icon, size: 13, color: fg),
              ),
              alignment: PlaceholderAlignment.middle,
            ),
            TextSpan(
              text: text,
              style: GoogleFonts.plusJakartaSans().copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: fg,
              ),
            ),
            ...suffix == null ? [] : [suffix],
          ],
        ),
      ),
    );
  }

  Widget _buildTranslationRow(bool isDark) {
    return Row(
      children: [
        Text(
          'Translation:',
          style: GoogleFonts.plusJakartaSans().copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          widget.surah.translationEn,
          style: GoogleFonts.plusJakartaSans().copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            '•',
            style: GoogleFonts.plusJakartaSans().copyWith(
              color: isDark ? AppColors.hairlineDark : AppColors.textMutedDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          widget.surah.translationId,
          style: GoogleFonts.plusJakartaSans().copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
          ),
        ),
      ],
    );
  }

  Widget _buildTafsirSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.menu_book, size: 13, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              'TAFSIR / DESCRIPTION',
              style: GoogleFonts.plusJakartaSans().copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: isDark
                    ? AppColors.textMutedDark
                    : AppColors.textMutedLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          widget.surah.tafsir,
          style: GoogleFonts.plusJakartaSans().copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: (isDark ? AppColors.textMainDark : AppColors.textMainLight)
                .withValues(alpha: 0.9),
            height: 1.65,
          ),
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildBottomActions(BuildContext context, bool isDark) {
    final quranProvider = context.watch<QuranProvider>();
    final surahKey = widget.surah.number.toString();
    final isBookmarked = quranProvider.isBookmarked(surahKey);
    final isPlaying = quranProvider.isSurahPlaying(surahKey);
    final isLoading = quranProvider.isSurahLoading(surahKey);
    final isActive = quranProvider.isSurahActive(surahKey);

    final audioIcon = isLoading
        ? Icons.hourglass_empty
        : (isPlaying ? Icons.volume_up : Icons.volume_down);

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        16 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark
                ? AppColors.textMainDark.withValues(alpha: 0.8)
                : AppColors.hairlineLight.withValues(alpha: 0.8),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Row(
            children: [
              _buildActionButton(
                icon: Icons.menu_book,
                bg: AppColors.primary,
                fg: Colors.white,
                hasShadow: true,
                shadowColor: AppColors.primary,
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          SurahReadingScreen(surahNumber: widget.surah.number),
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              _buildActionButton(
                icon: isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                bg: isBookmarked
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : (isDark
                          ? AppColors.hairlineDark
                          : AppColors.hairlineLight),
                fg: isBookmarked
                    ? AppColors.primary
                    : (isDark
                          ? AppColors.textMutedDark
                          : AppColors.textMutedLight),
                hasShadow: false,
                onTap: () {
                  quranProvider.toggleBookmark(surahKey);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isBookmarked
                            ? 'Removed from bookmarks'
                            : 'Added to bookmarks',
                      ),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              _buildActionButton(
                icon: audioIcon,
                bg: isPlaying || isActive
                    ? const Color(0xFF1D4ED8)
                    : AppColors.primary,
                fg: Colors.white,
                hasShadow: true,
                shadowColor: AppColors.primary,
                pulsing: isPlaying,
                onTap: _toggleAudio,
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'RECITATION',
                style: GoogleFonts.plusJakartaSans().copyWith(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  color:
                      (isDark
                              ? AppColors.textMainDark
                              : AppColors.textMainLight)
                          .withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Al-ʿAfāṣī atau Al-Afasy',
                style: GoogleFonts.plusJakartaSans().copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? AppColors.textMainDark
                      : AppColors.textMainLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color bg,
    required Color fg,
    required bool hasShadow,
    required VoidCallback onTap,
    Color? shadowColor,
    bool pulsing = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: hasShadow && shadowColor != null
              ? [
                  BoxShadow(
                    color: shadowColor.withValues(alpha: 0.2),
                    blurRadius: 3,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: AnimatedSize(
            duration: const Duration(milliseconds: 200),
            child: Icon(icon, size: pulsing ? 22 : 20, color: fg),
          ),
        ),
      ),
    );
  }
}
