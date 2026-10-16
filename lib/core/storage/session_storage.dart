import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_sms/core/models/user_role.dart';
import 'package:flutter_sms/features/auth/data/models/login_respone.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stores who is logged in (role + name), next to the token.
class SessionStorage {
  static const String _roleKey = 'user_role';
  static const String _nameKey = 'user_name';

  Future<void> saveRole(UserRole role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_roleKey, role.code);
  }

  Future<UserRole?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return UserRole.tryParse(prefs.getString(_roleKey));
  }

  Future<void> saveName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name);
  }

  Future<String?> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nameKey);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_roleKey);
    await prefs.remove(_nameKey);
  }

  /// Preferred: read role + name from the login response body.
  /// Falls back to the JWT if the response has no recognisable role.
  Future<UserRole> saveFromLogin(LoginResponse login) async {
    final found = login.roles
        .map(UserRole.tryParse)
        .whereType<UserRole>()
        .toList();

    if (found.isEmpty) {
      return saveFromToken(
        login.token,
        fallbackName: login.fullName.isNotEmpty ? login.fullName : login.email,
      );
    }

    // If a user has several roles, prefer the non-staff one.
    final role = found.firstWhere((r) => !r.isStaff, orElse: () => found.first);
    await saveRole(role);

    final name = login.fullName.trim();
    await saveName(name.isNotEmpty ? name : (_nameFromEmail(login.email) ?? ''));
    return role;
  }

  /// Reads the role and name from the JWT token and saves them.
  /// TODO: once the login response JSON is known, read them from there instead.
  Future<UserRole> saveFromToken(String token, {String? fallbackName}) async {
    final claims = _decodeClaims(token);

    var role = _roleFromClaims(claims);
    if (role == null) {
      debugPrint('SessionStorage: no role found in token, defaulting to staff');
    }
    role ??= UserRole.staff;
    await saveRole(role);

    final name = _nameFromClaims(claims) ?? _nameFromEmail(fallbackName);
    if (name != null && name.isNotEmpty) await saveName(name);

    return role;
  }

  Map<String, dynamic>? _decodeClaims(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final json = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final data = jsonDecode(json);
      return data is Map<String, dynamic> ? data : null;
    } catch (_) {
      return null;
    }
  }

  UserRole? _roleFromClaims(Map<String, dynamic>? claims) {
    if (claims == null) return null;
    final found = <UserRole>[];
    for (final key in const ['role', 'roles', 'authorities', 'scope', 'scp']) {
      _collect(claims[key], found);
    }
    for (final r in found) {
      if (!r.isStaff) return r;
    }
    return found.isEmpty ? null : found.first;
  }

  void _collect(Object? value, List<UserRole> out) {
    if (value == null) return;
    if (value is String) {
      for (final part in value.split(RegExp(r'[\s,]+'))) {
        final r = UserRole.tryParse(part);
        if (r != null) out.add(r);
      }
    } else if (value is List) {
      for (final v in value) {
        _collect(v, out);
      }
    } else if (value is Map) {
      _collect(value['authority'] ?? value['name'], out);
    }
  }

  String? _nameFromClaims(Map<String, dynamic>? claims) {
    if (claims == null) return null;
    for (final key in const ['name', 'fullName', 'full_name', 'username']) {
      final v = claims[key];
      if (v is String && v.trim().isNotEmpty) return v.trim();
    }
    return null;
  }

  String? _nameFromEmail(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final base = value.contains('@') ? value.split('@').first : value;
    final words = base
        .split(RegExp(r'[._\-\s]+'))
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1));
    return words.join(' ');
  }
}
