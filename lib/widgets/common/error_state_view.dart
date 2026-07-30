import 'package:flutter/material.dart';
import '../../core/errors/error_messages.dart';
import '../../core/theme/app_colors.dart';

/// Reusable error state view used by every screen.
///
/// Guarantees the SAME error always gets the SAME icon, title, message
/// style, and actions, no matter which screen it appears on. The icon and
/// title are derived from the message via [categorizeErrorMessage].
class ErrorStateView extends StatelessWidget {
  /// User-facing error message (from a provider's errorMessage)
  final String message;

  /// Called when the user taps Retry
  final VoidCallback onRetry;

  /// Optional — shown as an "Open Settings" button, but only for
  /// location-related errors where settings can actually help
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
        iconColor = const Color(0xFFEF4444);
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
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, size: 32, color: iconColor),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
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
                  label: const Text(
                    'Retry',
                    style: TextStyle(fontWeight: FontWeight.w700),
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
                    label: const Text(
                      'Open Settings',
                      style: TextStyle(fontWeight: FontWeight.w700),
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

/// Show an error snackbar with a consistent style everywhere in the app
void showErrorSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
  );
}
