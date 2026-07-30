import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Shimmering placeholder shown while a screen's provider is loading.
///
/// Wraps [Bone]-based section placeholders in a [Skeletonizer.zone] so every
/// screen shares the exact same loading look. Used by home, mosque and qibla.
class ScreenSkeleton extends StatelessWidget {
  final List<Widget> children;

  const ScreenSkeleton({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer.zone(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}

/// A rounded skeleton block shaped like one of the screen's cards/sections.
class SectionSkeleton extends StatelessWidget {
  final double height;
  final double? width;
  final double borderRadius;

  const SectionSkeleton({
    super.key,
    required this.height,
    this.width,
    this.borderRadius = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Bone(
      width: width ?? double.infinity,
      height: height,
      borderRadius: BorderRadius.circular(borderRadius),
    );
  }
}

/// A circular skeleton (e.g. the qibla compass dial).
class CircleSkeleton extends StatelessWidget {
  final double size;

  const CircleSkeleton({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Center(child: Bone.circle(size: size));
  }
}
