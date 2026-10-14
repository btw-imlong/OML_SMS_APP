import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sms/features/auth/presentation/create_new_password_page.dart';
import 'package:flutter_sms/features/auth/presentation/login_page.dart';
import 'package:flutter_sms/features/auth/presentation/widgets/auth_widgets.dart';

class VerificationCodePage extends StatefulWidget {
  const VerificationCodePage({super.key, required this.email});

  final String email;

  @override
  State<VerificationCodePage> createState() => _VerificationCodePageState();
}

class _VerificationCodePageState extends State<VerificationCodePage>
    with SingleTickerProviderStateMixin {
  static const int _otpLength = 6;
  static const int _resendSeconds = 45;

  final List<TextEditingController> _controllers =
      List.generate(_otpLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(_otpLength, (_) => FocusNode());

  late final AnimationController _c;
  late final Animation<double> _aTitle;
  late final Animation<double> _aOtp;
  late final Animation<double> _aResend;
  late final Animation<double> _aButton;
  late final Animation<double> _aLink;

  // Per-box staggered entrance
  late final List<Animation<double>> _boxAnims;

  Timer? _timer;
  int _remaining = _resendSeconds;
  bool _canResend = false;

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
    _aOtp = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.15, 0.55, curve: Curves.easeOutCubic),
    );
    _aResend = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.35, 0.7, curve: Curves.easeOutCubic),
    );
    _aButton = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.45, 0.85, curve: Curves.easeOutCubic),
    );
    _aLink = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic),
    );

    _boxAnims = List.generate(_otpLength, (i) {
      final start = 0.2 + (i * 0.06);
      final end = (start + 0.35).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: _c,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      );
    });

    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) _c.forward();
    });

    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNodes[0].requestFocus();
    });
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _remaining = _resendSeconds;
      _canResend = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        if (_remaining <= 1) {
          _remaining = 0;
          _canResend = true;
          t.cancel();
        } else {
          _remaining--;
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _c.dispose();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
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

  String get _code => _controllers.map((c) => c.text).join();

  void _onChanged(int index, String value) {
    if (value.length > 1) {
      // Handle paste
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (var i = 0; i < _otpLength; i++) {
        _controllers[i].text = i < digits.length ? digits[i] : '';
      }
      final next = digits.length.clamp(0, _otpLength - 1);
      _focusNodes[next].requestFocus();
      setState(() {});
      return;
    }

    if (value.isNotEmpty && index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    setState(() {});
  }

  void _onKey(int index, KeyEvent event) {
    if (event is! KeyDownEvent) return;
    if (event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
      _controllers[index - 1].clear();
      setState(() {});
    }
  }

  void _onResend() {
    if (!_canResend) return;
    // TODO: call resend OTP API
    for (final c in _controllers) {
      c.clear();
    }
    _focusNodes[0].requestFocus();
    _startTimer();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('A new code has been sent')),
    );
  }

  void _onVerify() {
    if (_code.length < _otpLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the complete 6-digit code')),
      );
      return;
    }
    // TODO: call verify OTP API
    Navigator.of(context).push(
      authRoute(const CreateNewPasswordPage()),
    );
  }

  String get _timerLabel {
    final m = (_remaining ~/ 60).toString().padLeft(2, '0');
    final s = (_remaining % 60).toString().padLeft(2, '0');
    return 'Resend Code ($m:$s)';
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
                                      'Verification Code',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                        color: AuthColors.textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Enter the 6-digit code we sent to\n${widget.email}',
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
                                _aOtp,
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Secure OTP Code',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AuthColors.textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: List.generate(_otpLength, (i) {
                                        return _OtpBox(
                                          animation: _boxAnims[i],
                                          controller: _controllers[i],
                                          focusNode: _focusNodes[i],
                                          onChanged: (v) => _onChanged(i, v),
                                          onKey: (e) => _onKey(i, e),
                                        );
                                      }),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 18),
                              _reveal(
                                _aResend,
                                Center(
                                  child: _canResend
                                      ? AuthLink(
                                          label: 'Resend Code',
                                          onTap: _onResend,
                                          color: AuthColors.blue,
                                        )
                                      : Text(
                                          _timerLabel,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: AuthColors.textGrey,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 22),
                              _reveal(
                                _aButton,
                                AuthButton(
                                  label: 'Verify & Continue',
                                  onPressed: _onVerify,
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

class _OtpBox extends StatelessWidget {
  const _OtpBox({
    required this.animation,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onKey,
  });

  final Animation<double> animation;
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final ValueChanged<KeyEvent> onKey;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.7, end: 1.0).animate(animation),
        child: SizedBox(
          width: 46,
          height: 56,
          child: KeyboardListener(
            focusNode: FocusNode(),
            onKeyEvent: onKey,
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AuthColors.textDark,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: AuthColors.fieldBg,
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: AuthColors.border,
                    width: 1.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: AuthColors.border,
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: AuthColors.blue,
                    width: 1.5,
                  ),
                ),
              ),
              onChanged: onChanged,
            ),
          ),
        ),
      ),
    );
  }
}
