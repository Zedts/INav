import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../core/services/installed_apps_service.dart';
import '../../core/theme/app_colors.dart';

/// Lazy launcher-icon loader. Same path as Add Apps: PNG from
/// [InstalledAppsService.getAppIcon], Material glyph only if native fails.
///
/// ponytail: process-lifetime in-memory cache (locked lists are tiny;
/// upgrade to LRU/disk if this map ever grows past a few hundred packages).
class AsyncAppIcon extends StatefulWidget {
  final String packageName;
  final String? activityName;
  final Color fallbackColor;
  final IconData fallbackIcon;
  final bool isDark;
  final double size;

  /// Optional override; defaults to the shared process cache.
  final Map<String, Uint8List>? cache;

  static final Map<String, Uint8List> sharedCache = <String, Uint8List>{};

  const AsyncAppIcon({
    super.key,
    required this.packageName,
    this.activityName,
    required this.fallbackColor,
    required this.fallbackIcon,
    required this.isDark,
    this.size = 48,
    this.cache,
  });

  @override
  State<AsyncAppIcon> createState() => _AsyncAppIconState();
}

class _AsyncAppIconState extends State<AsyncAppIcon> {
  Uint8List? _bytes;
  bool _failed = false;

  Map<String, Uint8List> get _cache =>
      widget.cache ?? AsyncAppIcon.sharedCache;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(AsyncAppIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.packageName != widget.packageName ||
        oldWidget.activityName != widget.activityName) {
      _load(notify: true);
    }
  }

  void _load({bool notify = false}) {
    final cached = _cache[widget.packageName];
    if (cached != null) {
      _bytes = cached;
      _failed = false;
      if (notify) setState(() {});
      return;
    }
    _bytes = null;
    _failed = false;
    InstalledAppsService.getAppIcon(
      packageName: widget.packageName,
      activityName: widget.activityName,
      sizeDp: widget.size.round().clamp(16, 256),
    ).then((bytes) {
      if (!mounted) return;
      if (bytes == null || bytes.isEmpty) {
        setState(() => _failed = true);
        return;
      }
      _cache[widget.packageName] = bytes;
      setState(() {
        _bytes = bytes;
        _failed = false;
      });
    }).catchError((_) {
      if (!mounted) return;
      setState(() => _failed = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final b = _bytes;
    if (b != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(
          b,
          width: size,
          height: size,
          fit: BoxFit.cover,
          gaplessPlayback: true,
        ),
      );
    }
    return _FallbackIcon(
      size: size,
      color: widget.fallbackColor,
      icon: widget.fallbackIcon,
      isDark: widget.isDark,
      spinner: !_failed,
    );
  }
}

class _FallbackIcon extends StatelessWidget {
  final double size;
  final Color color;
  final IconData icon;
  final bool isDark;
  final bool spinner;

  const _FallbackIcon({
    required this.size,
    required this.color,
    required this.icon,
    required this.isDark,
    this.spinner = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: (isDark ? AppColors.primaryDark : AppColors.primaryLight)
            .withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: spinner
            ? SizedBox(
                width: size * 0.375,
                height: size * 0.375,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDark ? AppColors.primaryDark : AppColors.primaryLight,
                  ),
                ),
              )
            : Icon(
                icon,
                color: color.computeLuminance() < 0.5
                    ? AppColors.primaryDark
                    : color,
                size: size * 0.5,
              ),
      ),
    );
  }
}
