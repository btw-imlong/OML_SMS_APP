import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sms/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_sms/navigation/main_navigation.dart';

import 'forgot_password_page.dart';
import 'widgets/auth_widgets.dart';

/// Smooth fade + slide route used across the auth flow.
Route<T> authRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 550),
    reverseTransitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (context, animation, secondary) => page,
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
  );
}

/// Clears the auth stack and shows the login page.
void backToLogin(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(
    authRoute(const LoginPage()),
    (route) => false,
  );
}

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  late final AnimationController _c;
  late final Animation<double> _titleA;
  late final Animation<double> _emailA;
  late final Animation<double> _passA;
  late final Animation<double> _btnA;
  late final Animation<double> _linkA;

  Animation<double> _interval(double start, double end) => CurvedAnimation(
        parent: _c,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      );

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _titleA = _interval(0.0, 0.4);
    _emailA = _interval(0.15, 0.55);
    _passA = _interval(0.3, 0.7);
    _btnA = _interval(0.45, 0.85);
    _linkA = _interval(0.6, 1.0);

    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    _emailController.dispose();
    _passwordController.dispose();
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

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await ref.read(authUserProvider.notifier).login(
            email: email,
            password: password,
          );

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (context, animation, secondary) =>
              const MainNavigation(),
          transitionsBuilder: (context, animation, secondary, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 24),
                            const Center(
                              child: Hero(
                                tag: 'auth_logo',
                                child: AuthLogo(size: 110),
                              ),
                            ),
                            const SizedBox(height: 24),
                            _reveal(
                              _titleA,
                              const Column(
                                children: [
                                  Text(
                                    'Welcome Back',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: AuthColors.textDark,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    'Sign in to continue',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AuthColors.textGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 28),
                            _reveal(
                              _emailA,
                              AuthTextField(
                                label: 'Email',
                                hint: 'name@company.com',
                                icon: Icons.mail_outline,
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _reveal(
                              _passA,
                              AuthPasswordField(
                                label: 'Password',
                                controller: _passwordController,
                              ),
                            ),
                            const SizedBox(height: 22),
                            _reveal(
                              _btnA,
                              AuthButton(
                                label: _loading ? 'Signing in...' : 'Login',
                                onPressed: _loading ? null : _login,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _reveal(
                              _linkA,
                              Align(
                                alignment: Alignment.center,
                                child: GestureDetector(
                                  onTap: _loading
                                      ? null
                                      : () => Navigator.of(context).push(
                                            authRoute(
                                              const ForgotPasswordPage(),
                                            ),
                                          ),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                    child: Text(
                                      'Forget Password?',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AuthColors.blue,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
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
