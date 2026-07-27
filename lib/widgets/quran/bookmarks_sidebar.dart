import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/quran_provider.dart';
import '../../core/models/surah_model.dart';

class BookmarksSidebar extends StatelessWidget {
  final void Function(SurahModel surah) onOpenSurah;

  const BookmarksSidebar({
    super.key,
    required this.onOpenSurah,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final quranProvider = context.watch<QuranProvider>();
    final bookmarks = quranProvider.bookmarkedSurahs;
    final isOpen = quranProvider.isSidebarOpen;

    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            ignoring: !isOpen,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              color: isOpen
                  ? Colors.black.withValues(alpha: 0.6)
                  : Colors.transparent,
              child: isOpen
                  ? GestureDetector(
                      onTap: () => quranProvider.closeSidebar(),
                      child: const SizedBox.expand(),
                    )
                  : null,
            ),
          ),
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          left: isOpen ? 0 : -280,
          top: 0,
          bottom: 0,
          child: IgnorePointer(
            ignoring: !isOpen,
            child: Container(
              width: 280,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : Colors.white,
                border: Border(
                  right: BorderSide(
                    color: isDark
                        ? const Color(0xFF1E293B).withValues(alpha: 0.5)
                        : const Color(0xFFE2E8F0).withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 40,
                    offset: const Offset(4, 0),
                  ),
                ],
              ),
              child: SafeArea(
                left: false,
                right: false,
                top: true,
                bottom: true,
                child: Column(
                  children: [
                    _buildHeader(context, isDark, quranProvider),
                    Expanded(
                      child: bookmarks.isEmpty
                          ? _buildEmptyState(isDark)
                          : _buildBookmarksList(
                              context,
                              isDark,
                              bookmarks,
                              quranProvider,
                            ),
                    ),
                    _buildFooter(context, isDark),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(
    BuildContext context,
    bool isDark,
    QuranProvider quranProvider,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF0D9488).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.bookmarks,
              size: 20,
              color: Color(0xFF0D9488),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Bookmarks',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => quranProvider.closeSidebar(),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.close,
                size: 18,
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_border,
            size: 40,
            color: isDark
                ? const Color(0xFF64748B).withValues(alpha: 0.4)
                : const Color(0xFF94A3B8).withValues(alpha: 0.4),
          ),
          const SizedBox(height: 8),
          Text(
            'No bookmarks yet',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? const Color(0xFF64748B).withValues(alpha: 0.6)
                  : const Color(0xFF94A3B8).withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarksList(
    BuildContext context,
    bool isDark,
    List<SurahModel> bookmarks,
    QuranProvider quranProvider,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: bookmarks.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final surah = bookmarks[index];
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              quranProvider.closeSidebar();
              onOpenSurah(surah);
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E293B).withValues(alpha: 0.5)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D9488).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${surah.number}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
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
                          surah.nameEn,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? const Color(0xFFF8FAFC)
                                : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          surah.translationEn,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFooter(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark
                ? const Color(0xFF1E293B).withValues(alpha: 0.8)
                : const Color(0xFFE2E8F0).withValues(alpha: 0.8),
            width: 1,
          ),
        ),
      ),
      child: Center(
        child: Text(
          'SAVED SURAH',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
            color: isDark
                ? const Color(0xFF94A3B8).withValues(alpha: 0.6)
                : const Color(0xFF64748B).withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }
}
