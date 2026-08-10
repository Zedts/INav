import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/quran_provider.dart';
import '../../core/models/surah_model.dart';
import '../../widgets/common/error_state_view.dart';
import '../../widgets/quran/quran_banner.dart';
import '../../widgets/quran/search_bar.dart';
import '../../widgets/quran/surah_list_tile.dart';
import '../../widgets/quran/surah_detail_sheet.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final quranProvider = context.read<QuranProvider>();
      if (quranProvider.allSurahs.isEmpty && !quranProvider.isLoading) {
        quranProvider.loadSurahs();
      }
    });
  }

  void _openSurahDetail(SurahModel surah) {
    SurahDetailSheet.show(context, surah);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final quranProvider = context.watch<QuranProvider>();

    return SafeArea(
      top: false,
      child: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(
                  child: SizedBox(height: 16),
                ),
                const SliverToBoxAdapter(
                  child: QuranBanner(),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 20),
                ),
                const SliverToBoxAdapter(
                  child: QuranSearchBar(),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 20),
                ),
                SliverToBoxAdapter(
                  child: _buildAllSurahHeader(context, quranProvider, isDark),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 12),
                ),
                if (quranProvider.isLoading)
                  SliverToBoxAdapter(
                    child: _buildLoadingState(context),
                  )
                else if (quranProvider.errorMessage != null)
                  SliverToBoxAdapter(
                    child: ErrorStateView(
                      message: quranProvider.errorMessage!,
                      onRetry: () =>
                          quranProvider.loadSurahs(forceRefresh: true),
                    ),
                  )
                else if (quranProvider.filteredSurahs.isEmpty)
                  SliverToBoxAdapter(
                    child: _buildNoResultsState(context, isDark),
                  )
                else
                  SliverList.separated(
                    itemCount: quranProvider.filteredSurahs.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 4),
                    itemBuilder: (context, index) {
                      final surah = quranProvider.filteredSurahs[index];
                      return SurahListTile(
                        surah: surah,
                        onTap: () => _openSurahDetail(surah),
                      );
                    },
                  ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllSurahHeader(
    BuildContext context,
    QuranProvider quranProvider,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Text(
            'ALL SURAH',
            style: GoogleFonts.plusJakartaSans().copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: isDark
                  ? AppColors.textMutedDark
                  : AppColors.textMutedLight,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.teal.withValues(
                alpha: isDark ? 0.2 : 0.1,
              ),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '${quranProvider.filteredSurahs.length} Total',
              style: GoogleFonts.plusJakartaSans().copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.teal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDark ? AppColors.primaryDark : AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading Surahs...',
              style: GoogleFonts.plusJakartaSans().copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textMutedDark
                    : AppColors.textMutedLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color:
                    (isDark ? AppColors.cardDark : AppColors.cardLight),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Icon(
                Icons.search,
                size: 28,
                color: isDark
                    ? AppColors.textMutedDark.withValues(alpha: 0.6)
                    : AppColors.textMutedLight.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'No Surah found',
              style: GoogleFonts.plusJakartaSans().copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.textMainDark
                    : AppColors.textMainLight,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Try searching a different name.',
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
    );
  }
}
