class Profile {
  final String profilePhoto;
  final String name;
  final String jobTitle;
  final String employeeId;
  final String email;
  final String phone;
  final String department;
  final String level;
  final String baseLocation;
  final int totalMissions;
  final int approvedMissions;
  final int completeMissions;

  const Profile({
    required this.profilePhoto,
    required this.name,
    required this.jobTitle,
    required this.employeeId,
    required this.email,
    required this.phone,
    required this.department,
    required this.level,
    required this.baseLocation,
    required this.totalMissions,
    required this.approvedMissions,
    required this.completeMissions,
  });
}
