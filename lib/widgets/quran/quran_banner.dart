import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:glass/glass.dart';
import '../../core/providers/quran_provider.dart';
import '../../core/models/surah_model.dart';
import '../common/glass_pill_badge.dart';

class QuranBanner extends StatefulWidget {
  const QuranBanner({super.key});

  @override
  State<QuranBanner> createState() => _QuranBannerState();
}

class _QuranBannerState extends State<QuranBanner> {
  static const AudioSourceId _sourceId = AudioSourceId.banner;
  static const String _defaultSurahKey = '1';
  static const String _defaultAudioUrl =
      'https://download.quranicaudio.com/quran/mishaari_raashid_al_3afaasee/001.mp3';

  Future<void> _toggleAudio() async {
    final quranProvider = context.read<QuranProvider>();
    final playingSurah = quranProvider.currentPlayingSurah;
    final isContinuous = quranProvider.continuousPlaybackMode;
    try {
      if (playingSurah == null) {
        await quranProvider.startContinuousPlayback();
      } else if (isContinuous) {
        await quranProvider.toggleAudio(
          source: AudioSourceId.banner,
          sourceKey: playingSurah.number.toString(),
          url: quranProvider.currentAudioUrl!,
        );
      } else if (quranProvider.currentAudioUrl != null &&
          quranProvider.currentAudioSource != null &&
          quranProvider.currentAudioSourceKey != null) {
        await quranProvider.toggleAudio(
          source: quranProvider.currentAudioSource!,
          sourceKey: quranProvider.currentAudioSourceKey!,
          url: quranProvider.currentAudioUrl!,
        );
      } else {
        await quranProvider.toggleAudio(
          source: _sourceId,
          sourceKey: _defaultSurahKey,
          url: _defaultAudioUrl,
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to play audio. Please try again.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _exitActivePlayback() async {
    final quranProvider = context.read<QuranProvider>();
    try {
      await quranProvider.stopAndClearAudio();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Stopped playback'),
          duration: Duration(seconds: 1),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to stop. Please try again.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final quranProvider = context.watch<QuranProvider>();
    final playingSurah = quranProvider.currentPlayingSurah;
    final isContinuous = quranProvider.continuousPlaybackMode;
    final hasActiveSurah = playingSurah != null;

    final isPlaying = hasActiveSurah
        ? quranProvider.isSurahPlaying(playingSurah.number.toString())
        : quranProvider.isPlayingAudioFrom(_sourceId, _defaultSurahKey);
    final isLoading = hasActiveSurah
        ? quranProvider.isSurahLoading(playingSurah.number.toString())
        : quranProvider.isLoadingAudioFrom(_sourceId, _defaultSurahKey);
    final isActive = hasActiveSurah
        ? quranProvider.isSurahActive(playingSurah.number.toString())
        : (quranProvider.currentAudioSource == _sourceId &&
            quranProvider.currentAudioSourceKey == _defaultSurahKey);

    final speakerIcon =
        isLoading
            ? Icons.hourglass_empty
            : (isPlaying ? Icons.volume_up : Icons.volume_down);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () {
          if (hasActiveSurah) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isContinuous
                      ? 'Continuous: ${playingSurah.nameEn}'
                      : 'Now Playing: ${playingSurah.nameEn}',
                ),
                duration: const Duration(seconds: 1),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Pick a Surah below to start reading'),
                duration: Duration(seconds: 1),
              ),
            );
          }
        },
        child: SizedBox(
          height: 170,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color:
                            (hasActiveSurah
                                    ? (isContinuous
                                        ? const Color(0xFF7C3AED)
                                        : const Color(0xFF2563EB))
                                    : const Color(0xFF0D9488))
                                .withValues(alpha: 0.35),
                        blurRadius: 60,
                        spreadRadius: -10,
                        offset: const Offset(-20, -20),
                      ),
                      BoxShadow(
                        color:
                            (isContinuous
                                    ? const Color(0xFF7C3AED)
                                    : const Color(0xFF2563EB))
                                .withValues(alpha: 0.2),
                        blurRadius: 70,
                        spreadRadius: -10,
                        offset: const Offset(20, 20),
                      ),
                      BoxShadow(
                        color:
                            const Color(0xFFD97706).withValues(alpha: 0.2),
                        blurRadius: 50,
                        spreadRadius: -15,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
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
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.65)
                          : const Color(0xFF0D47A1).withValues(alpha: 0.22),
                      blurRadius: 50,
                      offset:
                          isDark ? const Offset(0, 25) : const Offset(0, 20),
                    ),
                    BoxShadow(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.35)
                          : Colors.white.withValues(alpha: 0.8),
                      blurRadius: isDark ? 1 : 2,
                      offset: const Offset(0, 1),
                      spreadRadius: -1,
                    ),
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
                      Positioned(
                        right: -16,
                        bottom: -24,
                        child: Icon(
                          isContinuous
                              ? Icons.queue_play_next
                              : hasActiveSurah
                                  ? Icons.queue_music
                                  : Icons.menu_book,
                          size: 110,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : const Color(0xFF0D47A1).withValues(alpha: 0.1),
                        ),
                      ),
                      if (hasActiveSurah)
                        Positioned(
                          top: 12,
                          right: 12,
                          child: _buildExitButton(isDark),
                        ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          20,
                          20,
                          hasActiveSurah ? 60 : 20,
                          20,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            hasActiveSurah
                                ? isContinuous
                                    ? _buildContinuousBadge(isDark)
                                    : _buildNowPlayingBadge(isDark)
                                : GlassPillBadge(
                                    label: 'START READING',
                                    icon: Icons.menu_book,
                                    showPulsingDot: false,
                                    textColor: isDark
                                        ? const Color(0xFF5EEAD4)
                                        : const Color(0xFF134E4A),
                                  ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: hasActiveSurah
                                  ? _buildNowPlayingContent(
                                      context,
                                      isDark,
                                      playingSurah,
                                      speakerIcon,
                                      isPlaying,
                                      isLoading,
                                      isActive,
                                      isContinuous,
                                    )
                                  : _buildDefaultContent(
                                      context,
                                      isDark,
                                      speakerIcon,
                                      isPlaying,
                                      isLoading,
                                      isActive,
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ).asGlass(
                blurX: isDark ? 32 : 28,
                blurY: isDark ? 32 : 28,
                tintColor: Colors.transparent,
                frosted: true,
                clipBorderRadius: BorderRadius.circular(24),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExitButton(bool isDark) {
    return GestureDetector(
      onTap: _exitActivePlayback,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFFEF4444).withValues(alpha: 0.22)
              : const Color(0xFFEF4444).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFEF4444).withValues(alpha: 0.45),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFEF4444).withValues(alpha: 0.18),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.close,
          size: 20,
          color: const Color(0xFFEF4444),
        ),
      ),
    );
  }

  Widget _buildContinuousBadge(bool isDark) {
    return GlassPillBadge(
      label: 'CONTINUOUS PLAY',
      icon: Icons.all_inclusive,
      showPulsingDot: true,
      textColor: isDark ? const Color(0xFFC4B5FD) : const Color(0xFF5B21B6),
      pulsingDotColor: const Color(0xFF7C3AED),
    );
  }

  Widget _buildNowPlayingBadge(bool isDark) {
    return GlassPillBadge(
      label: 'NOW PLAYING',
      icon: Icons.volume_up,
      showPulsingDot: true,
      textColor: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
    );
  }

  Widget _buildDefaultContent(
    BuildContext context,
    bool isDark,
    IconData speakerIcon,
    bool isPlaying,
    bool isLoading,
    bool isActive,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Start Reading',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
            height: 1.2,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose a Surah below',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? const Color(0xFFCBD5E1)
                        : const Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'or tap play → all 114 Surahs',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                _buildAudioButton(
                  speakerIcon,
                  isPlaying,
                  isLoading,
                  isActive,
                  isDark,
                ),
                const SizedBox(width: 8),
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF0D9488).withValues(alpha: 0.2)
                        : const Color(0xFF0D9488).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    size: 18,
                    color: Color(0xFF0D9488),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNowPlayingContent(
    BuildContext context,
    bool isDark,
    SurahModel surah,
    IconData speakerIcon,
    bool isPlaying,
    bool isLoading,
    bool isActive,
    bool isContinuous,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color:
                    (isContinuous ? const Color(0xFF7C3AED) : const Color(0xFF2563EB))
                        .withValues(alpha: isDark ? 0.25 : 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '${surah.number}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: isContinuous
                        ? const Color(0xFF7C3AED)
                        : const Color(0xFF2563EB),
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
                    surah.nameEn,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      height: 1.1,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${surah.translationEn} · ${surah.translationId}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              surah.nameShort,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                height: 1,
                fontFamily: 'serif',
              ),
            ),
          ],
        ),
        const Spacer(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${surah.numberOfVerses} Ayahs · ${surah.revelationEn}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? const Color(0xFFCBD5E1)
                        : const Color(0xFF334155),
                  ),
                ),
                if (isContinuous) ...[
                  const SizedBox(height: 3),
                  Text(
                    'Auto-advance: Surah ${surah.number} → ${surah.number + 1}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? const Color(0xFFC4B5FD)
                          : const Color(0xFF6D28D9),
                    ),
                  ),
                ],
              ],
            ),
            Row(
              children: [
                _buildAudioButton(
                  speakerIcon,
                  isPlaying,
                  isLoading,
                  isActive,
                  isDark,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAudioButton(
    IconData icon,
    bool isPlaying,
    bool isLoading,
    bool isActive,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: _toggleAudio,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF3B82F6).withValues(alpha: 0.2)
              : const Color(0xFF2563EB).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(999),
          border: isPlaying || isActive
              ? Border.all(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.5),
                  width: 1.2,
                )
              : null,
        ),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 150),
          child: Icon(
            icon,
            size: isPlaying ? 17 : 16,
            color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
          ),
        ),
      ),
    );
  }
}
