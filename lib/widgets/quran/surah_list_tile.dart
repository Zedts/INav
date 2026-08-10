import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/errors/error_messages.dart';
import '../../core/models/surah_model.dart';
import '../../core/providers/quran_provider.dart';
import '../../core/theme/app_colors.dart';

class SurahListTile extends StatelessWidget {
  final SurahModel surah;
  final VoidCallback onTap;

  const SurahListTile({super.key, required this.surah, required this.onTap});

  Future<void> _handleAudioTap(BuildContext context) async {
    final quranProvider = context.read<QuranProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final url = surah.audioUrl;
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
        source: AudioSourceId.tile,
        sourceKey: surah.number.toString(),
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
    final quranProvider = context.watch<QuranProvider>();
    final surahKey = surah.number.toString();
    final isPlaying = quranProvider.isSurahPlaying(surahKey);
    final isLoading = quranProvider.isSurahLoading(surahKey);
    final isActive = quranProvider.isSurahActive(surahKey);

    final audioIcon = isLoading
        ? Icons.hourglass_empty
        : (isPlaying ? Icons.volume_up : Icons.volume_down);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark
                    ? AppColors.hairlineDark
                    : AppColors.hairlineLight.withValues(alpha: 0.8),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildNumberBadge(isDark),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        surah.nameEn,
                        style: GoogleFonts.plusJakartaSans().copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.textMainDark
                              : AppColors.textMainLight,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        surah.translationEn,
                        style: GoogleFonts.plusJakartaSans().copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppColors.textMutedDark
                              : AppColors.textMutedLight,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _handleAudioTap(context),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isPlaying || isActive
                          ? AppColors.primary.withValues(
                              alpha: isDark ? 0.3 : 0.18,
                            )
                          : AppColors.primary.withValues(
                              alpha: isDark ? 0.2 : 0.12,
                            ),
                      borderRadius: BorderRadius.circular(16),
                      border: isActive
                          ? Border.all(
                              color: AppColors.primary.withValues(alpha: 0.5),
                              width: 1.2,
                            )
                          : null,
                    ),
                    child: Icon(
                      audioIcon,
                      size: 20,
                      color: isPlaying || isActive
                          ? AppColors.primary
                          : AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      surah.nameShort,
                      style: GoogleFonts.fraunces().copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.textMainDark
                            : AppColors.textMainLight,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${surah.numberOfVerses} Ayahs',
                      style: GoogleFonts.plusJakartaSans().copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textMutedDark
                            : AppColors.textMutedLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNumberBadge(bool isDark) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          '${surah.number}',
          style: GoogleFonts.plusJakartaSans().copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
