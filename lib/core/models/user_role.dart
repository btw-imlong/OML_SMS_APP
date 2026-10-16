/// Mirrors the backend enum: com.onemore.mission.user.domain.UserRole
enum UserRole {
  staff('ROLE_STAFF', 'Staff'),
  functionManager('ROLE_FUNCTION_MANAGER', 'Function Manager'),
  hrbp('ROLE_HRBP', 'HRBP'),
  finance('ROLE_FINANCE', 'Finance'),
  bizops('ROLE_BIZOPS', 'BizOps'),
  executive('ROLE_EXECUTIVE', 'Executive'),
  admin('ROLE_ADMIN', 'Admin');

  const UserRole(this.code, this.label);

  /// Value sent by the backend, e.g. ROLE_STAFF.
  final String code;
  final String label;

  bool get isStaff => this == UserRole.staff;

  /// Accepts "ROLE_STAFF" or "STAFF". Returns null if unknown.
  static UserRole? tryParse(String? raw) {
    if (raw == null) return null;
    var value = raw.trim().toUpperCase();
    if (value.isEmpty) return null;
    if (!value.startsWith('ROLE_')) value = 'ROLE_$value';
    for (final role in UserRole.values) {
      if (role.code == value) return role;
    }
    return null;
  }
}
