import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/errors/error_messages.dart';
import '../../core/models/mosque_model.dart';
import '../../core/providers/mosque_provider.dart';
import '../common/error_state_view.dart';
import 'mosque_quick_actions.dart';

class MosqueDetailSheet extends StatelessWidget {
  final MosqueModel mosque;

  const MosqueDetailSheet({
    super.key,
    required this.mosque,
  });

  static void show(BuildContext context, MosqueModel mosque) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => MosqueDetailSheet(mosque: mosque),
    );
  }

  Future<void> _navigate(BuildContext context) async {
    final ok = await context.read<MosqueProvider>().navigateTo(mosque);
    if (!context.mounted) return;
    if (!ok) {
      showErrorSnackBar(context, ErrorMessages.mapsUnavailable);
    }
  }

  void _toggleFavorite(BuildContext context) {
    final provider = context.read<MosqueProvider>();
    final wasFavorite = provider.isFavorite(mosque.id);
    provider.toggleFavorite(mosque.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          wasFavorite ? 'Removed from favorites' : 'Added to favorites',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);
    final maxHeight = mediaQuery.size.height * 0.92;
    final minHeight = mediaQuery.size.height * 0.5;
    final provider = context.watch<MosqueProvider>();
    final isFavorite = provider.isFavorite(mosque.id);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: maxHeight,
            minHeight: minHeight,
          ),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 40,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDragHandle(isDark),
                      _buildHeader(isDark),
                      _buildBadgesRow(isDark),
                      const SizedBox(height: 20),
                      _buildDetailsSection(isDark),
                    ],
                  ),
                ),
              ),
              _buildBottomActions(context, isDark, isFavorite),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDragHandle(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Center(
        child: Container(
          width: 48,
          height: 5,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 16),
      child: Container(
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
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(
                    alpha: isDark ? 0.2 : 0.1,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.mosque,
                  color: Color(0xFF059669),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mosque.name,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? const Color(0xFFF8FAFC)
                            : const Color(0xFF0F172A),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 13,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            mosque.address,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadgesRow(bool isDark) {
    final badges = <Widget>[
      _buildBadge(
        icon: Icons.directions_walk_rounded,
        bg: const Color(0xFF10B981).withValues(alpha: 0.1),
        fg: const Color(0xFF059669),
        text: '${mosque.estimatedWalkingTime} walk',
      ),
      _buildBadge(
        icon: Icons.straighten,
        bg: const Color(0xFF2563EB).withValues(alpha: 0.1),
        fg: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
        text: mosque.formattedDistance,
      ),
    ];

    if (mosque.rating != null) {
      badges.add(
        _buildBadge(
          icon: Icons.star_rounded,
          bg: const Color(0xFFF59E0B).withValues(alpha: 0.1),
          fg: const Color(0xFFD97706),
          text: mosque.rating!.toStringAsFixed(1),
        ),
      );
    }

    if (mosque.openNow != null) {
      final open = mosque.openNow!;
      badges.add(
        _buildBadge(
          icon: open ? Icons.check_circle_outline : Icons.cancel_outlined,
          bg: (open ? const Color(0xFF10B981) : const Color(0xFFEF4444))
              .withValues(alpha: 0.1),
          fg: open ? const Color(0xFF059669) : const Color(0xFFEF4444),
          text: open ? 'Open now' : 'Closed',
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: badges,
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required Color bg,
    required Color fg,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.place_outlined,
              size: 13,
              color: Color(0xFF059669),
            ),
            const SizedBox(width: 6),
            Text(
              'LOCATION DETAILS',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          mosque.address,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: (isDark
                    ? const Color(0xFFF8FAFC)
                    : const Color(0xFF0F172A))
                .withValues(alpha: 0.9),
            height: 1.65,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '${mosque.latitude.toStringAsFixed(5)}, ${mosque.longitude.toStringAsFixed(5)}',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
          ),
        ),
        if (mosque.iconTag != null && mosque.iconTag!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'Category: ${mosque.iconTag}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBottomActions(
    BuildContext context,
    bool isDark,
    bool isFavorite,
  ) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        16 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark
                ? const Color(0xFF1E293B).withValues(alpha: 0.8)
                : const Color(0xFFE2E8F0).withValues(alpha: 0.8),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: MosqueNavigateButton(
              onTap: () => _navigate(context),
            ),
          ),
          const SizedBox(width: 12),
          MosqueFavoriteButton(
            isFavorite: isFavorite,
            onTap: () => _toggleFavorite(context),
          ),
        ],
      ),
    );
  }
}
