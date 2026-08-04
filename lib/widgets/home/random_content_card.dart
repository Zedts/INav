import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../core/providers/verse_provider.dart';
import '../../core/providers/hadith_provider.dart';
import '../../core/theme/app_colors.dart';

/// Swipeable card that shows a "Random Verse" and a "Random Hadist" page.
class RandomContentCard extends StatefulWidget {
  const RandomContentCard({super.key});

  @override
  State<RandomContentCard> createState() => _RandomContentCardState();
}

class _RandomContentCardState extends State<RandomContentCard> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          height: 300,
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? AppColors.borderDark.withValues(alpha: 0.8)
                  : AppColors.borderLight.withValues(alpha: 0.8),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : Colors.grey).withValues(
                  alpha: 0.1,
                ),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              PageView(
                controller: _pageController,
                children: [
                  _RandomVersePage(isDark: isDark, onShare: _showShareOptions),
                  _RandomHadithPage(isDark: isDark, onShare: _showShareOptions),
                ],
              ),

              // Dot indicators at bottom center
              Positioned(
                left: 0,
                right: 0,
                bottom: 10,
                child: Center(
                  child: SmoothPageIndicator(
                    controller: _pageController,
                    count: 2,
                    effect: ExpandingDotsEffect(
                      activeDotColor: isDark
                          ? AppColors.primaryDark
                          : AppColors.primaryLight,
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
            ],
          ),
        ),
      ),
    );
  }

  /// Shared copy/share bottom sheet — reused by both pages
  void _showShareOptions(
    BuildContext context, {
    required String shareText,
    required String subject,
    required String snackLabel,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.3)
                      : Colors.black.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title
              Text(
                'Share $snackLabel',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.textMainDark
                      : AppColors.textMainLight,
                ),
              ),

              const SizedBox(height: 20),

              // Copy option
              ListTile(
                leading: Icon(
                  Icons.copy_outlined,
                  color: isDark
                      ? AppColors.primaryDark
                      : AppColors.primaryLight,
                ),
                title: Text(
                  'Copy to Clipboard',
                  style: TextStyle(
                    color: isDark
                        ? AppColors.textMainDark
                        : AppColors.textMainLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: shareText));
                  if (context.mounted) {
                    Navigator.pop(bottomSheetContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$snackLabel copied to clipboard'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),

              // Share option
              ListTile(
                leading: Icon(
                  Icons.share_outlined,
                  color: isDark
                      ? AppColors.primaryDark
                      : AppColors.primaryLight,
                ),
                title: Text(
                  'Share via...',
                  style: TextStyle(
                    color: isDark
                        ? AppColors.textMainDark
                        : AppColors.textMainLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(bottomSheetContext);
                  await SharePlus.instance.share(
                    ShareParams(text: shareText, subject: subject),
                  );
                },
              ),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}

/// Callback signature for opening the shared share sheet
typedef ShareCallback =
    void Function(
      BuildContext context, {
      required String shareText,
      required String subject,
      required String snackLabel,
    });

/// ------------------------------------------------------------------
/// Page 1: Random Verse
/// ------------------------------------------------------------------
class _RandomVersePage extends StatelessWidget {
  final bool isDark;
  final ShareCallback onShare;

  const _RandomVersePage({required this.isDark, required this.onShare});

  @override
  Widget build(BuildContext context) {
    return Consumer<VerseProvider>(
      builder: (context, provider, child) {
        final canShare =
            !provider.isLoading &&
            provider.errorMessage == null &&
            provider.verse != null;

        return _ContentPageScaffold(
          isDark: isDark,
          accent: AppColors.teal,
          headerIcon: Icons.format_quote,
          headerLabel: 'RANDOM VERSE',
          showShareIcon: canShare,
          onShare: canShare
              ? () {
                  final verse = provider.verse!;
                  onShare(
                    context,
                    shareText:
                        '${verse.arabic}\n\n"${verse.translation}"\n\n- ${verse.formattedReference}',
                    subject: 'Random Verse - ${verse.surahName}',
                    snackLabel: 'Verse',
                  );
                }
              : null,
          child: Builder(
            builder: (context) {
              if (provider.isLoading) {
                return _LoadingState(isDark: isDark, accent: AppColors.teal);
              }
              if (provider.errorMessage != null) {
                return _ErrorState(
                  isDark: isDark,
                  accent: AppColors.teal,
                  message: provider.errorMessage!,
                  onRetry: () => provider.refresh(),
                );
              }
              if (provider.verse != null) {
                final verse = provider.verse!;
                return _ContentBody(
                  isDark: isDark,
                  arabic: verse.arabic,
                  translation: verse.translation,
                  reference: verse.formattedReference,
                );
              }
              return _EmptyState(isDark: isDark, message: 'No verse available');
            },
          ),
        );
      },
    );
  }
}

/// ------------------------------------------------------------------
/// Page 2: Random Hadist
/// ------------------------------------------------------------------
class _RandomHadithPage extends StatelessWidget {
  final bool isDark;
  final ShareCallback onShare;

  const _RandomHadithPage({required this.isDark, required this.onShare});

  static const Color _indigo = Color(0xFF6366F1);

  @override
  Widget build(BuildContext context) {
    return Consumer<HadithProvider>(
      builder: (context, provider, child) {
        final canShare =
            !provider.isLoading &&
            provider.errorMessage == null &&
            provider.hadith != null;

        return _ContentPageScaffold(
          isDark: isDark,
          accent: _indigo,
          headerIcon: Icons.menu_book_outlined,
          headerLabel: 'RANDOM HADIST',
          showShareIcon: canShare,
          onShare: canShare
              ? () {
                  final hadith = provider.hadith!;
                  onShare(
                    context,
                    shareText:
                        '${hadith.arabic}\n\n"${hadith.translation}"\n\n- ${hadith.formattedReference}',
                    subject: 'Random Hadist - ${hadith.formattedReference}',
                    snackLabel: 'Hadith',
                  );
                }
              : null,
          child: Builder(
            builder: (context) {
              if (provider.isLoading) {
                return _LoadingState(isDark: isDark, accent: _indigo);
              }
              if (provider.errorMessage != null) {
                return _ErrorState(
                  isDark: isDark,
                  accent: _indigo,
                  message: provider.errorMessage!,
                  onRetry: () => provider.refresh(),
                );
              }
              if (provider.hadith != null) {
                final hadith = provider.hadith!;
                return _ContentBody(
                  isDark: isDark,
                  arabic: hadith.arabic,
                  translation: hadith.translation,
                  reference: hadith.formattedReference,
                );
              }
              return _EmptyState(
                isDark: isDark,
                message: 'No hadith available',
              );
            },
          ),
        );
      },
    );
  }
}

/// Shared page shell: header row (badge + optional share icon) then content
class _ContentPageScaffold extends StatelessWidget {
  final bool isDark;
  final Color accent;
  final IconData headerIcon;
  final String headerLabel;
  final bool showShareIcon;
  final VoidCallback? onShare;
  final Widget child;

  const _ContentPageScaffold({
    required this.isDark,
    required this.accent,
    required this.headerIcon,
    required this.headerLabel,
    required this.showShareIcon,
    required this.onShare,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onShare,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        // Extra bottom padding leaves room for the dot indicators
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(headerIcon, size: 16, color: accent),
                    const SizedBox(width: 6),
                    Text(
                      headerLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: accent,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                if (showShareIcon)
                  Icon(
                    Icons.share_outlined,
                    size: 18,
                    color: isDark
                        ? AppColors.textMutedDark
                        : AppColors.textMutedLight,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

/// Arabic + translation + reference, scrollable for long content
class _ContentBody extends StatelessWidget {
  final bool isDark;
  final String arabic;
  final String translation;
  final String reference;

  const _ContentBody({
    required this.isDark,
    required this.arabic,
    required this.translation,
    required this.reference,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Arabic text (RTL)
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              arabic,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.textMainDark
                    : AppColors.textMainLight,
                height: 1.8,
                fontFamily: 'serif',
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Translation
          Text(
            '"$translation"',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.textMutedDark
                  : AppColors.textMutedLight,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),

          // Reference
          Text(
            reference,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? const Color(0xFF64748B) // slate-500
                  : const Color(0xFF94A3B8), // slate-400
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  final bool isDark;
  final Color accent;

  const _LoadingState({required this.isDark, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: accent, strokeWidth: 2),
          const SizedBox(height: 12),
          Text(
            'Loading...',
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? AppColors.textMutedDark
                  : AppColors.textMutedLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final bool isDark;
  final Color accent;
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.isDark,
    required this.accent,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 36,
              color: Colors.red.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppColors.textMutedDark
                    : AppColors.textMutedLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isDark;
  final String message;

  const _EmptyState({required this.isDark, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: TextStyle(
          fontSize: 12,
          color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
        ),
      ),
    );
  }
}
