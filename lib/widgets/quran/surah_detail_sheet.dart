import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/errors/error_messages.dart';
import '../../core/models/surah_model.dart';
import '../../core/providers/quran_provider.dart';

class SurahDetailSheet extends StatefulWidget {
  final SurahModel surah;

  const SurahDetailSheet({
    super.key,
    required this.surah,
  });

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
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 40,
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
            color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
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
                  ? const Color(0xFF1E293B).withValues(alpha: 0.8)
                  : const Color(0xFFE2E8F0).withValues(alpha: 0.8),
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
                      color: const Color(0xFF0D9488).withValues(
                        alpha: isDark ? 0.2 : 0.1,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        '${widget.surah.number}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0D9488),
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
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? const Color(0xFFF8FAFC)
                                : const Color(0xFF0F172A),
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          widget.surah.nameId,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
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
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? const Color(0xFFF8FAFC)
                              : const Color(0xFF0F172A),
                          height: 1,
                          fontFamily: 'serif',
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
        : const Color(0xFF2563EB).withValues(alpha: 0.1);
    final revelationFg =
        isMeccan ? const Color(0xFFD97706) : const Color(0xFF2563EB);

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
            text: '  (${widget.surah.revelationId} · ${widget.surah.revelation})',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: revelationFg.withValues(alpha: 0.6),
              fontFamily: 'serif',
            ),
          ),
        ),
        _buildBadge(
          icon: Icons.format_align_left,
          bg: const Color(0xFF2563EB).withValues(alpha: 0.1),
          fg: isDark ? const Color(0xFF3B82F6) : const Color(0xFF2563EB),
          text: '${widget.surah.numberOfVerses} Ayahs',
        ),
        _buildBadge(
          icon: Icons.sort,
          bg: const Color(0xFF0D9488).withValues(alpha: 0.1),
          fg: const Color(0xFF0D9488),
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
              style: TextStyle(
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
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDark
                ? const Color(0xFF94A3B8)
                : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          widget.surah.translationEn,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isDark
                ? const Color(0xFFF8FAFC)
                : const Color(0xFF0F172A),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            '•',
            style: TextStyle(
              color: isDark
                  ? const Color(0xFF334155)
                  : const Color(0xFFCBD5E1),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          widget.surah.translationId,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isDark
                ? const Color(0xFFF8FAFC)
                : const Color(0xFF0F172A),
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
            const Icon(
              Icons.menu_book,
              size: 13,
              color: Color(0xFF0D9488),
            ),
            const SizedBox(width: 6),
            Text(
              'TAFSIR / DESCRIPTION',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          widget.surah.tafsir,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: (isDark
                    ? const Color(0xFFF8FAFC)
                    : const Color(0xFF0F172A))
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

    final audioIcon =
        isLoading
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
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark
                ? const Color(0xFF1E293B).withValues(alpha: 0.8)
                : const Color(0xFFE2E8F0).withValues(alpha: 0.8),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Row(
            children: [
              _buildActionButton(
                icon: Icons.play_arrow,
                bg: const Color(0xFF0D9488),
                fg: Colors.white,
                hasShadow: true,
                shadowColor: const Color(0xFF0D9488),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Opening full reading view...'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(width: 12),
              _buildActionButton(
                icon: isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                bg: isBookmarked
                    ? const Color(0xFF0D9488).withValues(alpha: 0.1)
                    : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                fg: isBookmarked
                    ? const Color(0xFF0D9488)
                    : (isDark
                        ? const Color(0xFFF8FAFC)
                        : const Color(0xFF0F172A)),
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
                    : const Color(0xFF2563EB),
                fg: Colors.white,
                hasShadow: true,
                shadowColor: const Color(0xFF2563EB),
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
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  color: (isDark
                          ? const Color(0xFFF8FAFC)
                          : const Color(0xFF0F172A))
                      .withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Al-ʿAfāṣī atau Al-Afasy',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? const Color(0xFFF8FAFC)
                      : const Color(0xFF0F172A),
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
                    color: shadowColor.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: AnimatedSize(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              icon,
              size: pulsing ? 22 : 20,
              color: fg,
            ),
          ),
        ),
      ),
    );
  }
}
