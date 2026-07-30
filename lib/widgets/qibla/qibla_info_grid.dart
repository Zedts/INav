import 'package:flutter/material.dart';
import '../../core/models/qibla_model.dart';

/// Detail info grid: Qibla bearing, distance to Kaaba and current location.
class QiblaInfoGrid extends StatelessWidget {
  final QiblaModel? qiblaData;
  final String cityName;
  final bool isRefreshing;
  final VoidCallback onRefreshLocation;

  const QiblaInfoGrid({
    super.key,
    required this.qiblaData,
    required this.cityName,
    required this.isRefreshing,
    required this.onRefreshLocation,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bearingText = qiblaData != null
        ? '${qiblaData!.direction.round()}° ${qiblaData!.cardinalDirection}'
        : '--°';
    final distanceText =
        qiblaData != null ? qiblaData!.formattedDistance : '-- km';
    final coordsText = qiblaData != null
        ? '${qiblaData!.latitude.toStringAsFixed(4)}°, ${qiblaData!.longitude.toStringAsFixed(4)}°'
        : '-- , --';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildCard(
                  isDark,
                  icon: Icons.explore,
                  iconColor: isDark
                      ? const Color(0xFF818CF8)
                      : const Color(0xFF4F46E5),
                  iconBackground: const Color(0xFF4F46E5)
                      .withValues(alpha: isDark ? 0.2 : 0.1),
                  label: 'QIBLA BEARING',
                  value: bearingText,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildCard(
                  isDark,
                  icon: Icons.map,
                  iconColor: const Color(0xFFD97706),
                  iconBackground: const Color(0xFFD97706)
                      .withValues(alpha: isDark ? 0.2 : 0.1),
                  label: 'DISTANCE TO KAABA',
                  value: distanceText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: _cardDecoration(isDark),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildIconTile(
                        icon: Icons.location_on,
                        iconColor: const Color(0xFF0D9488),
                        background: const Color(0xFF0D9488)
                            .withValues(alpha: isDark ? 0.2 : 0.1),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'YOUR LOCATION',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        cityName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? const Color(0xFFF8FAFC)
                              : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        coordsText,
                        style: TextStyle(
                          fontSize: 11,
                          fontFamily: 'monospace',
                          fontFeatures: const [FontFeature.tabularFigures()],
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: isRefreshing ? null : onRefreshLocation,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: isRefreshing
                        ? const Padding(
                            padding: EdgeInsets.all(10),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            Icons.refresh,
                            size: 20,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration(bool isDark) {
    return BoxDecoration(
      color: isDark ? const Color(0xFF0F172A) : Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: isDark
            ? const Color(0xFF1E293B).withValues(alpha: 0.8)
            : const Color(0xFFE2E8F0).withValues(alpha: 0.8),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ],
    );
  }

  Widget _buildIconTile({
    required IconData icon,
    required Color iconColor,
    required Color background,
  }) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, size: 18, color: iconColor),
    );
  }

  Widget _buildCard(
    bool isDark, {
    required IconData icon,
    required Color iconColor,
    required Color iconBackground,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIconTile(
            icon: icon,
            iconColor: iconColor,
            background: iconBackground,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: isDark
                  ? const Color(0xFF94A3B8)
                  : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
              color: isDark
                  ? const Color(0xFFF8FAFC)
                  : const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}
