import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/providers/verse_provider.dart';
import '../../core/theme/app_colors.dart';

/// Verse of the Day card widget with glass morphism styling
class VerseOfTheDayCard extends StatelessWidget {
  const VerseOfTheDayCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Consumer<VerseProvider>(
        builder: (context, verseProvider, child) {
          final canShare =
              !verseProvider.isLoading &&
              verseProvider.errorMessage == null &&
              verseProvider.verse != null;

          return Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap:
                  canShare
                      ? () => _showShareOptions(context, verseProvider.verse!)
                      : null,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Container(
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
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Builder(
                        builder: (context) {
                          if (verseProvider.isLoading) {
                            return _buildLoadingState(isDark);
                          }

                          if (verseProvider.errorMessage != null) {
                            return _buildErrorState(
                              context,
                              verseProvider.errorMessage!,
                              verseProvider,
                              isDark,
                            );
                          }

                          if (verseProvider.verse != null) {
                            return _buildVerseContent(
                              context,
                              verseProvider.verse!,
                              isDark,
                            );
                          }

                          return _buildEmptyState(isDark);
                        },
                      ),
                    ),
                  ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Build loading state
  Widget _buildLoadingState(bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(isDark),
        const SizedBox(height: 16),
        Center(
          child: CircularProgressIndicator(
            color: isDark ? AppColors.teal : const Color(0xFF0D9488),
            strokeWidth: 2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Loading verse...',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
          ),
        ),
      ],
    );
  }

  /// Build error state with retry button
  Widget _buildErrorState(
    BuildContext context,
    String errorMessage,
    VerseProvider provider,
    bool isDark,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(isDark),
        const SizedBox(height: 16),
        Center(
          child: Column(
            children: [
              Icon(
                Icons.error_outline,
                size: 40,
                color: Colors.red.withValues(alpha: 0.7),
              ),
              const SizedBox(height: 12),
              Text(
                errorMessage,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.textMutedDark
                      : AppColors.textMutedLight,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => provider.refresh(),
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark
                      ? AppColors.teal
                      : const Color(0xFF0D9488),
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
      ],
    );
  }

  /// Build empty state
  Widget _buildEmptyState(bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(isDark),
        const SizedBox(height: 16),
        Text(
          'No verse available',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
          ),
        ),
      ],
    );
  }

  /// Build verse content
  Widget _buildVerseContent(BuildContext context, dynamic verse, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: _buildHeader(isDark)),
            Icon(
              Icons.share_outlined,
              size: 18,
              color: isDark
                  ? AppColors.textMutedDark
                  : AppColors.textMutedLight,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Arabic text (RTL)
        Directionality(
          textDirection: TextDirection.rtl,
          child: Text(
            verse.arabic,
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

        // English translation
        Text(
          '"${verse.translation}"',
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

        // Surah reference
        Text(
          verse.formattedReference,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: isDark
                ? const Color(0xFF64748B) // slate-500
                : const Color(0xFF94A3B8), // slate-400
          ),
        ),
      ],
    );
  }

  /// Show share options bottom sheet
  void _showShareOptions(BuildContext context, dynamic verse) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final verseText =
            '''
${verse.arabic}

"${verse.translation}"

- ${verse.formattedReference}
''';

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
                'Share Verse',
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
                  await Clipboard.setData(ClipboardData(text: verseText));
                  if (context.mounted) {
                    Navigator.pop(bottomSheetContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Verse copied to clipboard'),
                        duration: Duration(seconds: 2),
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
                    ShareParams(
                      text: verseText,
                      subject: 'Verse of the Day - ${verse.surahName}',
                    ),
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

  /// Build header with badge
  Widget _buildHeader(bool isDark) {
    return Row(
      children: [
        Icon(Icons.format_quote, size: 16, color: AppColors.teal),
        const SizedBox(width: 6),
        Text(
          'VERSE OF THE DAY',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.teal,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}
