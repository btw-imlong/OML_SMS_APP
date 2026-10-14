import 'package:flutter/material.dart';

// ─── Colors ──────────────────────────────────────────────────────────────────
class AuthColors {
  static const blue = Color(0xFF0B4392);
  static const blueLight = Color(0xFF1A6BC7);
  static const red = Color(0xFFE53935);
  static const fieldBg = Color(0xFFF5F7FA);
  static const border = Color(0xFFE0E4EA);
  static const textDark = Color(0xFF1A1D26);
  static const textGrey = Color(0xFF8A94A6);
  static const green = Color(0xFF2E9E6B);
}

// ─── Logo ────────────────────────────────────────────────────────────────────
class AuthLogo extends StatelessWidget {
  const AuthLogo({super.key, this.size = 110});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AuthColors.blue.withValues(alpha: 0.25),
            blurRadius: 28,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/logo.png',
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Container(
            color: AuthColors.blue.withValues(alpha: 0.1),
            child: Icon(Icons.business, size: size * 0.45, color: AuthColors.blue),
          ),
        ),
      ),
    );
  }
}

// ─── Background ──────────────────────────────────────────────────────────────
class AuthBackground extends StatelessWidget {
  const AuthBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -80,
          right: -60,
          child: _blob(180, AuthColors.blue.withValues(alpha: 0.06)),
        ),
        Positioned(
          bottom: -40,
          left: -50,
          child: _blob(140, AuthColors.blueLight.withValues(alpha: 0.05)),
        ),
        Positioned(
          top: 180,
          left: -30,
          child: _blob(90, AuthColors.blue.withValues(alpha: 0.04)),
        ),
      ],
    );
  }

  Widget _blob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

// ─── Scaffold wrapper (simple fade, used by older pages) ─────────────────────
class AuthScaffold extends StatefulWidget {
  const AuthScaffold({super.key, required this.child});
  final Widget child;

  @override
  State<AuthScaffold> createState() => _AuthScaffoldState();
}

class _AuthScaffoldState extends State<AuthScaffold>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fade = CurvedAnimation(parent: _c, curve: Curves.easeOut);
    _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          const Positioned.fill(child: AuthBackground()),
          FadeTransition(opacity: _fade, child: widget.child),
        ],
      ),
    );
  }
}

// ─── Text Field ──────────────────────────────────────────────────────────────
class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.onChanged,
  });

  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AuthColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          onChanged: onChanged,
          style: const TextStyle(fontSize: 14, color: AuthColors.textDark),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AuthColors.textGrey.withValues(alpha: 0.7),
              fontSize: 14,
            ),
            prefixIcon: Icon(icon, size: 20, color: AuthColors.textGrey),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AuthColors.fieldBg,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AuthColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AuthColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: AuthColors.blue, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Password Field ──────────────────────────────────────────────────────────
class AuthPasswordField extends StatefulWidget {
  const AuthPasswordField({
    super.key,
    required this.label,
    required this.controller,
    this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  @override
  State<AuthPasswordField> createState() => _AuthPasswordFieldState();
}

class _AuthPasswordFieldState extends State<AuthPasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return AuthTextField(
      label: widget.label,
      hint: '••••••••',
      icon: Icons.lock_outline_rounded,
      controller: widget.controller,
      obscureText: _obscure,
      onChanged: widget.onChanged,
      suffixIcon: IconButton(
        icon: Icon(
          _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          size: 20,
          color: AuthColors.textGrey,
        ),
        onPressed: () => setState(() => _obscure = !_obscure),
      ),
    );
  }
}

// ─── Button (supports null onPressed = disabled / loading) ───────────────────
class AuthButton extends StatelessWidget {
  const AuthButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.trailingIcon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: enabled ? 1.0 : 0.65,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AuthColors.blueLight, AuthColors.blue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: AuthColors.blue.withValues(alpha: 0.32),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onPressed,
            child: Center(
              child: enabled
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (trailingIcon != null) ...[
                          const SizedBox(width: 8),
                          Icon(trailingIcon, size: 18, color: Colors.white),
                        ],
                      ],
                    )
                  : const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Link ────────────────────────────────────────────────────────────────────
class AuthLink extends StatelessWidget {
  const AuthLink({
    super.key,
    required this.label,
    required this.onTap,
    this.color = AuthColors.blue,
  });

  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ),
    );
  }
}
