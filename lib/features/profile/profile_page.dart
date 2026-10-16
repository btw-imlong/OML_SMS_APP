import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sms/core/models/user_role.dart';
import 'package:flutter_sms/core/network/dio_client.dart';
import 'package:flutter_sms/core/storage/session_storage.dart';
import 'package:flutter_sms/core/storage/token_storage.dart';
import 'package:flutter_sms/features/auth/presentation/login_page.dart';
import 'package:flutter_sms/features/profile/data/profile_repository.dart';
import 'package:flutter_sms/features/profile/data/user_profile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, this.showBack = false});

  /// true when opened by tapping the avatar (shows a back button).
  final bool showBack;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _Row {
  const _Row(this.icon, this.label, this.value);
  final IconData icon;
  final String label;
  final String value;
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  static const _blue = Color(0xFF1B4587);
  static const _blueLight = Color(0xFF2A5CAB);
  static const _ink = Color(0xFF1A1A1A);
  static const _grey = Color(0xFF6B7280);
  static const _red = Color(0xFFD23B3B);

  final _repo = ProfileRepository(DioClient());

  // Header entrance
  late final AnimationController _head = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  // Content entrance (plays when data arrives)
  late final AnimationController _body = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );
  // Skeleton pulse
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  )..repeat(reverse: true);

  late final List<Animation<double>> _headSteps = List.generate(4, (i) {
    final s = i * 0.16;
    return CurvedAnimation(
      parent: _head,
      curve: Interval(s, s + 0.5, curve: Curves.easeOutCubic),
    );
  });

  late final List<Animation<double>> _bodySteps = List.generate(5, (i) {
    final s = i * 0.14;
    return CurvedAnimation(
      parent: _body,
      curve: Interval(s, s + 0.44, curve: Curves.easeOutCubic),
    );
  });

  UserProfile? _profile;
  String _cachedName = '';
  bool _loading = true;
  bool _loggingOut = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _head.forward();
    _bootstrap();
  }

  @override
  void dispose() {
    _head.dispose();
    _body.dispose();
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final name = await SessionStorage().getName() ?? '';
    if (mounted) setState(() => _cachedName = name);
    await _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = _profile == null;
      _error = null;
    });
    try {
      final p = await _repo.me();
      if (p.fullName.isNotEmpty) await SessionStorage().saveName(p.fullName);
      if (!mounted) return;
      setState(() {
        _profile = p;
        _loading = false;
      });
      _body.forward(from: 0);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load your profile.';
        _loading = false;
      });
      _body.forward(from: 0);
    }
  }

  // ---------------------------------------------------------------------------
  // Logout
  // ---------------------------------------------------------------------------

  Future<void> _confirmLogout() async {
    final ok = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE1E5EE),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 22),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _red.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout_rounded, color: _red, size: 26),
              ),
              const SizedBox(height: 16),
              const Text(
                'Log out?',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: _ink,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'You will need to sign in again to continue.',
                style: TextStyle(fontSize: 13.5, color: _grey),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _ink,
                          side: const BorderSide(color: Color(0xFFE1E5EE)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _red,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Log out',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (ok == true) await _logout();
  }

  Future<void> _logout() async {
    if (_loggingOut) return;
    setState(() => _loggingOut = true);

    // Tell the server, but always log out locally even if this fails.
    try {
      await _repo.logout();
    } catch (_) {}

    await TokenStorage().saveToken(''); // empty token = logged out
    await SessionStorage().clear();

    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  void _copy(String label, String value) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$label copied'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  List<String> get _roleLabels {
    final p = _profile;
    if (p == null) return const [];
    return p.roles.map((r) => UserRole.tryParse(r)?.label ?? r).toList();
  }

  Widget _reveal(Animation<double> a, Widget child, {double dy = 0.12}) {
    return FadeTransition(
      opacity: a,
      child: SlideTransition(
        position: Tween<Offset>(begin: Offset(0, dy), end: Offset.zero)
            .animate(a),
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
      backgroundColor: const Color(0xFFF6F7FB),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: EdgeInsets.zero,
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            _header(),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 22, 18, 32),
              child: _content(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circle(double size, double alpha) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: alpha),
        ),
      );

  Widget _header() {
    final p = _profile;
    final name = (p?.fullName.isNotEmpty ?? false) ? p!.fullName : _cachedName;
    final initials = p?.initials ??
        (name.isNotEmpty ? name.trim().characters.first.toUpperCase() : '?');

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(36)),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_blueLight, _blue],
          ),
        ),
        child: Stack(
          children: [
            Positioned(top: -70, right: -50, child: _circle(210, 0.07)),
            Positioned(bottom: -60, left: -45, child: _circle(150, 0.06)),
            Positioned(top: 90, left: 28, child: _circle(14, 0.14)),
            Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                MediaQuery.of(context).padding.top + 8,
                20,
                30,
              ),
              child: Column(
                children: [
                  if (widget.showBack)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Material(
                        color: Colors.white.withValues(alpha: 0.16),
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => Navigator.of(context).maybePop(),
                          child: const Padding(
                            padding: EdgeInsets.all(10),
                            child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 30),
                  const SizedBox(height: 14),

                  // Avatar
                  ScaleTransition(
                    scale: Tween<double>(begin: 0.6, end: 1).animate(
                      CurvedAnimation(
                        parent: _head,
                        curve: const Interval(0, 0.7, curve: Curves.easeOutBack),
                      ),
                    ),
                    child: FadeTransition(
                      opacity: _headSteps[0],
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.35),
                            width: 2,
                          ),
                        ),
                        child: Container(
                          width: 96,
                          height: 96,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.18),
                                blurRadius: 22,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Text(
                            initials,
                            style: const TextStyle(
                              color: _blueLight,
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Name
                  _reveal(
                    _headSteps[1],
                    Text(
                      name.isEmpty ? 'Your profile' : name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),

                  if (p != null && p.email.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    _reveal(
                      _headSteps[2],
                      Text(
                        p.email,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _content() {
    if (_loading) return _skeleton();

    final p = _profile;
    if (p == null) {
      return Column(
        children: [
          const SizedBox(height: 30),
          const Icon(Icons.cloud_off_rounded, size: 44, color: Color(0xFFB8BFCC)),
          const SizedBox(height: 10),
          Text(_error ?? 'Something went wrong.',
              style: const TextStyle(color: _grey)),
          const SizedBox(height: 6),
          TextButton(onPressed: _load, child: const Text('Retry')),
          const SizedBox(height: 14),
          _logoutButton(),
        ],
      );
    }

    final employment = <_Row>[
      _Row(Icons.badge_outlined, 'Employee ID', p.employeeId),
      if (p.jobLevel.isNotEmpty)
        _Row(Icons.work_outline_rounded, 'Position', p.jobLevel),
      if (p.functionName != null)
        _Row(Icons.account_tree_outlined, 'Function', p.functionName!),
      if (p.business != null)
        _Row(Icons.business_outlined, 'Business', p.business!),
    ];

    final contact = <_Row>[
      if (p.email.isNotEmpty)
        _Row(Icons.mail_outline_rounded, 'Work email', p.email),
    ];

    final account = <_Row>[
      if (_roleLabels.isNotEmpty)
        _Row(Icons.shield_outlined, _roleLabels.length > 1 ? 'Roles' : 'Role',
            _roleLabels.join(', ')),
    ];

    return Column(
      children: [
        _reveal(_bodySteps[0], _section('Employment', employment)),
        if (contact.isNotEmpty) ...[
          const SizedBox(height: 18),
          _reveal(_bodySteps[1], _section('Contact', contact)),
        ],
        if (account.isNotEmpty) ...[
          const SizedBox(height: 18),
          _reveal(_bodySteps[2], _section('Account', account)),
        ],
        const SizedBox(height: 26),
        _reveal(_bodySteps[3], _logoutButton()),
        const SizedBox(height: 14),
        FadeTransition(
          opacity: _bodySteps[4],
          child: const Text(
            'Tap a field to copy it',
            style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
          ),
        ),
      ],
    );
  }

  Widget _section(String title, List<_Row> rows) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 6, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: Color(0xFF9CA3AF),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE8EBF2)),
            boxShadow: [
              BoxShadow(
                color: _blue.withValues(alpha: 0.05),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Material(
              color: Colors.transparent,
              child: Column(
                children: [
                  for (var i = 0; i < rows.length; i++) ...[
                    _infoRow(rows[i]),
                    if (i != rows.length - 1)
                      const Divider(
                        height: 1,
                        indent: 70,
                        color: Color(0xFFEDEFF5),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoRow(_Row r) {
    return InkWell(
      onTap: () => _copy(r.label, r.value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _blueLight.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(r.icon, size: 20, color: _blueLight),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.label,
                    style: const TextStyle(fontSize: 12, color: _grey),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    r.value,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: _ink,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _logoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: _loggingOut ? null : _confirmLogout,
        style: ElevatedButton.styleFrom(
          backgroundColor: _red.withValues(alpha: 0.08),
          foregroundColor: _red,
          disabledBackgroundColor: _red.withValues(alpha: 0.05),
          disabledForegroundColor: _red,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: _red.withValues(alpha: 0.35)),
          ),
        ),
        icon: _loggingOut
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: _red),
              )
            : const Icon(Icons.logout_rounded, size: 20),
        label: const Text(
          'Log out',
          style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  // Pulsing placeholder while /me loads
  Widget _skeleton() {
    Widget bar(double w, double h) => Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            color: const Color(0xFFE6EAF2),
            borderRadius: BorderRadius.circular(6),
          ),
        );

    Widget card() => Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE8EBF2)),
          ),
          child: Column(
            children: [
              for (var i = 0; i < 3; i++) ...[
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6EAF2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [bar(70, 10), const SizedBox(height: 8), bar(150, 14)],
                    ),
                  ],
                ),
                if (i != 2) const SizedBox(height: 18),
              ],
            ],
          ),
        );

    return FadeTransition(
      opacity: Tween<double>(begin: 0.45, end: 1).animate(_pulse),
      child: Column(
        children: [card(), const SizedBox(height: 18), card()],
      ),
    );
  }
}
