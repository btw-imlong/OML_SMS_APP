import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/profile_model.dart';

final profileProvider = Provider<Profile>((ref) {
  return const Profile(
    profilePhoto: 'https://img.magnific.com/free-vector/young-man-black-shirt_1308-173618.jpg?semt=ais_hybrid&w=740&q=80',
    name: 'Sreyleak Chan',
    jobTitle: 'Network Operations Specialist',
    employeeId: 'E-001',
    email: 'sreyleak.chan@company.com.kh',
    phone: '+855 12 263986',
    baseLocation: 'HQ — Phnom Penh (Norodom Blvd)',
    level: 'G4 · SENIOR OFFICER',
    department: 'TECHNOLOGY OPERATIONS',
    totalMissions: 6,
    approvedMissions: 2,
    completeMissions: 1,
  );
});
