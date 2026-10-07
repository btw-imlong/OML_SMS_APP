class Employee {
  final int id;
  final String employeeCode;
  final String fullName;
  final String email;
  final String jobLevel;
  final String functionName;
  final String business;
  final bool isActive;
  final List<String> roles;

  const Employee({
    required this.id,
    required this.employeeCode,
    required this.fullName,
    required this.email,
    required this.jobLevel,
    required this.functionName,
    required this.business,
    required this.isActive,
    required this.roles,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] as int,
      employeeCode: json['employeeCode'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      jobLevel: json['jobLevel'] as String? ?? '',
      functionName: json['functionName'] as String? ?? '',
      business: json['business'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? false,
      roles: (json['roles'] as List<dynamic>? ?? [])
          .map((role) => role.toString())
          .toList(),
    );
  }
}
