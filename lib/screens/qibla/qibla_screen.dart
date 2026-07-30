import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/providers/qibla_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/common/error_state_view.dart';
import '../../widgets/common/section_skeleton.dart';
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

    if (qp.isLoading) {
      return _buildLoadingView();
    }
    if (qp.errorMessage != null && qp.qiblaData == null) {
      return ErrorStateView(
        message: qp.errorMessage!,
        onRetry: () => qp.refresh(forceRefreshLocation: true),
        onOpenSettings: () {
          if (qp.errorMessage!.toLowerCase().contains('disabled')) {
            qp.openLocationSettings();
          } else {
            qp.openAppSettings();
          }
        },
      );
    }
    return _buildContent(isDark, qp);
  }

  Widget _buildLoadingView() {
    return const ScreenSkeleton(
      children: [
        // Hero banner
        SectionSkeleton(height: 110),
        SizedBox(height: 32),
        // Compass dial
        CircleSkeleton(size: 260),
        SizedBox(height: 12),
        // Accuracy badge
        Center(child: SectionSkeleton(height: 28, width: 150, borderRadius: 20)),
        SizedBox(height: 24),
        // Info grid row
        Row(
          children: [
            Expanded(child: SectionSkeleton(height: 96)),
            SizedBox(width: 14),
            Expanded(child: SectionSkeleton(height: 96)),
          ],
        ),
        SizedBox(height: 14),
        // Location card
        SectionSkeleton(height: 110),
      ],
    );
  }

  Widget _buildContent(bool isDark, QiblaProvider qp) {
    return RefreshIndicator.adaptive(
      onRefresh: _onRefresh,
      edgeOffset: 4,
      color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
      backgroundColor: isDark ? AppColors.cardDark : Colors.white,
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
