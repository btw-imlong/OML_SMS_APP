import 'models/home_mission.dart';

class HomeMockData {
  HomeMockData._();

  static const userName = 'Admin User';
  static const approvals = 12;
  static const myRequests = 5;

  static const recentMissions = <HomeMission>[
    HomeMission(
      title: 'Customer experience workshop — Kampot branch',
      location: 'Kampot, Kampot',
      dateText: '21 Sep 2026 · 1 day',
      travelText: 'Individual · Company Vehicle',
      footerNote: 'Dates updated',
      amount: 18.00,
      status: HomeMissionStatus.approved,
    ),
    HomeMission(
      code: 'MSN-2026-0155',
      title: 'Coastal POP inspection — Sihanoukville',
      location: 'Sihanoukville, Preah Sihanouk',
      dateText: '06 – 07 Oct 2026 · 2 days',
      travelText: 'Individual · Contracted Transport',
      footerNote: 'Not submitted yet',
      amount: 68.00,
      status: HomeMissionStatus.draft,
    ),
    HomeMission(
      code: 'MSN-2026-0139',
      title: 'Fibre fault escalation support — KampongCham',
      location: 'Kampong Cham, Kampong Cham',
      dateText: '03 – 04 Sep 2026 · 2 days',
      travelText: 'Individual · Company Shuttle',
      footerNote: '2-day mission',
      amount: 62.00,
      status: HomeMissionStatus.completed,
    ),
  ];
}