import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/theme/app_colors.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: themeProvider.toggleTheme,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.hairlineDark : AppColors.hairlineLight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Center(
          child: isDark
              ? const Icon(Icons.wb_sunny_outlined, size: 20)
              : Transform.rotate(
                  angle: -0.4,
                  child: const Icon(Icons.nightlight_round, size: 20),
                ),
        ),
      ),
    );
  }
}
