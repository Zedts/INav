import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart' hide Path;
import '../../core/models/mosque_model.dart';
import '../../core/theme/app_colors.dart';

class MapViewSection extends StatefulWidget {
  final List<MosqueModel> mosques;
  final MosqueModel? selectedMosque;
  final LatLng? userLatLng;
  final bool isExpanded;
  final VoidCallback onToggleExpand;
  final MosqueModel? featuredMosque;
  final bool isOverridden;
  final VoidCallback? onResetToNearest;
  final ValueChanged<MosqueModel>? onMosqueTap;
  final double compactHeight;

  const MapViewSection({
    super.key,
    required this.mosques,
    this.selectedMosque,
    this.userLatLng,
    required this.isExpanded,
    required this.onToggleExpand,
    this.featuredMosque,
    this.isOverridden = false,
    this.onResetToNearest,
    this.onMosqueTap,
    this.compactHeight = 220.0,
  });

  @override
  State<MapViewSection> createState() => _MapViewSectionState();
}

class _MapViewSectionState extends State<MapViewSection>
    with TickerProviderStateMixin {
  late final MapController _mapController;
  late final AnimationController _pulseController;
  bool _didCenter = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final initial = widget.userLatLng;
      if (initial != null) {
        try {
          _mapController.move(initial, 15.0);
          _didCenter = true;
        } catch (_) {}
      }
    });
  }

  @override
  void didUpdateWidget(covariant MapViewSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userLatLng != widget.userLatLng && !_didCenter) {
      final initial = widget.userLatLng;
      if (initial != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          try {
            _mapController.move(initial, 15.0);
            _didCenter = true;
          } catch (_) {}
        });
      }
    }
    if (oldWidget.isExpanded != widget.isExpanded && widget.isExpanded) {
      final center = widget.userLatLng ??
          (widget.selectedMosque != null
              ? LatLng(
                  widget.selectedMosque!.latitude,
                  widget.selectedMosque!.longitude,
                )
              : null);
      if (center != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          try {
            _mapController.move(center, 16.0);
          } catch (_) {}
        });
      }
    }
    if (oldWidget.selectedMosque != widget.selectedMosque &&
        widget.selectedMosque != null) {
      final m = widget.selectedMosque!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        try {
          _mapController.move(LatLng(m.latitude, m.longitude), 16.0);
        } catch (_) {}
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final initial =
        widget.userLatLng ??
        (widget.selectedMosque != null
            ? LatLng(
                widget.selectedMosque!.latitude,
                widget.selectedMosque!.longitude,
              )
            : const LatLng(-6.2088, 106.8456));
    return SizedBox(
      height: widget.isExpanded ? double.infinity : widget.compactHeight,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: initial,
                initialZoom: 15.0,
                minZoom: 2.0,
                maxZoom: 19.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                  scrollWheelVelocity: 0.005,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.inav.app',
                  tileProvider: NetworkTileProvider(),
                  additionalOptions: const {},
                  maxZoom: 19,
                ),
                MarkerLayer(markers: _buildMarkers()),
              ],
            ),
            Positioned(
              left: 12,
              bottom: 12,
              child: _buildAttributionBadge(),
            ),
            if (!widget.isExpanded)
              Positioned(
                right: 12,
                bottom: 12,
                child: _pillIconButton(
                  icon: Icons.fullscreen,
                  onTap: widget.onToggleExpand,
                  semanticLabel: 'Expand map',
                ),
              )
            else
              Positioned(
                right: 16,
                bottom: 34,
                child: _pillIconButton(
                  icon: Icons.fullscreen_exit,
                  onTap: widget.onToggleExpand,
                  size: 42,
                  semanticLabel: 'Collapse map',
                ),
              ),
            if (widget.isExpanded && widget.featuredMosque != null)
              Positioned(
                top: 12,
                left: 12,
                right: 12,
                child: _buildExpandedInfoCard(widget.featuredMosque!),
              ),
          ],
        ),
      ),
    );
  }

  List<Marker> _buildMarkers() {
    final markers = <Marker>[];

    final user = widget.userLatLng;
    if (user != null) {
      markers.add(
        Marker(
          width: 80,
          height: 80,
          point: user,
          alignment: Alignment.center,
          child: _UserLocationMarker(controller: _pulseController),
        ),
      );
    }

    for (final m in widget.mosques) {
      final isSelected = widget.selectedMosque?.id == m.id;
      final isHighlight = widget.featuredMosque?.id == m.id;
      markers.add(
        Marker(
          width: 38,
          height: 46,
          point: m.latLng,
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () => widget.onMosqueTap?.call(m),
            child: _MosquePinMarker(
              isSelected: isSelected || isHighlight,
            ),
          ),
        ),
      );
    }

    return markers;
  }

  Widget _buildAttributionBadge() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color:
            isDark
                ? AppColors.cardDark
                : AppColors.cardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.hairlineDark : AppColors.hairlineLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        '© OpenStreetMap',
        style: GoogleFonts.plusJakartaSans().copyWith(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color:
              isDark
                  ? AppColors.textMutedDark
                  : AppColors.textMutedLight,
        ),
      ),
    );
  }

  Widget _pillIconButton({
    required IconData icon,
    required VoidCallback onTap,
    required String semanticLabel,
    double size = 40,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color:
                isDark
                    ? AppColors.cardDark
                    : AppColors.cardLight,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color:
                  isDark
                      ? AppColors.hairlineDark
                      : AppColors.hairlineLight,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Container(
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: size * 0.45,
              color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedInfoCard(MosqueModel m) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            color:
                isDark
                    ? AppColors.cardDark
                    : AppColors.cardLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  isDark
                      ? AppColors.hairlineDark
                      : AppColors.hairlineLight,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Container(
            padding: EdgeInsets.fromLTRB(
              12,
              12,
              widget.isOverridden && widget.onResetToNearest != null ? 44 : 12,
              12,
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: widget.isOverridden
                        ? AppColors.roseAccent.withValues(alpha: isDark ? 0.18 : 0.12)
                        : AppColors.primary.withValues(alpha: isDark ? 0.18 : 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    widget.isOverridden
                        ? Icons.push_pin_outlined
                        : Icons.mosque,
                    color: widget.isOverridden
                        ? AppColors.roseAccent
                        : AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.isOverridden ? 'SELECTED MOSQUE' : 'NEAREST TO YOU',
                        style: GoogleFonts.plusJakartaSans().copyWith(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: widget.isOverridden
                              ? AppColors.roseAccent
                              : (isDark
                                  ? AppColors.primaryDark
                                  : AppColors.primary),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        m.name,
                        style: GoogleFonts.plusJakartaSans().copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color:
                              isDark ? AppColors.textMainDark : AppColors.textMainLight,
                          overflow: TextOverflow.ellipsis,
                        ),
                        maxLines: 1,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${m.formattedDistance} · ${m.estimatedWalkingTime} walk',
                        style: GoogleFonts.plusJakartaSans().copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color:
                              isDark
                                  ? AppColors.textMutedDark
                                  : AppColors.textMutedLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (widget.isOverridden && widget.onResetToNearest != null)
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: widget.onResetToNearest,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.cardDark
                      : AppColors.cardLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? AppColors.hairlineDark
                        : AppColors.hairlineLight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.replay,
                  size: 15,
                  color: isDark
                      ? AppColors.primaryDark
                      : AppColors.primary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _UserLocationMarker extends StatelessWidget {
  final AnimationController controller;

  const _UserLocationMarker({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final t = controller.value;
        final outerScale = 1.0 + t * 1.4;
        final outerOpacity = (1.0 - t).clamp(0.0, 1.0);
        return Stack(
          alignment: Alignment.center,
          children: [
            Opacity(
              opacity: outerOpacity * 0.35,
              child: Transform.scale(
                scale: outerScale,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            Opacity(
              opacity: 0.55,
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MosquePinMarker extends StatelessWidget {
  final bool isSelected;

  const _MosquePinMarker({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final accent =
        isSelected ? AppColors.roseAccent : AppColors.primary;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.95),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: const Icon(
            Icons.mosque,
            size: 15,
            color: Colors.white,
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -1),
          child: CustomPaint(
            size: const Size(6, 8),
            painter: _PinTailPainter(color: accent),
          ),
        ),
      ],
    );
  }
}

class _PinTailPainter extends CustomPainter {
  final Color color;

  _PinTailPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant _PinTailPainter old) => old.color != color;
}
