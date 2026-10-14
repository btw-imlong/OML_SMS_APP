import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sms/core/storage/language_storage.dart';
import 'package:flutter_sms/features/auth/presentation/login_page.dart';
import 'package:flutter_sms/widgets/app_logo.dart';
import 'package:flutter_sms/widgets/circles_background.dart';

class LanguageSelectionPage extends StatefulWidget {
  const LanguageSelectionPage({super.key});

  @override
  State<LanguageSelectionPage> createState() => _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends State<LanguageSelectionPage>
    with TickerProviderStateMixin {
  static const _blue = AppLogo.blue;
  static const _ink = Color(0xFF1A1A1A);
  static const _cardH = 78.0;
  static const _gap = 14.0;

  String selectedLanguage = 'English';
  bool _saving = false;

  late final AnimationController _enter;
  late final AnimationController _float;
  late final Animation<double> _floatAnim;
  late final List<Animation<double>> _steps;

  @override
  void initState() {
    super.initState();

    // Staggered entrance: logo, title, options, button
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _steps = List.generate(4, (i) {
      final start = i * 0.14;
      return CurvedAnimation(
        parent: _enter,
        curve: Interval(start, start + 0.5, curve: Curves.easeOutCubic),
      );
    });
    _enter.forward();

    // Gentle floating logo
    _float = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);
    _floatAnim = CurvedAnimation(parent: _float, curve: Curves.easeInOut);

    // Pre-select the language saved earlier (e.g. coming back from login)
    LanguageStorage().getLanguage().then((saved) {
      if (!mounted) return;
      if (saved == 'Khmer' || saved == 'English') {
        setState(() => selectedLanguage = saved!);
      }
    });
  }

  @override
  void dispose() {
    _enter.dispose();
    _float.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (_saving) return;
    setState(() => _saving = true);

    await LanguageStorage().saveLanguage(selectedLanguage);
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, _, _) => const LoginPage(),
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

  Widget _reveal(int i, Widget child) {
    return FadeTransition(
      opacity: _steps[i],
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.14),
          end: Offset.zero,
        ).animate(_steps[i]),
        child: child,
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
      body: CirclesBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26),
            child: Column(
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) => SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(minHeight: constraints.maxHeight),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Floating logo in a white circle with a ring
                              _reveal(
                                0,
                                AnimatedBuilder(
                                  animation: _floatAnim,
                                  builder: (context, child) =>
                                      Transform.translate(
                                    offset: Offset(0, -7 * _floatAnim.value),
                                    child: child,
                                  ),
                                  child: Container(
                                    width: 164,
                                    height: 164,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: _blue.withValues(alpha: 0.14),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Center(
                                      child: Container(
                                        width: 140,
                                        height: 140,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  _blue.withValues(alpha: 0.16),
                                              blurRadius: 30,
                                              offset: const Offset(0, 10),
                                            ),
                                          ],
                                        ),
                                        child: const Padding(
                                          padding: EdgeInsets.all(16),
                                          child: AppLogo(size: 108),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 30),

                              _reveal(
                                1,
                                const Column(
                                  children: [
                                    Text(
                                      'Welcome to One More',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w800,
                                        color: _ink,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Choose your language to continue',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14.5,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 32),

                              _reveal(2, _options()),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Get Start button
                _reveal(
                  3,
                  Column(
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: _blue.withValues(alpha: 0.30),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _saving ? null : _continue,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _blue,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: _blue,
                              disabledForegroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Get Start',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward_rounded, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Two cards with one blue highlight that slides between them.
  Widget _options() {
    final isKhmer = selectedLanguage == 'Khmer';

    return SizedBox(
      height: _cardH * 2 + _gap,
      child: Stack(
        children: [
          // Static cards behind
          _slot(0, _baseCard()),
          _slot(1, _baseCard()),

          // Sliding highlight
          AnimatedPositioned(
            duration: const Duration(milliseconds: 380),
            curve: Curves.easeOutCubic,
            top: isKhmer ? 0 : _cardH + _gap,
            left: 0,
            right: 0,
            height: _cardH,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2A5CAB), _blue],
                ),
                boxShadow: [
                  BoxShadow(
                    color: _blue.withValues(alpha: 0.30),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
            ),
          ),

          // Content on top
          // Khmer = \u1781\u17D2\u1798\u17C2\u179A
          _slot(
            0,
            _option(
              value: 'Khmer',
              title: '\u1781\u17D2\u1798\u17C2\u179A',
              subtitle: 'Khmer',
              badge: '\u1781',
            ),
          ),
          _slot(
            1,
            _option(
              value: 'English',
              title: 'English',
              subtitle: 'English',
              badge: 'En',
            ),
          ),
        ],
      ),
    );
  }

  Widget _slot(int index, Widget child) {
    return Positioned(
      top: index * (_cardH + _gap),
      left: 0,
      right: 0,
      height: _cardH,
      child: child,
    );
  }

  Widget _baseCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6FA),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _blue.withValues(alpha: 0.08)),
      ),
    );
  }

  Widget _option({
    required String value,
    required String title,
    required String subtitle,
    required String badge,
  }) {
    final selected = selectedLanguage == value;
    const d = Duration(milliseconds: 300);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (selected) return;
        HapticFeedback.selectionClick();
        setState(() => selectedLanguage = value);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            // Badge
            AnimatedContainer(
              duration: d,
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                  color: selected
                      ? Colors.white
                      : _blue.withValues(alpha: 0.15),
                ),
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _blue,
                ),
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedDefaultTextStyle(
                    duration: d,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : _ink,
                    ),
                    child: Text(title),
                  ),
                  const SizedBox(height: 2),
                  AnimatedDefaultTextStyle(
                    duration: d,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: selected ? Colors.white70 : Colors.grey.shade600,
                    ),
                    child: Text(subtitle),
                  ),
                ],
              ),
            ),

            // Check
            AnimatedContainer(
              duration: d,
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? Colors.white : Colors.transparent,
                border: Border.all(
                  color: selected ? Colors.white : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: AnimatedScale(
                scale: selected ? 1 : 0,
                duration: d,
                curve: Curves.easeOutBack,
                child: const Icon(Icons.check_rounded, size: 17, color: _blue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
