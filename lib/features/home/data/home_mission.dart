import 'package:flutter_sms/features/mission/domain/entities/mission_status.dart';

/// One mission card on the home page.
/// TODO: add fromJson() when the real API is connected.
class HomeMission {
  const HomeMission({
    required this.id,
    required this.code,
    required this.title,
    required this.location,
    required this.start,
    required this.end,
    required this.type,
    required this.transport,
    required this.status,
    required this.amount,
    this.note,
    this.requesterName = '',
    this.department = '',
    this.isMine = false,
  });

  final String id;
  final String code; // e.g. MSN-2026-0128
  final String title;
  final String location;
  final DateTime start;
  final DateTime end;
  final String type; // e.g. Individual
  final String transport; // e.g. Company Vehicle
  final MissionStatus status;
  final double amount;
  final String? note;
  final String requesterName;
  final String department;
  final bool isMine;

  /// Builds a card from one item of GET /api/missions.
  factory HomeMission.fromApi(Map<String, dynamic> j) {
    String s(dynamic v) => v?.toString().trim() ?? '';
    DateTime? d(dynamic v) => v == null ? null : DateTime.tryParse(v.toString());

    final status =
        MissionStatus.tryParse(s(j['status'])) ?? MissionStatus.draft;
    final start = d(j['departureDate']) ?? d(j['arrivalDate']) ?? DateTime.now();
    final rawEnd = d(j['arrivalDate']) ?? start;
    final objectives = s(j['travelObjectives']);
    final destination = s(j['destinationLocation']);
    final type = s(j['missionType']).replaceAll('_', ' ');

    return HomeMission(
      id: s(j['id']),
      code: s(j['missionCode']),
      title: objectives.isNotEmpty
          ? objectives
          : (destination.isNotEmpty ? destination : 'Untitled mission'),
      location: destination,
      start: start,
      end: rawEnd.isBefore(start) ? start : rawEnd,
      type: type.isEmpty
          ? ''
          : type[0].toUpperCase() + type.substring(1).toLowerCase(),
      transport: '',
      status: status,
      amount: double.tryParse(s(j['totalExpense'])) ?? 0,
      note: _noteFor(status),
      requesterName: s(j['requesterName']),
      department: s(j['functionName']),
    );
  }

  static String? _noteFor(MissionStatus s) {
    switch (s) {
      case MissionStatus.draft:
        return 'Not submitted yet';
      case MissionStatus.submitted:
        return 'Submitted';
      case MissionStatus.fmReview:
        return 'With Function Manager';
      case MissionStatus.hrbpReview:
        return 'With HRBP';
      case MissionStatus.financeReview:
        return 'With Finance';
      case MissionStatus.bizopsReview:
        return 'With BizOps';
      case MissionStatus.executiveReview:
        return 'With Executive';
      case MissionStatus.approved:
        return 'Ready to travel';
      case MissionStatus.rejected:
        return 'Returned for editing';
      case MissionStatus.cancelled:
        return 'Cancelled';
      case MissionStatus.reportSubmitted:
        return 'Report under review';
      case MissionStatus.settled:
        return 'Settled';
    }
  }

  /// "Individual" or "Individual · Company Vehicle" when transport is known.
  String get typeLabel =>
      transport.isEmpty ? type : '$type \u00B7 $transport';

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  int get days => end.difference(start).inDays + 1;

  String get amountLabel => '\$${amount.toStringAsFixed(2)}';

  String get dateLabel {
    String two(int n) => n.toString().padLeft(2, '0');
    final m1 = _months[start.month - 1];
    final m2 = _months[end.month - 1];
    final String range;
    if (start.year == end.year &&
        start.month == end.month &&
        start.day == end.day) {
      range = '${two(start.day)} $m1 ${start.year}';
    } else if (start.year == end.year && start.month == end.month) {
      range = '${two(start.day)} \u2013 ${two(end.day)} $m1 ${end.year}';
    } else {
      range = '${two(start.day)} $m1 \u2013 ${two(end.day)} $m2 ${end.year}';
    }
    final unit = days == 1 ? 'day' : 'days';
    return '$range \u00B7 $days $unit';
  }
}
