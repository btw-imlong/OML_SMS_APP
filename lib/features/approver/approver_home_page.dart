import 'package:flutter/material.dart';
import 'package:flutter_sms/core/models/user_role.dart';
import 'package:flutter_sms/core/storage/session_storage.dart';
import 'package:flutter_sms/features/profile/profile_page.dart';
import 'package:flutter_sms/features/home/data/home_mission.dart';
import 'package:flutter_sms/features/home/data/home_mission_source.dart';
import 'package:flutter_sms/features/home/data/mission_refresh.dart';
import 'package:flutter_sms/features/mission/presentation/mission_detail_page.dart';
import 'package:flutter_sms/features/mission/domain/entities/mission_status.dart';

/// Home page for every role except staff (managers, HRBP, finance, ...).
class ApproverHomePage extends StatefulWidget {
  const ApproverHomePage({super.key, required this.role, this.onSeeAll});

  final UserRole role;
  final VoidCallback? onSeeAll;

  @override
  State<ApproverHomePage> createState() => _ApproverHomePageState();
}

class _ApproverHomePageState extends State<ApproverHomePage> {
  static const _blue = Color(0xFF1B4587);
  static const _ink = Color(0xFF1A1A1A);
  static const _grey = Color(0xFF6B7280);

  final _source = HomeMissionSource();

  String _name = '';
  List<HomeMission> _missions = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    missionRefresh.addListener(_onMissionsChanged);
    _bootstrap();
  }

  void _openProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ProfilePage(showBack: true)),
    );
  }

  @override
  void dispose() {
    missionRefresh.removeListener(_onMissionsChanged);
    super.dispose();
  }

  void _onMissionsChanged() {
    if (mounted) _load();
  }

  Future<void> _openMission(HomeMission m) async {
    final id = int.tryParse(m.id);
    if (id == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MissionDetailPage(id: id, code: m.code),
      ),
    );
    if (mounted) _load();
  }

  Future<void> _bootstrap() async {
    final name = await SessionStorage().getName() ?? '';
    if (!mounted) return;
    setState(() => _name = name);
    await _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = _missions.isEmpty;
      _error = null;
    });
    try {
      final data = await _source.fetchMissions(widget.role);
      if (!mounted) return;
      setState(() {
        _missions = data;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load missions.';
        _loading = false;
      });
    }
  }

  int get _totalApprovals => _missions
      .where((m) => m.status.name.toLowerCase().contains('approved'))
      .length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: Column(
        children: [
          _header(),
          Expanded(child: _body()),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Header
  // ---------------------------------------------------------------------------

  Widget _header() {
    final displayName = _name.isNotEmpty ? _name : widget.role.label;
    final initial = displayName.characters.first.toUpperCase();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 16,
        20,
        22,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2A5CAB), _blue],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _openProfile,
            child: Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.18),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(
                Icons.notifications_none_rounded,
                color: Colors.white,
                size: 28,
              ),
              Positioned(
                top: 1,
                right: 1,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    shape: BoxShape.circle,
                    border: Border.all(color: _blue, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Body
  // ---------------------------------------------------------------------------

  Widget _body() {
    if (_loading) return const Center(child: CircularProgressIndicator());

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: const TextStyle(color: _grey)),
            const SizedBox(height: 8),
            TextButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    }

    final recent = _missions.take(5).toList();

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
        children: [
          _announcement(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _statCard(
                  label: 'Total Approvals',
                  value: _totalApprovals,
                  icon: Icons.check_circle_outline_rounded,
                  filled: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statCard(
                  label: 'Total Requests',
                  value: _missions.length,
                  icon: Icons.description_outlined,
                  filled: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Recent activity',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _ink,
                  ),
                ),
              ),
              GestureDetector(
                onTap: widget.onSeeAll,
                child: const Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (recent.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Column(
                children: [
                  Icon(Icons.inbox_outlined,
                      size: 48, color: Color(0xFFB8BFCC)),
                  SizedBox(height: 10),
                  Text('No recent activity', style: TextStyle(color: _grey)),
                ],
              ),
            )
          else
            for (final m in recent) _activityCard(m),
        ],
      ),
    );
  }

  Widget _announcement() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        height: 160,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/meeting.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(color: _blue),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00000000), Color(0xCC000000)],
                  stops: [0.35, 1.0],
                ),
              ),
            ),
            const Positioned(
              left: 16,
              right: 16,
              bottom: 14,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Company Announcement',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Annual meeting scheduled for next Friday.',
                    style: TextStyle(color: Colors.white70, fontSize: 12.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard({
    required String label,
    required int value,
    required IconData icon,
    required bool filled,
  }) {
    final fg = filled ? Colors.white : _ink;

    return Container(
      height: 124,
      decoration: BoxDecoration(
        gradient: filled
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF3B70F0), Color(0xFF1F4FD0)],
              )
            : null,
        color: filled ? null : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: filled ? null : Border.all(color: const Color(0xFFE8EBF2)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            if (filled)
              Positioned(
                top: -22,
                right: -22,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.10),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: filled
                          ? Colors.white.withValues(alpha: 0.22)
                          : const Color(0xFFE6F6EC),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      size: 18,
                      color: filled ? Colors.white : const Color(0xFF16A34A),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$value',
                        style: TextStyle(
                          fontSize: 28,
                          height: 1.1,
                          fontWeight: FontWeight.w800,
                          color: fg,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: fg,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Recent activity card
  // ---------------------------------------------------------------------------

  Widget _activityCard(HomeMission m) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8EBF2)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _openMission(m),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        m.title,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: _ink,
                          height: 1.25,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _statusBadge(m.status),
                  ],
                ),
                const SizedBox(height: 12),
                _infoRow(Icons.location_on_outlined, m.location),
                _infoRow(Icons.calendar_today_outlined, m.dateLabel),
                _infoRow(
                  Icons.directions_car_outlined,
                  m.typeLabel,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(height: 1, color: Color(0xFFEDEFF5)),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        m.note ?? '',
                        style: const TextStyle(fontSize: 12.5, color: _grey),
                      ),
                    ),
                    Text(
                      m.amountLabel,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: _ink,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(Icons.chevron_right_rounded,
                        size: 20, color: _grey),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusBadge(MissionStatus s) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: s.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        s.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: s.color,
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 15, color: _grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12.5, color: _grey),
            ),
          ),
        ],
      ),
    );
  }
}
