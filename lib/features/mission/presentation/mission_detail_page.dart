import 'package:flutter/material.dart';
import 'package:flutter_sms/features/mission/data/mission_detail_repository.dart';
import 'package:flutter_sms/features/mission/domain/entities/mission_status.dart';

class MissionDetailPage extends StatefulWidget {
  const MissionDetailPage({super.key, required this.id, this.code});

  final int id;
  final String? code;

  @override
  State<MissionDetailPage> createState() => _MissionDetailPageState();
}

class _MissionDetailPageState extends State<MissionDetailPage>
    with TickerProviderStateMixin {
  static const _blue = Color(0xFF1B4587);
  static const _blueLight = Color(0xFF2A5CAB);
  static const _ink = Color(0xFF1A1A1A);
  static const _grey = Color(0xFF6B7280);
  static const _green = Color(0xFF15803D);
  static const _red = Color(0xFFD23B3B);
  static const _line = Color(0xFFEDEFF5);

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  final _repo = MissionDetailRepository();

  late final AnimationController _enter = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  );
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  )..repeat(reverse: true);

  MissionDetail? _m;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _enter.dispose();
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = _m == null;
      _error = null;
    });
    try {
      final m = await _repo.fetch(widget.id);
      if (!mounted) return;
      setState(() {
        _m = m;
        _loading = false;
      });
      _enter.forward(from: 0);
    } catch (e) {
      debugPrint('MissionDetailPage load failed: $e');
      if (!mounted) return;
      setState(() {
        _error = 'Could not load this mission.';
        _loading = false;
      });
    }
  }

  // ---------------------------------------------------------------------------
  // Formatting
  // ---------------------------------------------------------------------------

  String _money(double v) => '\$${v.toStringAsFixed(2)}';

  String _date(DateTime? d) =>
      d == null ? '-' : '${d.day.toString().padLeft(2, '0')} ${_months[d.month - 1]} ${d.year}';

  String _pretty(String raw) {
    if (raw.isEmpty) return '';
    final w = raw.replaceAll('_', ' ').toLowerCase().split(' ');
    return w.map((x) => x.isEmpty ? x : x[0].toUpperCase() + x.substring(1)).join(' ');
  }

  String _travelDates(MissionDetail m) {
    if (m.departureDate == null) return '-';
    final a = _date(m.departureDate);
    final b = _date(m.arrivalDate);
    return (m.arrivalDate == null || a == b) ? a : '$a \u2013 $b';
  }

  Widget _reveal(int i, Widget child) {
    final start = (i * 0.09).clamp(0.0, 0.6);
    final a = CurvedAnimation(
      parent: _enter,
      curve: Interval(start, (start + 0.4).clamp(0.0, 1.0),
          curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: a,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
            .animate(a),
        child: child,
      ),
    );
  }

  void _soon(String what) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$what \u2014 coming soon'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // ---------------------------------------------------------------------------
  // Build
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
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
              child: _body(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    final m = _m;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 8,
        16,
        24,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_blueLight, _blue],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Material(
                color: Colors.white.withValues(alpha: 0.16),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => Navigator.of(context).maybePop(),
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 18),
                  ),
                ),
              ),
              const Expanded(
                child: Text(
                  'Mission detail',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 38),
            ],
          ),
          const SizedBox(height: 20),
          if (m == null)
            Text(
              widget.code ?? '',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 13,
              ),
            )
          else ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    m.code,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12.5,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                  decoration: BoxDecoration(
                    color: m.status.background,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    m.status.label,
                    style: TextStyle(
                      color: m.status.color,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              m.objectives.isNotEmpty ? m.objectives : m.destination,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                height: 1.25,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _heroInfo(Icons.location_on_outlined, m.destination),
                _heroInfo(Icons.calendar_today_outlined, _travelDates(m)),
                _heroInfo(Icons.payments_outlined, _money(m.totalExpense)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _heroInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: Colors.white.withValues(alpha: 0.85)),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.92),
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _body() {
    if (_loading) return _skeleton();

    final m = _m;
    if (m == null) {
      return Column(
        children: [
          const SizedBox(height: 40),
          const Icon(Icons.cloud_off_rounded, size: 44, color: Color(0xFFB8BFCC)),
          const SizedBox(height: 10),
          Text(_error ?? 'Something went wrong.',
              style: const TextStyle(color: _grey)),
          TextButton(onPressed: _load, child: const Text('Retry')),
        ],
      );
    }

    var i = 0;
    return Column(
      children: [
        _reveal(i++, _missionCard(m)),
        if (m.participants.length > 1) ...[
          const SizedBox(height: 16),
          _reveal(i++, _participantsCard(m)),
        ],
        const SizedBox(height: 16),
        _reveal(i++, _allowanceCard(m)),
        const SizedBox(height: 16),
        _reveal(i++, _approvalCard(m)),
        const SizedBox(height: 16),
        _reveal(i++, _managementCard(m)),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Cards
  // ---------------------------------------------------------------------------

  Widget _card(String title, IconData icon, List<Widget> children,
      {Widget? trailing}) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: _blueLight.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: _blueLight),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: _ink,
                    ),
                  ),
                ),
                ?trailing,
              ],
            ),
          ),
          ...children,
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  Widget _row(String label, String value,
      {Color? color, bool strong = true, bool last = false}) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: last ? null : const Border(top: BorderSide(color: _line)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            child: Text(label,
                style: const TextStyle(fontSize: 13, color: _grey)),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: strong ? FontWeight.w700 : FontWeight.w500,
                color: color ?? _ink,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _missionCard(MissionDetail m) {
    final dep = m.departureTime;
    final arr = m.arrivalTime;
    return _card('Mission', Icons.flag_outlined, [
      if (m.objectives.isNotEmpty)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PURPOSE',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                  color: Color(0xFFB45309),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                m.objectives,
                style: const TextStyle(
                  fontSize: 14.5,
                  height: 1.35,
                  color: _ink,
                ),
              ),
            ],
          ),
        ),
      _row('Mission type', '${_pretty(m.missionType)} mission'),
      _row('Requested by',
          m.jobLevel.isEmpty ? m.requesterName : '${m.requesterName} \u00B7 ${_pretty(m.jobLevel)}'),
      _row('Position', m.position),
      _row('Department', m.functionName),
      _row('Business', m.business),
      _row('Base location', m.basedLocation),
      _row('Destination', m.destination),
      _row('Travel dates', _travelDates(m)),
      _row('Duration', m.days > 0 ? '${m.days} ${m.days == 1 ? 'day' : 'days'}' : ''),
      _row('Departure time', dep ?? ''),
      _row('Arrival / return', arr ?? ''),
      _row(
        'Accommodation',
        m.nights > 0 ? '${m.nights} ${m.nights == 1 ? 'night' : 'nights'}' : 'Not required',
        color: m.nights > 0 ? _ink : _blueLight,
      ),
      if (m.description.isNotEmpty)
        _row('Notes', m.description, strong: false, last: true),
    ]);
  }

  Widget _participantsCard(MissionDetail m) {
    return _card(
      'Participants',
      Icons.groups_outlined,
      [
        for (final p in m.participants)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: _line)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: _blueLight.withValues(alpha: 0.12),
                  child: Text(
                    p.fullName.isEmpty ? '?' : p.fullName.characters.first.toUpperCase(),
                    style: const TextStyle(
                      color: _blueLight,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.fullName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        [
                          if (p.employeeCode.isNotEmpty) p.employeeCode,
                          if (p.functionName.isNotEmpty) p.functionName,
                        ].join(' \u00B7 '),
                        style: const TextStyle(fontSize: 12, color: _grey),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _money(p.totalExpense),
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: _ink,
                      ),
                    ),
                    if (p.requester)
                      const Text('Requester',
                          style: TextStyle(fontSize: 11, color: _blueLight)),
                  ],
                ),
              ],
            ),
          ),
      ],
      trailing: Text(
        '${m.participants.length}',
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: _grey,
        ),
      ),
    );
  }

  Widget _mealRow(String label, Meal meal) {
    return _row(
      label,
      meal.eligible
          ? (meal.quantity > 0
              ? 'Eligible \u00B7 ${meal.quantity} \u00D7 ${_money(meal.amount)}'
              : 'Eligible')
          : 'Not eligible',
      color: meal.eligible ? _green : _grey,
    );
  }

  Widget _allowanceCard(MissionDetail m) {
    final grade = [
      if (m.jobLevel.isNotEmpty) _pretty(m.jobLevel),
      if (m.locationTier.isNotEmpty) _pretty(m.locationTier),
    ].join(' \u00B7 ');

    return _card('Allowance calculation', Icons.calculate_outlined, [
      _row('Grade', grade),
      _mealRow('Breakfast', m.breakfast),
      _mealRow('Lunch', m.lunch),
      _mealRow('Dinner', m.dinner),
      _row('Meal allowance', _money(m.mealTotal)),
      _row(
        'Accommodation',
        m.nights > 0
            ? '${m.nights} \u00D7 ${_money(m.accommodationPerNight)} = ${_money(m.accommodationTotal)}'
            : 'Not required',
        color: m.nights > 0 ? _ink : _grey,
      ),
      Container(
        margin: const EdgeInsets.fromLTRB(10, 8, 10, 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: _blueLight.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Expanded(
              child: Text(
                'Total calculated allowance',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: _ink,
                ),
              ),
            ),
            Text(
              _money(m.totalExpense),
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w900,
                color: _blueLight,
              ),
            ),
          ],
        ),
      ),
    ]);
  }

  // ---------------------------------------------------------------------------
  // Approval progress (derived from the mission status)
  // ---------------------------------------------------------------------------

  static const _steps = [
    'Requester',
    'Function Manager',
    'HR Business Partner',
    'Finance',
    'BizOps',
    'Executive',
  ];

  /// Index of the step that is currently active (steps.length = all done).
  int _stage(MissionStatus s) {
    switch (s) {
      case MissionStatus.draft:
        return 0;
      case MissionStatus.submitted:
      case MissionStatus.fmReview:
        return 1;
      case MissionStatus.hrbpReview:
        return 2;
      case MissionStatus.financeReview:
        return 3;
      case MissionStatus.bizopsReview:
        return 4;
      case MissionStatus.executiveReview:
        return 5;
      case MissionStatus.approved:
      case MissionStatus.reportSubmitted:
      case MissionStatus.settled:
        return _steps.length;
      case MissionStatus.rejected:
      case MissionStatus.cancelled:
        return -1;
    }
  }

  Widget _approvalCard(MissionDetail m) {
    final stage = _stage(m.status);

    if (stage < 0) {
      final rejected = m.status == MissionStatus.rejected;
      final c = rejected ? _red : _grey;
      return _card('Approval progress', Icons.verified_outlined, [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: c.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(rejected ? Icons.cancel_outlined : Icons.block_rounded,
                    color: c),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    rejected
                        ? 'This mission was rejected and returned for editing.'
                        : 'This mission was cancelled.',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: c,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ]);
    }

    final done = stage.clamp(0, _steps.length);
    return _card(
      'Approval progress',
      Icons.verified_outlined,
      [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
          child: Column(
            children: [
              for (var i = 0; i < _steps.length; i++)
                _stepTile(
                  _steps[i],
                  i < stage ? 2 : (i == stage ? 1 : 0),
                  last: i == _steps.length - 1,
                ),
            ],
          ),
        ),
      ],
      trailing: Text(
        '$done of ${_steps.length}',
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: _grey,
        ),
      ),
    );
  }

  /// state: 2 = done, 1 = in review, 0 = pending
  Widget _stepTile(String title, int state, {bool last = false}) {
    final Color c = state == 2
        ? _green
        : (state == 1 ? const Color(0xFFB45309) : const Color(0xFFB8BFCC));
    final String label =
        state == 2 ? 'Done' : (state == 1 ? 'In review' : 'Pending');

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: state == 0 ? Colors.white : c,
                    border: Border.all(color: c, width: 2),
                  ),
                  child: state == 2
                      ? const Icon(Icons.check_rounded,
                          size: 15, color: Colors.white)
                      : (state == 1
                          ? const Icon(Icons.more_horiz_rounded,
                              size: 15, color: Colors.white)
                          : null),
                ),
                if (!last)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: state == 2 ? _green.withValues(alpha: 0.5) : _line,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: last ? 0 : 18),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: state == 0 ? FontWeight.w500 : FontWeight.w700,
                        color: state == 0 ? _grey : _ink,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                      color: c.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: c,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Mission management
  // ---------------------------------------------------------------------------

  Widget _managementCard(MissionDetail m) {
    final s = m.status;
    final closed = s == MissionStatus.cancelled ||
        s == MissionStatus.rejected ||
        s == MissionStatus.settled ||
        s == MissionStatus.reportSubmitted;
    final approved = s == MissionStatus.approved ||
        s == MissionStatus.reportSubmitted ||
        s == MissionStatus.settled;

    final tiles = <Widget>[
      if (approved)
        _manageTile(Icons.description_outlined, 'View Mission Order',
            'Approved order document and QR verification', _blueLight,
            () => _soon('Mission order')),
      if (!closed)
        _manageTile(Icons.event_repeat_outlined, 'Reschedule mission',
            'Change travel dates \u2014 approvals are carried over', _blueLight,
            () => _soon('Reschedule')),
      if (!closed)
        _manageTile(Icons.cancel_outlined, 'Cancel mission',
            'A reason is required and all approvers are notified', _red,
            () => _soon('Cancel mission'), danger: true),
    ];

    if (tiles.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            'Mission management',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: _ink,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE8EBF2)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Material(
              color: Colors.transparent,
              child: Column(
                children: [
                  for (var i = 0; i < tiles.length; i++) ...[
                    tiles[i],
                    if (i != tiles.length - 1)
                      const Divider(height: 1, indent: 68, color: _line),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _manageTile(IconData icon, String title, String sub, Color color,
      VoidCallback onTap,
      {bool danger = false}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: danger ? _red : _ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(sub, style: const TextStyle(fontSize: 12, color: _grey)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: _grey),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Loading skeleton
  // ---------------------------------------------------------------------------

  Widget _skeleton() {
    Widget bar(double w, double h) => Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            color: const Color(0xFFE6EAF2),
            borderRadius: BorderRadius.circular(6),
          ),
        );

    Widget card(int rows) => Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE8EBF2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              bar(120, 16),
              const SizedBox(height: 18),
              for (var i = 0; i < rows; i++) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [bar(90, 12), bar(130, 12)],
                ),
                const SizedBox(height: 16),
              ],
            ],
          ),
        );

    return FadeTransition(
      opacity: Tween<double>(begin: 0.45, end: 1).animate(_pulse),
      child: Column(
        children: [card(5), const SizedBox(height: 16), card(4)],
      ),
    );
  }
}
