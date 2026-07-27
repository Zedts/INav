import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/quran_provider.dart';

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
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: isDark ? const Color(0xFF0F172A) : Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: isDark
                  ? const Color(0xFF1E293B).withValues(alpha: 0.8)
                  : const Color(0xFFE2E8F0).withValues(alpha: 0.8),
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: isDark
                  ? const Color(0xFF1E293B).withValues(alpha: 0.8)
                  : const Color(0xFFE2E8F0).withValues(alpha: 0.8),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: const Color(0xFF0D9488).withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          prefixIcon: Icon(
            Icons.search,
            size: 18,
            color: _isFocused
                ? const Color(0xFF0D9488)
                : isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B),
          ),
          hintText: 'Search Surah names...',
          hintStyle: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
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
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
