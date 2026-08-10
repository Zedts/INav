import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/errors/error_messages.dart';
import '../../core/theme/app_colors.dart';

class ErrorStateView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final VoidCallback? onOpenSettings;

  const ErrorStateView({
    super.key,
    required this.message,
    required this.onRetry,
    this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final category = categorizeErrorMessage(message);

    final IconData icon;
    final String title;
    final Color iconColor;
    switch (category) {
      case ErrorCategory.offline:
        icon = Icons.wifi_off_rounded;
        title = 'No Internet Connection';
        iconColor = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
      case ErrorCategory.timeout:
        icon = Icons.hourglass_empty_rounded;
        title = 'Connection Timed Out';
        iconColor = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
      case ErrorCategory.location:
        icon = Icons.location_off_rounded;
        title = 'Location Unavailable';
        iconColor = isDark ? AppColors.primaryDark : AppColors.primaryLight;
      case ErrorCategory.generic:
        icon = Icons.error_outline;
        title = 'Something Went Wrong';
        iconColor = AppColors.roseAccent;
    }

    final showSettings =
        onOpenSettings != null && category == ErrorCategory.location;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(icon, size: 32, color: iconColor),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.fraunces(
                color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: GoogleFonts.plusJakartaSans(
                color:
                    isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                fontSize: 14,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: Text(
                    'Retry',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isDark ? AppColors.primaryDark : AppColors.primaryLight,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                if (showSettings) ...[
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: onOpenSettings,
                    icon: const Icon(Icons.settings, size: 18),
                    label: Text(
                      'Open Settings',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark
                          ? AppColors.primaryDark
                          : AppColors.primaryLight,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void showErrorSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
  );
}
