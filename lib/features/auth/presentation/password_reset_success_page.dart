import 'package:flutter/material.dart';
import 'package:flutter_sms/features/auth/presentation/login_page.dart';
import 'package:flutter_sms/features/auth/presentation/widgets/auth_widgets.dart';

class PasswordResetSuccessPage extends StatefulWidget {
  const PasswordResetSuccessPage({super.key});

  @override
  State<PasswordResetSuccessPage> createState() =>
      _PasswordResetSuccessPageState();
}

class _PasswordResetSuccessPageState extends State<PasswordResetSuccessPage>
    with TickerProviderStateMixin {
  late final AnimationController _c;
  late final AnimationController _iconC;
  late final Animation<double> _aIcon;
  late final Animation<double> _aRing;
  late final Animation<double> _aCheck;
  late final Animation<double> _aTitle;
  late final Animation<double> _aMessage;
  late final Animation<double> _aAlert;
  late final Animation<double> _aButton;
  late final Animation<double> _aSupport;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );
    _iconC = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _aIcon = CurvedAnimation(
      parent: _iconC,
      curve: const Interval(0.0, 0.55, curve: Curves.elasticOut),
    );
    _aRing = CurvedAnimation(
      parent: _iconC,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
    );
    _aCheck = CurvedAnimation(
      parent: _iconC,
      curve: const Interval(0.4, 0.85, curve: Curves.easeOutBack),
    );

    _aTitle = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.15, 0.5, curve: Curves.easeOutCubic),
    );
    _aMessage = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.3, 0.65, curve: Curves.easeOutCubic),
    );
    _aAlert = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.45, 0.8, curve: Curves.easeOutCubic),
    );
    _aButton = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.6, 0.95, curve: Curves.easeOutCubic),
    );
    _aSupport = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.7, 1.0, curve: Curves.easeOutCubic),
    );

    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) {
        _iconC.forward();
        _c.forward();
      }
    });
  }

  @override
  void dispose() {
    _c.dispose();
    _iconC.dispose();
    super.dispose();
  }

  Widget _reveal(Animation<double> a, Widget child) {
    return FadeTransition(
      opacity: a,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.25),
          end: Offset.zero,
        ).animate(a),
        child: child,
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
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 48),
                              // Success icon with ring + elastic scale
                              Center(
                                child: SizedBox(
                                  width: 120,
                                  height: 120,
                                  child: AnimatedBuilder(
                                    animation: _iconC,
                                    builder: (context, child) {
                                      return Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          // Expanding soft ring
                                          Opacity(
                                            opacity: (1.0 - _aRing.value)
                                                .clamp(0.0, 1.0),
                                            child: Transform.scale(
                                              scale: 0.6 + (_aRing.value * 0.9),
                                              child: Container(
                                                width: 110,
                                                height: 110,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: AuthColors.green
                                                        .withValues(
                                                            alpha: 0.35),
                                                    width: 3,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          // Main circle
                                          ScaleTransition(
                                            scale: _aIcon,
                                            child: Container(
                                              width: 88,
                                              height: 88,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: AuthColors.green
                                                    .withValues(alpha: 0.12),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: AuthColors.green
                                                        .withValues(
                                                            alpha: 0.25),
                                                    blurRadius: 24,
                                                    spreadRadius: 2,
                                                  ),
                                                ],
                                              ),
                                              child: Center(
                                                child: FadeTransition(
                                                  opacity: _aCheck,
                                                  child: ScaleTransition(
                                                    scale: _aCheck,
                                                    child: Icon(
                                                      Icons.check_rounded,
                                                      size: 48,
                                                      color: AuthColors.green,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                              _reveal(
                                _aTitle,
                                Text(
                                  'Password Reset!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: AuthColors.textDark,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              _reveal(
                                _aMessage,
                                Text(
                                  'Your password has been successfully updated. You can now sign in with your new password.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    height: 1.5,
                                    color: AuthColors.textGrey,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 28),
                              _reveal(
                                _aAlert,
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AuthColors.blue
                                        .withValues(alpha: 0.06),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: AuthColors.blue
                                          .withValues(alpha: 0.18),
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.shield_outlined,
                                        size: 22,
                                        color: AuthColors.blue,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Security Alert',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: AuthColors.textDark,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'If you did not request this change, please contact support immediately to secure your account.',
                                              style: TextStyle(
                                                fontSize: 12.5,
                                                height: 1.45,
                                                color: AuthColors.textGrey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 28),
                              _reveal(
                                _aButton,
                                AuthButton(
                                  label: 'Back to Login',
                                  onPressed: () => backToLogin(context),
                                  trailingIcon: Icons.arrow_forward_rounded,
                                ),
                              ),
                              const SizedBox(height: 20),
                              _reveal(
                                _aSupport,
                                Center(
                                  child: Text(
                                    'Need help? Contact support@example.com',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: AuthColors.textGrey
                                          .withValues(alpha: 0.85),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
