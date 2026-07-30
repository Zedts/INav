import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Services & Tools grid section with 8 feature buttons
class ServicesToolsGrid extends StatelessWidget {
  final Function(int) onNavigate;

  const ServicesToolsGrid({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Define all service items
    final services = [
      _ServiceItem(
        icon: Icons.menu_book_outlined,
        label: 'Quran',
        color: const Color(0xFF0D9488), // teal
        isActive: true,
        targetIndex: 1, // QuranScreen index
      ),
      _ServiceItem(
        icon: Icons.mosque_outlined,
        label: 'Mosque',
        color: const Color(0xFF059669), // emerald
        isActive: true,
        targetIndex: 2, // MosqueScreen index
      ),
      _ServiceItem(
        icon: Icons.explore_outlined,
        label: 'Qibla',
        color: const Color(0xFF2563EB), // blue
        isActive: true,
        targetIndex: 3, // QiblaScreen index
      ),
      _ServiceItem(
        icon: Icons.auto_stories_outlined,
        label: 'Duas',
        color: const Color(0xFF7C3AED), // purple
        isActive: false,
      ),
      _ServiceItem(
        icon: Icons.circle_outlined,
        label: 'Tasbih',
        color: const Color(0xFFE11D48), // rose
        isActive: false,
      ),
      _ServiceItem(
        icon: Icons.trending_up,
        label: 'Tracker',
        color: const Color(0xFFD97706), // amber
        isActive: false,
      ),
      _ServiceItem(
        icon: Icons.article_outlined,
        label: 'Hadith',
        color: const Color(0xFF4F46E5), // indigo
        isActive: false,
      ),
      _ServiceItem(
        icon: Icons.more_horiz,
        label: 'More',
        color: const Color(0xFF64748B), // slate
        isActive: false,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SERVICES & TOOLS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.textMutedDark
                      : AppColors.textMutedLight,
                  letterSpacing: 1.2,
                ),
              ),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('More tools section opened'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.primaryDark
                        : AppColors.primaryLight,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 1),

        // Grid of service buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.95,
            ),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              return _ServiceButton(
                service: service,
                isDark: isDark,
                onTap: () {
                  if (service.isActive && service.targetIndex != null) {
                    // Navigate to target screen
                    onNavigate(service.targetIndex!);
                  } else {
                    // Show coming soon toast
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${service.label} feature coming soon'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Data model for service item
class _ServiceItem {
  final IconData icon;
  final String label;
  final Color color;
  final bool isActive;
  final int? targetIndex;

  _ServiceItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.isActive,
    this.targetIndex,
  });
}

/// Individual service button widget
class _ServiceButton extends StatelessWidget {
  final _ServiceItem service;
  final bool isDark;
  final VoidCallback onTap;

  const _ServiceButton({
    required this.service,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.cardLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? AppColors.borderDark.withValues(alpha: 0.8)
                    : AppColors.borderLight.withValues(alpha: 0.8),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? Colors.black : Colors.grey).withValues(
                    alpha: 0.05,
                  ),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon with colored background
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: service.color.withValues(
                        alpha: isDark ? 0.2 : 0.1,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(service.icon, color: service.color, size: 22),
                  ),

                  const SizedBox(height: 4),

                  // Label
                  Text(
                    service.label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.textMainDark
                          : AppColors.textMainLight,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ),
      ),
    );
  }
}
