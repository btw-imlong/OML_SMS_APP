import 'package:flutter/material.dart';

/// The app logo, shared by splash, language and login pages.
/// All instances share one [Hero] tag, so the logo glides between pages.
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 150,
    this.glow = false, // kept so existing calls still compile
  });

  static const Color blue = Color(0xFF1B4587);
  static const String assetPath = 'assets/images/one_more_limited_group_logo.jpg';
  static const String heroTag = 'app_logo';

  final double size;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: heroTag,
      child: Material(
        type: MaterialType.transparency,
        child: SizedBox(
          width: size,
          height: size,
          child: Image.asset(
            assetPath,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            errorBuilder: (context, error, stack) {
              debugPrint('AppLogo: failed to load $assetPath -> $error');
              return Center(
                child: Text(
                  'ONE MORE',
                  style: TextStyle(
                    color: blue,
                    fontSize: size * 0.12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
