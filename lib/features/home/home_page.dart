import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sms/core/models/user_role.dart';
import 'package:flutter_sms/core/storage/session_storage.dart';
import 'package:flutter_sms/features/profile/profile_page.dart';
import 'package:flutter_sms/features/home/data/home_mission.dart';
import 'package:flutter_sms/features/home/data/home_mission_source.dart';
import 'package:flutter_sms/features/home/data/mission_refresh.dart';
import 'package:flutter_sms/features/mission/presentation/mission_detail_page.dart';
import 'package:flutter_sms/features/mission/domain/entities/mission_status.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _blue = Color(0xFF1B4587);
  static const _ink = Color(0xFF1A1A1A);
  static const _grey = Color(0xFF6B7280);

  /// false = only show filter chips for statuses that have missions.
  /// true  = always show all 12 statuses from the backend enum.
  static const _showEmptyStatuses = false;

  final _source = HomeMissionSource();
  final _searchController = TextEditingController();

  UserRole _role = UserRole.staff;
  String _name = '';
  List<HomeMission> _missions = const [];
  bool _loading = true;
  String? _error;

  String _filterId = 'all';
  bool _searching = false;
  String _query = '';

  @override
  void initState() {
    super.initState();
    missionRefresh.addListener(_onMissionsChanged);
    _bootstrap();
  }

  @override
  void dispose() {
    missionRefresh.removeListener(_onMissionsChanged);
    _searchController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Data
  // ---------------------------------------------------------------------------

  void _openProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ProfilePage(showBack: true)),
    );
  }

  void _onMissionsChanged() {
    if (mounted) _load();
  }

  Future<void> _bootstrap() async {
    final session = SessionStorage();
    final role = await session.getRole() ?? UserRole.staff;
    final name = await session.getName() ?? '';
    if (!mounted) return;

    setState(() {
      _role = role;
      _name = name;
      _filterId = role.isStaff ? 'all' : 'queue';
    });
    await _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = _missions.isEmpty;
      _error = null;
    });
    try {
      final data = await _source.fetchMissions(_role);
      if (!mounted) return;
      setState(() {
        _missions = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load missions.';
        _loading = false;
      });
    }
  }

  bool _inQueue(HomeMission m) => _role.queueStatuses.contains(m.status);

  List<_FilterOption> _filters() {
    final options = <_FilterOption>[];
    if (!_role.isStaff) {
      options.add(
        _FilterOption('queue', 'To review', _missions.where(_inQueue).length),
      );
    }
    options.add(_FilterOption('all', 'All', _missions.length));
    for (final s in MissionStatus.values) {
      final count = _missions.where((m) => m.status == s).length;
      if (count > 0 || _showEmptyStatuses) {
        options.add(_FilterOption(s.name, s.label, count));
      }
    }
    return options;
  }

  List<HomeMission> _visible(String filterId) {
    Iterable<HomeMission> list = _missions;
    if (filterId == 'queue') {
      list = list.where(_inQueue);
    } else if (filterId != 'all') {
      list = list.where((m) => m.status.name == filterId);
    }
    final q = _query.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where(
        (m) =>
            m.code.toLowerCase().contains(q) ||
            m.title.toLowerCase().contains(q) ||
            m.location.toLowerCase().contains(q) ||
            m.requesterName.toLowerCase().contains(q),
      );
    }
    return list.toList();
  }

  void _closeSearch() {
    setState(() {
      _searching = false;
      _query = '';
      _searchController.clear();
    });
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

  /// Debug only: long-press the avatar to preview the app as another role.
  Future<void> _pickRoleForPreview() async {
    final picked = await showModalBottomSheet<UserRole>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Preview as role (debug only)',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
              for (final r in UserRole.values)
                ListTile(
                  title: Text(r.label),
                  trailing: r == _role
                      ? const Icon(Icons.check_rounded, color: _blue)
                      : null,
                  onTap: () => Navigator.pop(context, r),
                ),
            ],
          ),
        ),
      ),
    );
    if (picked == null || !mounted) return;

    await SessionStorage().saveRole(picked);
    setState(() {
      _role = picked;
      _filterId = picked.isStaff ? 'all' : 'queue';
      _missions = const [];
      _searching = false;
      _query = '';
      _searchController.clear();
    });
    await _load();
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final filters = _filters();
    final activeId =
        filters.any((f) => f.id == _filterId) ? _filterId : filters.first.id;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: Column(
        children: [
          _header(),
          Expanded(child: _body(filters, activeId)),
        ],
      ),
    );
  }

  Widget _header() {
    final displayName = _name.isNotEmpty ? _name : _role.label;
    final initial = displayName.characters.first.toUpperCase();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 16,
        20,
        24,
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
            onLongPress: kDebugMode ? _pickRoleForPreview : null,
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
                if (!_role.isStaff) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _role.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
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

  Widget _body(List<_FilterOption> filters, String activeId) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

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

    final items = _visible(activeId);

    final String title;
    final String subtitle;
    if (_role.isStaff) {
      final n = _missions.length;
      title = 'My missions';
      subtitle = '$n total request${n == 1 ? '' : 's'}';
    } else {
      final n = _missions.where(_inQueue).length;
      title = 'Approval queue';
      subtitle = '$n waiting for your review';
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 24),
        children: [
          _titleRow(title, subtitle),
          const SizedBox(height: 14),
          _chips(filters, activeId),
          const SizedBox(height: 16),
          if (items.isEmpty)
            _empty()
          else
            for (var i = 0; i < items.length; i++)
              _missionCard(items[i], i, activeId),
        ],
      ),
    );
  }

  Widget _titleRow(String title, String subtitle) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: _searching
          ? TextField(
              key: const ValueKey('search'),
              controller: _searchController,
              autofocus: true,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Search missions',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: IconButton(
                  onPressed: _closeSearch,
                  icon: const Icon(Icons.close_rounded),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            )
          : Row(
              key: const ValueKey('title'),
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: _ink,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(fontSize: 13, color: _grey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => _searching = true),
                  icon: const Icon(Icons.search_rounded, color: _ink),
                ),
              ],
            ),
    );
  }

  Widget _chips(List<_FilterOption> filters, String activeId) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final f = filters[i];
          final selected = f.id == activeId;
          return GestureDetector(
            onTap: () => setState(() => _filterId = f.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? _blue : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? _blue : const Color(0xFFE1E5EE),
                ),
              ),
              child: Text(
                '${f.label}  ${f.count}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : _ink,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _empty() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 48, color: Color(0xFFB8BFCC)),
          SizedBox(height: 10),
          Text('No missions here', style: TextStyle(color: _grey)),
        ],
      ),
    );
  }

  Widget _missionCard(HomeMission m, int index, String activeId) {
    final inQueue = !_role.isStaff && _inQueue(m);
    final delay = math.min(index, 8) * 50;

    final String note;
    final Color noteColor;
    if (inQueue) {
      note = 'Needs your review';
      noteColor = const Color(0xFFB45309);
    } else {
      note = m.note ?? '';
      noteColor = m.status == MissionStatus.rejected
          ? const Color(0xFFD23B3B)
          : _grey;
    }

    return TweenAnimationBuilder<double>(
      key: ValueKey('$activeId-${m.id}-$_query'),
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 350 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, 14 * (1 - v)), child: child),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE8EBF2)),
          boxShadow: [
            BoxShadow(
              color: _blue.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _openMission(m),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          m.code,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: _grey,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      _statusBadge(m.status),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    m.title,
                    style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      color: _ink,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (!_role.isStaff)
                    _infoRow(
                      Icons.person_outline_rounded,
                      '${m.requesterName} \u00B7 ${m.department}',
                      color: _ink,
                    ),
                  _infoRow(Icons.location_on_outlined, m.location),
                  _infoRow(Icons.calendar_today_outlined, m.dateLabel),
                  _infoRow(
                    Icons.directions_car_outlined,
                    m.typeLabel,
                    color: _blue,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(height: 1, color: Color(0xFFEDEFF5)),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          note,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight:
                                inQueue ? FontWeight.w700 : FontWeight.w500,
                            color: noteColor,
                          ),
                        ),
                      ),
                      Text(
                        m.amountLabel,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: _ink,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: _grey,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusBadge(MissionStatus s) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: s.background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        s.label.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
          color: s.color,
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, {Color color = _grey}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Icon(icon, size: 16, color: _grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterOption {
  const _FilterOption(this.id, this.label, this.count);

  final String id;
  final String label;
  final int count;
}
