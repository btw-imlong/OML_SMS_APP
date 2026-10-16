import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_sms/core/models/user_role.dart';
import 'package:flutter_sms/core/network/dio_client.dart';
import 'package:flutter_sms/features/home/data/home_mission.dart';
import 'package:flutter_sms/features/mission/domain/entities/mission_status.dart';

/// Loads missions from GET /api/missions, newest change first.
class HomeMissionSource {
  HomeMissionSource() : _dio = DioClient().dio;

  final Dio _dio;
  int? _myId;

  Future<List<HomeMission>> fetchMissions(UserRole role) async {
    try {
      final res = await _dio.get('/api/missions');
      final all = _extractList(res.data)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

      final me = await _currentUserId();

      final visible = all.where((j) {
        final isDraft = _status(j) == MissionStatus.draft;
        if (me == null) return role.isStaff || !isDraft;
        final mine = _isMine(j, me);
        // Staff: only their own. Others: everything except other people's drafts.
        return role.isStaff ? mine : (mine || !isDraft);
      }).toList()
        ..sort(_newestFirst);

      return visible.map(HomeMission.fromApi).toList();
    } catch (e) {
      debugPrint('HomeMissionSource.fetchMissions failed: $e');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------

  Future<int?> _currentUserId() async {
    if (_myId != null) return _myId;
    try {
      final res = await _dio.get('/api/auth/me');
      var body = res.data;
      if (body is String) body = jsonDecode(body);
      if (body is Map) {
        final src = body['data'] is Map ? body['data'] as Map : body;
        _myId = _toInt(src['id']);
      }
    } catch (_) {}
    return _myId;
  }

  bool _isMine(Map<String, dynamic> j, int me) {
    if (_toInt(j['requesterId']) == me) return true;
    final p = j['participants'];
    if (p is List) {
      for (final x in p) {
        if (x is Map && _toInt(x['employeeId']) == me) return true;
      }
    }
    return false;
  }

  MissionStatus _status(Map<String, dynamic> j) =>
      MissionStatus.tryParse(j['status']?.toString()) ?? MissionStatus.draft;

  /// Newest created/changed first.
  int _newestFirst(Map<String, dynamic> a, Map<String, dynamic> b) {
    final x = _stamp(a);
    final y = _stamp(b);
    if (x != null && y != null) {
      final c = y.compareTo(x);
      if (c != 0) return c;
    } else if (x != null) {
      return -1;
    } else if (y != null) {
      return 1;
    }
    return (_toInt(b['id']) ?? 0).compareTo(_toInt(a['id']) ?? 0);
  }

  DateTime? _stamp(Map<String, dynamic> j) =>
      DateTime.tryParse('${j['updatedAt'] ?? ''}') ??
      DateTime.tryParse('${j['createdAt'] ?? ''}');

  int? _toInt(dynamic v) => v is num ? v.toInt() : int.tryParse('$v');

  /// Accepts a plain list, or {data: [...]}, {items: [...]}, {content: [...]}.
  List<dynamic> _extractList(dynamic body) {
    if (body is String) {
      try {
        body = jsonDecode(body);
      } catch (_) {
        return const [];
      }
    }
    if (body is List) return body;
    if (body is Map) {
      for (final key in const ['data', 'items', 'content', 'missions']) {
        final v = body[key];
        if (v is List) return v;
        if (v is Map) {
          final inner = _extractList(v);
          if (inner.isNotEmpty) return inner;
        }
      }
    }
    return const [];
  }
}
