import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/providers/qibla_provider.dart';
import '../../widgets/qibla/calibration_alert.dart';
import '../../widgets/qibla/compass_dial.dart';
import '../../widgets/qibla/qibla_hero_banner.dart';
import '../../widgets/qibla/qibla_info_grid.dart';

/// Qibla screen - live compass pointing to the Kaaba
class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  bool _wasAligned = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final qp = context.read<QiblaProvider>();
      if (!qp.isLoading && qp.qiblaData == null) {
        qp.initialize();
      }
      // Compass starts automatically — no permission prompt needed
      qp.startCompass();
    });
  }

  Future<void> _onRefresh() {
    return context.read<QiblaProvider>().refresh();
  }

  void _handleAlignmentFeedback(QiblaProvider qp) {
    final aligned = qp.isAligned;
    if (aligned && !_wasAligned) {
      HapticFeedback.mediumImpact();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
      });
    }
    _wasAligned = aligned;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final qp = context.watch<QiblaProvider>();

    _handleAlignmentFeedback(qp);

    if (qp.isLoading && qp.qiblaData == null) {
      return _buildLoadingView(isDark);
    }
    if (qp.errorMessage != null && qp.qiblaData == null) {
      return _buildErrorView(isDark, qp, qp.errorMessage!);
    }
    return _buildContent(isDark, qp);
  }

  Widget _buildLoadingView(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: isDark ? const Color(0xFF818CF8) : const Color(0xFF4F46E5),
          ),
          const SizedBox(height: 16),
          Text(
            'Calculating direction to Makkah...',
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? const Color(0xFF94A3B8)
                  : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(bool isDark, QiblaProvider qp, String err) {
    final isPermissionOrGps = err.toLowerCase().contains('permission') ||
        err.toLowerCase().contains('disabled');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isPermissionOrGps
                    ? const Color(0xFF4F46E5).withValues(alpha: 0.15)
                    : const Color(0xFFEF4444).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                isPermissionOrGps ? Icons.location_off : Icons.error_outline,
                size: 32,
                color: isPermissionOrGps
                    ? const Color(0xFF4F46E5)
                    : const Color(0xFFEF4444),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isPermissionOrGps ? 'Location needed' : 'Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark
                    ? const Color(0xFFF8FAFC)
                    : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              err,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () =>
                      qp.refresh(forceRefreshLocation: true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text(
                    'Retry',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                if (isPermissionOrGps) ...[
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      if (err.toLowerCase().contains('disabled')) {
                        qp.openLocationSettings();
                      } else {
                        qp.openAppSettings();
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark
                          ? const Color(0xFF818CF8)
                          : const Color(0xFF4F46E5),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.settings, size: 18),
                    label: const Text(
                      'Open Settings',
                      style: TextStyle(fontWeight: FontWeight.w700),
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

  Widget _buildContent(bool isDark, QiblaProvider qp) {
    return RefreshIndicator.adaptive(
      onRefresh: _onRefresh,
      edgeOffset: 4,
      color: const Color(0xFF4F46E5),
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 8),

              // Summary hero banner
              QiblaHeroBanner(
                qiblaData: qp.qiblaData,
                cityName: qp.cityName,
                isAligned: qp.isAligned,
              ),

              // Calibration alert
              if (qp.compassStatus == CompassStatus.approximate) ...[
                const SizedBox(height: 16),
                const CalibrationAlert(),
              ],

              const SizedBox(height: 32),

              // Compass dial
              CompassDial(
                heading: qp.heading,
                bearing: qp.qiblaData?.direction,
                status: qp.compassStatus,
                isAligned: qp.isAligned,
                guidanceText: qp.guidanceText,
              ),

              const SizedBox(height: 24),

              // Detail info grid
              QiblaInfoGrid(
                qiblaData: qp.qiblaData,
                cityName: qp.cityName,
                isRefreshing: qp.isLoading,
                onRefreshLocation: () =>
                    qp.refresh(forceRefreshLocation: true),
              ),

              const SizedBox(height: 20),

              // Disclaimer
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Direction is calculated using the great-circle bearing to the '
                  'Kaaba (21.4225°N, 39.8262°E). Accuracy depends on your '
                  "device's magnetometer calibration and location precision.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.5,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ]),
          ),
        ],
      ),
    );
  }
}
