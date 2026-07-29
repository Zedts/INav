import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:glass/glass.dart';
import '../../core/providers/mosque_provider.dart';
import '../../core/models/mosque_model.dart';
import '../common/glass_pill_badge.dart';
import 'mosque_detail_sheet.dart';
import 'mosque_quick_actions.dart';

class NearestMosqueBanner extends StatelessWidget {
  final MosqueModel? mosque;
  final bool isOverridden;
  final VoidCallback? onResetToNearest;

  const NearestMosqueBanner({
    super.key,
    required this.mosque,
    this.isOverridden = false,
    this.onResetToNearest,
  });

  Future<void> _navigate(BuildContext context, MosqueModel m) async {
    final ok = await context.read<MosqueProvider>().navigateTo(m);
    if (!context.mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open Maps. Please try again later.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _toggleFavorite(BuildContext context, MosqueModel m) {
    final provider = context.read<MosqueProvider>();
    final wasFavorite = provider.isFavorite(m.id);
    provider.toggleFavorite(m.id);
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
    final m = mosque;
    final provider = context.watch<MosqueProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 170,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withValues(alpha: 0.35),
                      blurRadius: 60,
                      spreadRadius: -10,
                      offset: const Offset(-20, -20),
                    ),
                    BoxShadow(
                      color: const Color(0xFF06B6D4).withValues(alpha: 0.18),
                      blurRadius: 70,
                      spreadRadius: -10,
                      offset: const Offset(20, 20),
                    ),
                    BoxShadow(
                      color: const Color(0xFFD97706).withValues(alpha: 0.18),
                      blurRadius: 50,
                      spreadRadius: -15,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          const Color(0xFF0F172A).withValues(alpha: 0.55),
                          const Color(0xFF0F172A).withValues(alpha: 0.25),
                        ]
                      : [
                          Colors.white.withValues(alpha: 0.35),
                          Colors.white.withValues(alpha: 0.12),
                        ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.65)
                        : const Color(0xFF065F46).withValues(alpha: 0.18),
                    blurRadius: 50,
                    offset: const Offset(0, 25),
                  ),
                  BoxShadow(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.35)
                        : Colors.white.withValues(alpha: 0.8),
                    blurRadius: isDark ? 1 : 2,
                    offset: const Offset(0, 1),
                    spreadRadius: -1,
                  ),
                  if (isDark)
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 2,
                      offset: const Offset(0, -1),
                      spreadRadius: -1,
                    ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.18)
                        : Colors.white.withValues(alpha: 0.45),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: const Alignment(-1.0, -1.0),
                            end: const Alignment(0.6, 0.6),
                            colors: isDark
                                ? [
                                    Colors.white.withValues(alpha: 0.04),
                                    Colors.white.withValues(alpha: 0.01),
                                    Colors.transparent,
                                  ]
                                : [
                                    Colors.white.withValues(alpha: 0.45),
                                    Colors.white.withValues(alpha: 0.1),
                                    Colors.transparent,
                                  ],
                            stops: const [0.0, 0.35, 0.6],
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                    Positioned(
                      right: -16,
                      bottom: -24,
                      child: Icon(
                        Icons.mosque,
                        size: 110,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : const Color(0xFF065F46).withValues(alpha: 0.1),
                      ),
                    ),
                    if (isOverridden && onResetToNearest != null)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: GestureDetector(
                          onTap: onResetToNearest,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.black.withValues(alpha: 0.45)
                                  : Colors.white.withValues(alpha: 0.75),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.15)
                                    : const Color(0xFF0F172A)
                                        .withValues(alpha: 0.08),
                              ),
                            ),
                            child: Icon(
                              Icons.replay,
                              size: 17,
                              color: isDark
                                  ? const Color(0xFF6EE7B7)
                                  : const Color(0xFF059669),
                            ),
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GlassPillBadge(
                            label: isOverridden
                                ? 'SELECTED MOSQUE'
                                : 'NEAREST TO YOU',
                            icon: isOverridden
                                ? Icons.push_pin_outlined
                                : Icons.location_on,
                            showPulsingDot: !isOverridden,
                            textColor: isOverridden
                                ? (isDark
                                    ? const Color(0xFFFCD34D)
                                    : const Color(0xFFD97706))
                                : (isDark
                                    ? const Color(0xFF6EE7B7)
                                    : const Color(0xFF065F46)),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: m == null
                                ? _buildEmptyContent(context, isDark)
                                : _buildContent(
                                    context,
                                    isDark,
                                    m,
                                    provider.isFavorite(m.id),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ).asGlass(
              blurX: isDark ? 32 : 28,
              blurY: isDark ? 32 : 28,
              tintColor: Colors.transparent,
              frosted: true,
              clipBorderRadius: BorderRadius.circular(24),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyContent(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Searching nearby…',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
            height: 1.2,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Fetching nearest mosques',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
          ),
        ),
        const Spacer(),
        const Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator.adaptive(strokeWidth: 2.2),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(
    BuildContext context,
    bool isDark,
    MosqueModel m,
    bool isFavorite,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          m.name,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
            height: 1.1,
            letterSpacing: -0.3,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(
              Icons.directions_walk_rounded,
              size: 14,
              color: isDark
                  ? const Color(0xFF6EE7B7)
                  : const Color(0xFF10B981),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                '${m.estimatedWalkingTime} walk (${m.formattedDistance})',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? const Color(0xFFCBD5E1)
                      : const Color(0xFF334155),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.2),
              ),
            ),
          ),
          child: MosqueQuickActionsRow(
            onNavigate: () => _navigate(context, m),
            onToggleFavorite: () => _toggleFavorite(context, m),
            isFavorite: isFavorite,
            onInfo: () => MosqueDetailSheet.show(context, m),
          ),
        ),
      ],
    );
  }
}
