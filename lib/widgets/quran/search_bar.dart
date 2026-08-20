import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/providers/quran_provider.dart';
import '../../core/theme/app_colors.dart';

class QuranSearchBar extends StatefulWidget {
  const QuranSearchBar({super.key});

  @override
  State<QuranSearchBar> createState() => _QuranSearchBarState();
}

class _QuranSearchBarState extends State<QuranSearchBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (mounted) {
        setState(() {
          _isFocused = _focusNode.hasFocus;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final quranProvider = context.read<QuranProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        onChanged: (value) => quranProvider.setSearchQuery(value),
        style: GoogleFonts.plusJakartaSans().copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: isDark ? AppColors.cardDark : Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: isDark ? AppColors.hairlineDark : AppColors.hairlineLight,
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: isDark ? AppColors.hairlineDark : AppColors.hairlineLight,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: AppColors.primary.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          prefixIcon: Icon(
            Icons.search,
            size: 18,
            color: _isFocused
                ? AppColors.primary
                : isDark
                    ? AppColors.textMutedDark
                    : AppColors.textMutedLight,
          ),
          hintText: 'Search Surah names...',
          hintStyle: GoogleFonts.plusJakartaSans().copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
          ),
          suffixIcon: _controller.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _controller.clear();
                    quranProvider.setSearchQuery('');
                  },
                  child: Icon(
                    Icons.clear,
                    size: 16,
                    color: isDark
                        ? AppColors.textMutedDark
                        : AppColors.textMutedLight,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
