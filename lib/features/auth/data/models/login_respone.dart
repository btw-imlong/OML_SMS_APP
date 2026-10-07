class LoginResponse {
  final String token;
  final String type;
  final int id;
  final String email;
  final String fullName;
  final List<String> roles;

  LoginResponse({
    required this.token,
    required this.type,
    required this.id,
    required this.email,
    required this.fullName,
    required this.roles,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'],
      type: json['type'],
      id: json['id'],
      email: json['email'],
      fullName: json['fullName'],
      roles: List<String>.from(json['roles'] ?? []),
    );
  }
}
