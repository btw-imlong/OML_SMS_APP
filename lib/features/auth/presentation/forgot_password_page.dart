import 'package:flutter/material.dart';
import 'package:flutter_sms/features/auth/presentation/login_page.dart';
import 'package:flutter_sms/features/auth/presentation/verification_code_page.dart';
import 'package:flutter_sms/features/auth/presentation/widgets/auth_widgets.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  late final AnimationController _c;
  late final Animation<double> _aTitle;
  late final Animation<double> _aField;
  late final Animation<double> _aButton;
  late final Animation<double> _aLink;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _aTitle = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic),
    );
    _aField = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.15, 0.55, curve: Curves.easeOutCubic),
    );
    _aButton = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.35, 0.75, curve: Curves.easeOutCubic),
    );
    _aLink = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.5, 0.9, curve: Curves.easeOutCubic),
    );
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    _emailController.dispose();
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

  void _onSend() {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }
    // TODO: call forgot-password API
    Navigator.of(context).push(
      authRoute(VerificationCodePage(email: email)),
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
                              const SizedBox(height: 32),
                              const Center(
                                child: Hero(
                                  tag: 'auth_logo',
                                  child: AuthLogo(size: 110),
                                ),
                              ),
                              const SizedBox(height: 36),
                              _reveal(
                                _aTitle,
                                Column(
                                  children: [
                                    Text(
                                      'Forgot Password?',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                        color: AuthColors.textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Enter the email associated with your account and we\'ll send you a reset link.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 13,
                                        height: 1.5,
                                        color: AuthColors.textGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 28),
                              _reveal(
                                _aField,
                                AuthTextField(
                                  label: 'Email',
                                  hint: 'you@example.com',
                                  icon: Icons.mail_outline_rounded,
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                ),
                              ),
                              const SizedBox(height: 22),
                              _reveal(
                                _aButton,
                                AuthButton(
                                  label: 'Send Reset Link',
                                  onPressed: _onSend,
                                  trailingIcon: Icons.arrow_forward_rounded,
                                ),
                              ),
                              const SizedBox(height: 20),
                              _reveal(
                                _aLink,
                                Center(
                                  child: AuthLink(
                                    label: 'Back to Login',
                                    onTap: () => backToLogin(context),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
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
