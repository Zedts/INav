import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class ServicesToolsGrid extends StatelessWidget {
  final Function(int) onNavigate;

  const ServicesToolsGrid({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final plusJakarta = GoogleFonts.plusJakartaSans();

    final services = [
      _ServiceItem(
        icon: Icons.menu_book_outlined,
        label: 'Quran',
        color: AppColors.teal,
        isActive: true,
        targetIndex: 1,
      ),
      _ServiceItem(
        icon: Icons.mosque_outlined,
        label: 'Mosque',
        color: const Color(0xFF059669),
        isActive: true,
        targetIndex: 2,
      ),
      _ServiceItem(
        icon: Icons.explore_outlined,
        label: 'Qibla',
        color: AppColors.primary,
        isActive: true,
        targetIndex: 3,
      ),
      _ServiceItem(
        icon: Icons.auto_stories_outlined,
        label: 'Duas',
        color: const Color(0xFF7C3AED),
        isActive: false,
      ),
      _ServiceItem(
        icon: Icons.circle_outlined,
        label: 'Tasbih',
        color: AppColors.roseAccent,
        isActive: false,
      ),
      _ServiceItem(
        icon: Icons.trending_up,
        label: 'Tracker',
        color: AppColors.roseAccent,
        isActive: false,
      ),
      _ServiceItem(
        icon: Icons.article_outlined,
        label: 'Hadith',
        color: const Color(0xFF4F46E5),
        isActive: false,
      ),
      _ServiceItem(
        icon: Icons.more_horiz,
        label: 'More',
        color: AppColors.textMutedLight,
        isActive: false,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SERVICES & TOOLS',
                style: plusJakarta.copyWith(
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
                  style: plusJakarta.copyWith(
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

        const SizedBox(height: 8),

        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: services.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final service = services[index];
              return SizedBox(
                width: 80,
                child: _ServiceButton(
                  service: service,
                  isDark: isDark,
                  onTap: () {
                    if (service.isActive && service.targetIndex != null) {
                      onNavigate(service.targetIndex!);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${service.label} feature coming soon'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

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
    final plusJakarta = GoogleFonts.plusJakartaSans();

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
                    ? AppColors.hairlineDark.withValues(alpha: 0.8)
                    : AppColors.hairlineLight.withValues(alpha: 0.8),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? Colors.black : Colors.grey).withValues(
                    alpha: 0.05,
                  ),
                  blurRadius: 3,
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
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: service.color.withValues(
                        alpha: isDark ? 0.2 : 0.1,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(service.icon, color: service.color, size: 22),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    service.label,
                    style: plusJakarta.copyWith(
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
