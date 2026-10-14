import 'package:flutter/material.dart';
import 'package:flutter_sms/features/auth/presentation/login_page.dart';
import 'package:flutter_sms/features/auth/presentation/password_reset_success_page.dart';
import 'package:flutter_sms/features/auth/presentation/widgets/auth_widgets.dart';

class CreateNewPasswordPage extends StatefulWidget {
  const CreateNewPasswordPage({super.key});

  @override
  State<CreateNewPasswordPage> createState() => _CreateNewPasswordPageState();
}

class _CreateNewPasswordPageState extends State<CreateNewPasswordPage>
    with SingleTickerProviderStateMixin {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  late final AnimationController _c;
  late final Animation<double> _aTitle;
  late final Animation<double> _aPassword;
  late final Animation<double> _aReqs;
  late final Animation<double> _aConfirm;
  late final Animation<double> _aButton;
  late final Animation<double> _aLink;

  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasNumber = false;
  bool _hasSpecial = false;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );
    _aTitle = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.0, 0.35, curve: Curves.easeOutCubic),
    );
    _aPassword = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.12, 0.5, curve: Curves.easeOutCubic),
    );
    _aReqs = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.25, 0.65, curve: Curves.easeOutCubic),
    );
    _aConfirm = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.4, 0.8, curve: Curves.easeOutCubic),
    );
    _aButton = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.55, 0.9, curve: Curves.easeOutCubic),
    );
    _aLink = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.65, 1.0, curve: Curves.easeOutCubic),
    );

    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) _c.forward();
    });

    _passwordController.addListener(_validatePassword);
  }

  void _validatePassword() {
    final p = _passwordController.text;
    setState(() {
      _hasMinLength = p.length >= 8;
      _hasUppercase = p.contains(RegExp(r'[A-Z]'));
      _hasNumber = p.contains(RegExp(r'[0-9]'));
      _hasSpecial = p.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\;/`~]'));
    });
  }

  @override
  void dispose() {
    _c.dispose();
    _passwordController.removeListener(_validatePassword);
    _passwordController.dispose();
    _confirmController.dispose();
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

  bool get _allReqsMet =>
      _hasMinLength && _hasUppercase && _hasNumber && _hasSpecial;

  void _onReset() {
    final pass = _passwordController.text;
    final confirm = _confirmController.text;

    if (!_allReqsMet) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password does not meet all requirements'),
        ),
      );
      return;
    }
    if (pass != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }
    // TODO: call reset-password API
    Navigator.of(context).push(
      authRoute(const PasswordResetSuccessPage()),
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
                                      'Create New Password',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                        color: AuthColors.textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Your new password must be different from previous passwords and meet the requirements below.',
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
                                _aPassword,
                                AuthPasswordField(
                                  label: 'New Password',
                                  controller: _passwordController,
                                  onChanged: (_) {},
                                ),
                              ),
                              const SizedBox(height: 16),
                              _reveal(
                                _aReqs,
                                _RequirementsBlock(
                                  hasMinLength: _hasMinLength,
                                  hasUppercase: _hasUppercase,
                                  hasNumber: _hasNumber,
                                  hasSpecial: _hasSpecial,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _reveal(
                                _aConfirm,
                                AuthPasswordField(
                                  label: 'Confirm Password',
                                  controller: _confirmController,
                                  onChanged: (_) {},
                                ),
                              ),
                              const SizedBox(height: 22),
                              _reveal(
                                _aButton,
                                AuthButton(
                                  label: 'Reset Password',
                                  onPressed: _onReset,
                                  trailingIcon: Icons.lock_reset_rounded,
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

class _RequirementsBlock extends StatelessWidget {
  const _RequirementsBlock({
    required this.hasMinLength,
    required this.hasUppercase,
    required this.hasNumber,
    required this.hasSpecial,
  });

  final bool hasMinLength;
  final bool hasUppercase;
  final bool hasNumber;
  final bool hasSpecial;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AuthColors.fieldBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AuthColors.border),
      ),
      child: Column(
        children: [
          _ReqRow(label: 'At least 8 characters', met: hasMinLength),
          const SizedBox(height: 10),
          _ReqRow(label: 'One uppercase letter', met: hasUppercase),
          const SizedBox(height: 10),
          _ReqRow(label: 'One number', met: hasNumber),
          const SizedBox(height: 10),
          _ReqRow(label: 'One special character', met: hasSpecial),
        ],
      ),
    );
  }
}

class _ReqRow extends StatelessWidget {
  const _ReqRow({required this.label, required this.met});

  final String label;
  final bool met;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          transitionBuilder: (child, anim) {
            return ScaleTransition(scale: anim, child: child);
          },
          child: met
              ? Icon(
                  Icons.check_circle_rounded,
                  key: const ValueKey('check'),
                  size: 20,
                  color: AuthColors.green,
                )
              : Icon(
                  Icons.circle_outlined,
                  key: const ValueKey('circle'),
                  size: 20,
                  color: AuthColors.textGrey.withValues(alpha: 0.55),
                ),
        ),
        const SizedBox(width: 10),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 280),
          style: TextStyle(
            fontSize: 13,
            fontWeight: met ? FontWeight.w600 : FontWeight.w400,
            color: met ? AuthColors.textDark : AuthColors.textGrey,
          ),
          child: Text(label),
        ),
      ],
    );
  }
}
