import 'dart:async';

import 'package:flutter/material.dart';

import 'language_selection_page.dart';
import 'widgets/auth_widgets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _intro;
  late final AnimationController _pulse;
  late final AnimationController _load;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _textFade;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();
    _load = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..forward();

    _logoScale = Tween<double>(begin: 0.3, end: 1).animate(
      CurvedAnimation(
        parent: _intro,
        curve: const Interval(0, 0.75, curve: Curves.elasticOut),
      ),
    );
    _logoFade = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0, 0.4, curve: Curves.easeOut),
    );
    _textFade = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.6, 1, curve: Curves.easeOut),
    );

    // TODO: check saved token here later and go straight to MainNavigation.
    _timer = Timer(const Duration(milliseconds: 3200), _next);
  }

  void _next() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 900),
        pageBuilder: (_, _, _) => const LanguageSelectionPage(),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _intro.dispose();
    _pulse.dispose();
    _load.dispose();
    super.dispose();
  }

  Widget _dot(double size, double alpha) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AuthColors.blue.withValues(alpha: alpha),
        ),
      );

  Widget _ripple(double p) {
    final size = 150 + p * 210;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AuthColors.blue.withValues(alpha: (1 - p) * 0.16),
        border: Border.all(
          color: AuthColors.blue.withValues(alpha: (1 - p) * 0.22),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFE8F0FF)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(top: -120, right: -90, child: _dot(300, 0.06)),
            Positioned(bottom: -140, left: -100, child: _dot(340, 0.07)),
            Center(
              child: SizedBox(
                width: 360,
                height: 360,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    _dot(190, 0.08),
                    AnimatedBuilder(
                      animation: _pulse,
                      builder: (context, _) => Stack(
                        alignment: Alignment.center,
                        children: [
                          for (var i = 0; i < 3; i++)
                            _ripple((_pulse.value + i / 3) % 1),
                        ],
                      ),
                    ),
                    FadeTransition(
                      opacity: _logoFade,
                      child: ScaleTransition(
                        scale: _logoScale,
                        child: const Hero(tag: 'auth_logo', child: AuthLogo(size: 124)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 64,
              child: FadeTransition(
                opacity: _textFade,
                child: Column(
                  children: [
                    const Text(
                      'Staff Mission System',
                      style: TextStyle(
                        color: AuthColors.blue,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 120,
                      child: AnimatedBuilder(
                        animation: _load,
                        builder: (context, _) => ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: _load.value,
                            minHeight: 4,
                            backgroundColor:
                                AuthColors.blue.withValues(alpha: 0.12),
                            valueColor: const AlwaysStoppedAnimation(
                                AuthColors.blue),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

