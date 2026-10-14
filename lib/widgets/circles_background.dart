import 'dart:math' as math;

import 'package:flutter/material.dart';

/// White background with soft circles that drift slowly.
/// Wrap any page body with this to match the splash screen.
class CirclesBackground extends StatefulWidget {
  const CirclesBackground({super.key, required this.child});

  final Widget child;

  @override
  State<CirclesBackground> createState() => _CirclesBackgroundState();
}

class _CirclesBackgroundState extends State<CirclesBackground>
    with SingleTickerProviderStateMixin {
  static const _blue = Color(0xFF1B4587);

  late final AnimationController _loop;

  @override
  void initState() {
    super.initState();
    _loop = AnimationController(vsync: this, duration: const Duration(seconds: 8))
      ..repeat();
  }

  @override
  void dispose() {
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: ColoredBox(color: Colors.white)),
        Positioned.fill(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _loop,
              builder: (context, _) {
                final t = _loop.value * 2 * math.pi;
                return Stack(
                  children: [
                    _deco(t, top: -120, right: -90, size: 300, alpha: 0.07),
                    _deco(t, top: 150, left: -55, size: 100, ring: true, phase: 1.2),
                    _deco(t, top: 90, right: 38, size: 16, alpha: 0.18, phase: 2.0),
                    _deco(t, bottom: 190, left: 36, size: 22, alpha: 0.14, phase: 3.1),
                    _deco(t, bottom: -130, right: -70, size: 290, alpha: 0.06, phase: 2.4),
                    _deco(t, bottom: 120, right: 50, size: 80, ring: true, phase: 4.0),
                    _deco(t, bottom: 50, left: -40, size: 120, alpha: 0.08, phase: 1.8),
                  ],
                );
              },
            ),
          ),
        ),
        widget.child,
      ],
    );
  }

  Widget _deco(
    double t, {
    double? top,
    double? left,
    double? right,
    double? bottom,
    required double size,
    bool ring = false,
    double alpha = 0.08,
    double phase = 0,
  }) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Transform.translate(
        offset: Offset(math.sin(t + phase) * 8, math.cos(t + phase) * 8),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ring ? null : _blue.withValues(alpha: alpha),
            border: ring
                ? Border.all(color: _blue.withValues(alpha: 0.16), width: 2)
                : null,
          ),
        ),
      ),
    );
  }
}
