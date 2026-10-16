class UserProfile {
  final int id;
  final String email;
  final String fullName;
  final String jobLevel;
  final List<String> roles;
  final String? employeeCode;
  final String? functionName;
  final String? business;

  const UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    required this.jobLevel,
    required this.roles,
    this.employeeCode,
    this.functionName,
    this.business,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    String? opt(dynamic v) {
      final s = v?.toString().trim();
      return (s == null || s.isEmpty) ? null : s;
    }

    return UserProfile(
      id: (json['id'] as num?)?.toInt() ?? 0,
      email: json['email']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      jobLevel: json['jobLevel']?.toString() ?? '',
      roles: List<String>.from(json['roles'] ?? const []),
      employeeCode: opt(json['employeeCode']),
      functionName: opt(json['functionName']),
      business: opt(json['business']),
    );
  }

  /// employeeCode from the backend, or E-001 built from the id.
  String get employeeId =>
      employeeCode ?? 'E-${id.toString().padLeft(3, '0')}';

  String get initials {
    final words =
        fullName.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '?';
    if (words.length == 1) return words.first[0].toUpperCase();
    return (words.first[0] + words[1][0]).toUpperCase();
  }
}
