enum HomeMissionStatus { approved, draft, completed }

class HomeMission {
  const HomeMission({
    required this.title,
    required this.location,
    required this.dateText,
    required this.travelText,
    required this.footerNote,
    required this.amount,
    required this.status,
    this.code,
  });

  final String? code;
  final String title;
  final String location;
  final String dateText;
  final String travelText;
  final String footerNote;
  final double amount;
  final HomeMissionStatus status;
}