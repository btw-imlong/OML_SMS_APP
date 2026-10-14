import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_sms/core/storage/language_storage.dart';
import 'package:flutter_sms/core/storage/token_storage.dart';
import 'package:flutter_sms/features/auth/presentation/language_selection_page.dart';
import 'package:flutter_sms/features/auth/presentation/login_page.dart';
import 'package:flutter_sms/navigation/main_navigation.dart';
import 'package:flutter_sms/widgets/app_logo.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  static const _blue = AppLogo.blue;

  /// Minimum time the splash stays visible.
  static const _minSplash = Duration(milliseconds: 2200);

  late final AnimationController _intro; // entrance
  late final AnimationController _loop; // drifting circles, ripples, dots

  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _ringFade;
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _lineWidth;

  bool _precached = false;

  @override
  void initState() {
    super.initState();

    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );
    _loop = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );

    Animation<double> interval(double a, double b, Curve c) =>
        CurvedAnimation(parent: _intro, curve: Interval(a, b, curve: c));

    _logoFade = interval(0.0, 0.4, Curves.easeOut);
    _logoScale = Tween<double>(begin: 0.85, end: 1.0)
        .animate(interval(0.0, 0.65, Curves.easeOutBack));
    _ringFade = interval(0.15, 0.6, Curves.easeOut);
    _textFade = interval(0.5, 1.0, Curves.easeOut);
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(interval(0.5, 1.0, Curves.easeOutCubic));
    _lineWidth = interval(0.6, 1.0, Curves.easeOutCubic);

    _bootstrap();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_precached) return;
    _precached = true;

    // Load the logo first so it never pops in late, then start animating.
    precacheImage(const AssetImage(AppLogo.assetPath), context)
        .catchError((_) {})
        .whenComplete(() {
      if (!mounted) return;
      _intro.forward();
      _loop.repeat();
    });
  }

  @override
  void dispose() {
    _intro.dispose();
    _loop.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Startup logic
  // ---------------------------------------------------------------------------

  Future<void> _bootstrap() async {
    final destinationFuture = _resolveStartPage();
    await Future.delayed(_minSplash);
    final destination = await destinationFuture;

    if (!mounted) return;
    _goTo(destination);
  }

  /// Token saved          -> Home
  /// Language chosen only -> Login
  /// First launch         -> Language selection
  Future<Widget> _resolveStartPage() async {
    try {
      final token = await TokenStorage().getToken();
      if (token != null && token.isNotEmpty) {
        return const MainNavigation();
      }
      final hasLanguage = await LanguageStorage().hasChosenLanguage();
      return hasLanguage ? const LoginPage() : const LanguageSelectionPage();
    } catch (_) {
      return const LanguageSelectionPage();
    }
  }

  void _goTo(Widget page) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, _, _) => page,
        transitionsBuilder: (_, animation, _, child) => FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubic,
          ),
          child: child,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Floating decorative circles
          Positioned.fill(
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _loop,
                builder: (context, _) {
                  final t = _loop.value * 2 * math.pi;
                  return Stack(
                    children: [
                      _deco(t, top: -120, right: -90, size: 310, alpha: 0.07),
                      _deco(t, top: 130, left: -55, size: 110, ring: true, phase: 1.2),
                      _deco(t, top: 90, right: 38, size: 18, alpha: 0.18, phase: 2.0),
                      _deco(t, top: 260, right: 70, size: 46, ring: true, phase: 0.6),
                      _deco(t, bottom: 170, left: 46, size: 24, alpha: 0.14, phase: 3.1),
                      _deco(t, bottom: -130, right: -70, size: 300, alpha: 0.06, phase: 2.4),
                      _deco(t, bottom: 110, right: 60, size: 90, ring: true, phase: 4.0),
                      _deco(t, bottom: 60, left: -40, size: 130, alpha: 0.08, phase: 1.8),
                    ],
                  );
                },
              ),
            ),
          ),

          SafeArea(
            child: SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  const Spacer(flex: 5),

                  // Logo with circles around it
                  SizedBox(
                    width: 300,
                    height: 300,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Soft ripples
                        RepaintBoundary(
                          child: AnimatedBuilder(
                            animation: _loop,
                            builder: (context, _) => Stack(
                              alignment: Alignment.center,
                              children: [
                                _ripple(0.0),
                                _ripple(0.5),
                              ],
                            ),
                          ),
                        ),

                        // Static thin ring
                        FadeTransition(
                          opacity: _ringFade,
                          child: Container(
                            width: 236,
                            height: 236,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _blue.withValues(alpha: 0.14),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),

                        // White circle holding the logo
                        FadeTransition(
                          opacity: _logoFade,
                          child: ScaleTransition(
                            scale: _logoScale,
                            child: Container(
                              width: 196,
                              height: 196,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: _blue.withValues(alpha: 0.16),
                                    blurRadius: 40,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 14),
                                  ),
                                ],
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(22),
                                child: AppLogo(size: 152),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Tagline
                  FadeTransition(
                    opacity: _textFade,
                    child: SlideTransition(
                      position: _textSlide,
                      child: const Text(
                        'Staff Mission System',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.8,
                          color: _blue,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  AnimatedBuilder(
                    animation: _lineWidth,
                    builder: (context, _) => Container(
                      width: 34 * _lineWidth.value,
                      height: 2.5,
                      decoration: BoxDecoration(
                        color: _blue.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  const Spacer(flex: 4),

                  // Loading dots
                  FadeTransition(
                    opacity: _textFade,
                    child: AnimatedBuilder(
                      animation: _loop,
                      builder: (context, _) => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(3, (i) {
                          final v = (_loop.value * 3 + i * 0.18) % 1.0;
                          final a = 0.25 + 0.75 * (1 - (v - 0.5).abs() * 2);
                          return Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _blue.withValues(alpha: a.clamp(0.0, 1.0)),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),

                  const SizedBox(height: 56),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// One expanding, fading ripple around the logo.
  Widget _ripple(double phase) {
    final v = (_loop.value * 3 + phase) % 1.0;
    final scale = 0.9 + v * 0.42;
    final opacity = (1.0 - v) * 0.20;
    return Opacity(
      opacity: opacity.clamp(0.0, 1.0),
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: 236,
          height: 236,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: _blue, width: 1.5),
          ),
        ),
      ),
    );
  }

  /// A decorative circle (filled or ring) that drifts slowly.
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
    final dx = math.sin(t + phase) * 8;
    final dy = math.cos(t + phase) * 8;
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Transform.translate(
        offset: Offset(dx, dy),
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
