import 'package:flutter/material.dart';

import 'login_page.dart';
import 'widgets/auth_widgets.dart';

class LanguageSelectionPage extends StatefulWidget {
  const LanguageSelectionPage({super.key});

  @override
  State<LanguageSelectionPage> createState() => _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends State<LanguageSelectionPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _titleA;
  late final Animation<double> _khA;
  late final Animation<double> _enA;
  late final Animation<double> _btnA;

  String _selected = 'en';

  Animation<double> _interval(double start, double end) => CurvedAnimation(
        parent: _c,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      );

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );
    _titleA = _interval(0.0, 0.45);
    _khA = _interval(0.2, 0.65);
    _enA = _interval(0.35, 0.8);
    _btnA = _interval(0.55, 1.0);

    // Wait for the logo to finish flying in from the splash screen.
    Future.delayed(const Duration(milliseconds: 450), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Widget _reveal(Animation<double> a, Widget child) {
    return FadeTransition(
      opacity: a,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(a),
        child: child,
      ),
    );
  }

  void _start() {
    // TODO: save the selected language (_selected) here.
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 550),
        pageBuilder: (context, animation, secondary) => const LoginPage(),
        transitionsBuilder: (context, animation, secondary, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.08, 0),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          const Positioned.fill(child: AuthBackground()),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: LayoutBuilder(
                  builder: (context, constraints) => SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 56),
                            const Center(
                              child: Hero(
                                tag: 'auth_logo',
                                child: AuthLogo(size: 84),
                              ),
                            ),
                            const SizedBox(height: 22),
                            _reveal(
                              _titleA,
                              const Column(
                                children: [
                                  Text(
                                    'WELCOME To',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: AuthColors.textGrey,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'One More',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: AuthColors.blue,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Choose your language',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: AuthColors.textGrey,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            _reveal(
                              _khA,
                              _LanguageTile(
                                flag: '\u{1F1F0}\u{1F1ED}',
                                name:
                                    '\u1797\u17B6\u179F\u17B6\u1781\u17D2\u1798\u17C2\u179A',
                                selected: _selected == 'km',
                                onTap: () =>
                                    setState(() => _selected = 'km'),
                              ),
                            ),
                            const SizedBox(height: 12),
                            _reveal(
                              _enA,
                              _LanguageTile(
                                flag: '\u{1F1EC}\u{1F1E7}',
                                name: 'English',
                                selected: _selected == 'en',
                                onTap: () =>
                                    setState(() => _selected = 'en'),
                              ),
                            ),
                            const SizedBox(height: 28),
                            _reveal(
                              _btnA,
                              AuthButton(
                                label: 'Get Start',
                                trailingIcon: Icons.arrow_forward,
                                onPressed: _start,
                              ),
                            ),
                            const SizedBox(height: 36),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.flag,
    required this.name,
    required this.selected,
    required this.onTap,
  });

  final String flag;
  final String name;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: selected ? 1.02 : 1.0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutBack,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFEAF1FF) : const Color(0xFFF7F8FA),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AuthColors.blue : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AuthColors.blue.withValues(alpha: selected ? 0.16 : 0),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Text(flag, style: const TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: AuthColors.textDark,
                  ),
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: selected
                    ? const Icon(Icons.check_circle,
                        key: ValueKey('on'), size: 22, color: AuthColors.blue)
                    : const Icon(Icons.radio_button_unchecked,
                        key: ValueKey('off'),
                        size: 22,
                        color: AuthColors.textGrey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
