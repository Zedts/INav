import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/errors/error_messages.dart';
import '../../core/providers/quran_provider.dart';
import '../../core/models/surah_model.dart';
import '../../core/theme/app_colors.dart';
import '../../screens/quran/surah_reading_screen.dart';
import '../common/error_state_view.dart';
import '../common/pill_badge.dart';

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
      showErrorSnackBar(context, ErrorMessages.audioPlaybackFailed);
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
      showErrorSnackBar(context, ErrorMessages.audioStopFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final quranProvider = context.watch<QuranProvider>();
    final playingSurah = quranProvider.currentPlayingSurah;
    final isContinuous = quranProvider.continuousPlaybackMode;
    final hasActiveSurah = playingSurah != null;
    final lastRead = quranProvider.getLastRead();
    final hasReadingHistory = lastRead != null;

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

    final speakerIcon = isLoading
        ? Icons.hourglass_empty
        : (isPlaying ? Icons.volume_up : Icons.volume_down);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () {
          final quranProvider = context.read<QuranProvider>();
          final lastRead = quranProvider.getLastRead();
          final surahNum = lastRead?.$1 ?? 1;
          final ayahNum = lastRead?.$2;

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SurahReadingScreen(
                surahNumber: surahNum,
                initialAyahNumber: ayahNum,
              ),
            ),
          );
        },
        child: SizedBox(
          height: 170,
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
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
                          ? Colors.white.withValues(alpha: 0.04)
                          : AppColors.primary.withValues(alpha: 0.06),
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
                      20,
                      hasActiveSurah ? 60 : 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        hasActiveSurah
                            ? isContinuous
                                ? _buildContinuousBadge(isDark)
                                : _buildNowPlayingBadge(isDark)
                            : hasReadingHistory
                                ? PillBadge(
                                    label: 'CONTINUE READING',
                                    icon: Icons.menu_book,
                                    showPulsingDot: true,
                                    textColor: isDark
                                        ? AppColors.primaryDark
                                        : AppColors.primary,
                                    pulsingDotColor: AppColors.primary,
                                  )
                                : PillBadge(
                                    label: 'START READING',
                                    icon: Icons.menu_book,
                                    showPulsingDot: false,
                                    textColor: isDark
                                        ? AppColors.primaryDark
                                        : AppColors.primary,
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
              ? AppColors.roseAccent.withValues(alpha: 0.18)
              : AppColors.roseAccent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.roseAccent.withValues(alpha: 0.35),
            width: 1,
          ),
        ),
        child: Icon(Icons.close, size: 20, color: AppColors.roseAccent),
      ),
    );
  }

  Widget _buildContinuousBadge(bool isDark) {
    return PillBadge(
      label: 'CONTINUOUS PLAY',
      icon: Icons.all_inclusive,
      showPulsingDot: true,
      textColor: isDark ? AppColors.primaryDark : AppColors.primary,
      pulsingDotColor: AppColors.primary,
    );
  }

  Widget _buildNowPlayingBadge(bool isDark) {
    return PillBadge(
      label: 'NOW PLAYING',
      icon: Icons.volume_up,
      showPulsingDot: true,
      textColor: isDark ? AppColors.primaryDark : AppColors.primary,
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
    final quranProvider = context.watch<QuranProvider>();
    final lastRead = quranProvider.getLastRead();
    final hasLastRead = lastRead != null;

    String? surahName;
    if (hasLastRead) {
      final surah = quranProvider.allSurahs.firstWhere(
        (s) => s.number == lastRead.$1,
        orElse: () => SurahModel(
          audioUrl: '',
          nameEn: '',
          nameId: '',
          nameLong: '',
          nameShort: '',
          number: 0,
          numberOfVerses: 0,
          sequence: 0,
          revelation: '',
          revelationEn: '',
          revelationId: '',
          tafsir: '',
          translationEn: '',
          translationId: '',
        ),
      );
      if (surah.number != 0) {
        surahName = surah.nameEn;
      }
    }

    final fraunces = GoogleFonts.fraunces();
    final plusJakarta = GoogleFonts.plusJakartaSans();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          surahName ?? (hasLastRead ? 'Continue Reading' : 'Start Reading'),
          style: fraunces.copyWith(
            fontSize: 26,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
            height: 1.2,
            letterSpacing: -0.02,
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
                  hasLastRead
                      ? 'Surah ${lastRead.$1}, Ayah ${lastRead.$2}'
                      : 'Choose a Surah below',
                  style: plusJakarta.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textMainDark.withValues(alpha: 0.88)
                        : AppColors.textMainLight.withValues(alpha: 0.88),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  hasLastRead
                      ? 'Tap to continue where you left off'
                      : 'or tap play → all 114 Surahs',
                  style: plusJakarta.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.textMutedDark
                        : AppColors.textMutedLight,
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
                    color: AppColors.primary.withValues(alpha: isDark ? 0.18 : 0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Icon(
                    Icons.menu_book,
                    size: 18,
                    color: AppColors.primary,
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
    final fraunces = GoogleFonts.fraunces();
    final plusJakarta = GoogleFonts.plusJakartaSans();

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
                color: AppColors.primary.withValues(alpha: isDark ? 0.22 : 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '${surah.number}',
                  style: plusJakarta.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
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
                    surah.nameEn,
                    style: fraunces.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
                      height: 1.1,
                      letterSpacing: -0.02,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${surah.translationEn} · ${surah.translationId}',
                    style: plusJakarta.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.textMutedDark
                          : AppColors.textMutedLight,
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
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                fontFamily: 'serif',
                height: 1,
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
                  style: plusJakarta.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textMainDark.withValues(alpha: 0.88)
                        : AppColors.textMainLight.withValues(alpha: 0.88),
                  ),
                ),
                if (isContinuous) ...[
                  const SizedBox(height: 3),
                  Text(
                    'Auto-advance: Surah ${surah.number} → ${surah.number + 1}',
                    style: plusJakarta.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
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
          color: AppColors.primary.withValues(alpha: isDark ? 0.18 : 0.12),
          borderRadius: BorderRadius.circular(999),
          border: isPlaying || isActive
              ? Border.all(
                  color: AppColors.primary.withValues(alpha: 0.45),
                  width: 1,
                )
              : null,
        ),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 150),
          child: Icon(
            icon,
            size: isPlaying ? 17 : 16,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
