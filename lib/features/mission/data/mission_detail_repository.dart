import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_sms/core/network/dio_client.dart';
import 'package:flutter_sms/features/mission/domain/entities/mission_status.dart';

class DetailParticipant {
  const DetailParticipant({
    required this.fullName,
    required this.employeeCode,
    required this.jobLevel,
    required this.functionName,
    required this.requester,
    required this.totalExpense,
  });

  final String fullName;
  final String employeeCode;
  final String jobLevel;
  final String functionName;
  final bool requester;
  final double totalExpense;
}

class MissionDetail {
  const MissionDetail({
    required this.id,
    required this.code,
    required this.requesterName,
    required this.position,
    required this.functionName,
    required this.business,
    required this.jobLevel,
    required this.locationTier,
    required this.basedLocation,
    required this.destination,
    required this.objectives,
    required this.description,
    required this.departureDate,
    required this.arrivalDate,
    required this.departureTime,
    required this.arrivalTime,
    required this.days,
    required this.breakfast,
    required this.lunch,
    required this.dinner,
    required this.accommodationPerNight,
    required this.nights,
    required this.accommodationTotal,
    required this.totalExpense,
    required this.status,
    required this.currentStep,
    required this.missionType,
    required this.participants,
  });

  final int id;
  final String code;
  final String requesterName;
  final String position;
  final String functionName;
  final String business;
  final String jobLevel;
  final String locationTier;
  final String basedLocation;
  final String destination;
  final String objectives;
  final String description;
  final DateTime? departureDate;
  final DateTime? arrivalDate;
  final String? departureTime;
  final String? arrivalTime;
  final int days;
  final Meal breakfast;
  final Meal lunch;
  final Meal dinner;
  final double accommodationPerNight;
  final int nights;
  final double accommodationTotal;
  final double totalExpense;
  final MissionStatus status;
  final String currentStep;
  final String missionType;
  final List<DetailParticipant> participants;

  double get mealTotal => breakfast.total + lunch.total + dinner.total;

  static double _d(dynamic v) =>
      v is num ? v.toDouble() : double.tryParse('${v ?? ''}') ?? 0;
  static int _i(dynamic v) =>
      v is num ? v.toInt() : int.tryParse('${v ?? ''}') ?? 0;
  static String _s(dynamic v) => v?.toString().trim() ?? '';

  /// Handles {hour, minute}, [h, m] and "08:00:00".
  static String? _time(dynamic v) {
    int? h;
    int? m;
    if (v is Map) {
      h = int.tryParse('${v['hour']}');
      m = int.tryParse('${v['minute']}');
    } else if (v is List && v.length >= 2) {
      h = int.tryParse('${v[0]}');
      m = int.tryParse('${v[1]}');
    } else if (v is String) {
      final p = v.split(':');
      if (p.length >= 2) {
        h = int.tryParse(p[0]);
        m = int.tryParse(p[1]);
      }
    }
    if (h == null || m == null) return null;
    final ap = h >= 12 ? 'PM' : 'AM';
    final h12 = h % 12 == 0 ? 12 : h % 12;
    return '$h12:${m.toString().padLeft(2, '0')} $ap';
  }

  factory MissionDetail.fromJson(Map<String, dynamic> j) {
    Meal meal(String k) => Meal(
          amount: _d(j['${k}Amount']),
          quantity: _i(j['${k}Quantity']),
          total: _d(j['${k}Total']),
        );

    final people = <DetailParticipant>[];
    final raw = j['participants'];
    if (raw is List) {
      for (final p in raw) {
        if (p is! Map) continue;
        people.add(DetailParticipant(
          fullName: _s(p['fullName']),
          employeeCode: _s(p['employeeCode']),
          jobLevel: _s(p['jobLevel']),
          functionName: _s(p['functionName']),
          requester: p['requester'] == true,
          totalExpense: _d(p['totalExpense']),
        ));
      }
    }

    return MissionDetail(
      id: _i(j['id']),
      code: _s(j['missionCode']),
      requesterName: _s(j['requesterName']),
      position: _s(j['position']),
      functionName: _s(j['functionName']),
      business: _s(j['business']),
      jobLevel: _s(j['jobLevel']),
      locationTier: _s(j['locationTier']),
      basedLocation: _s(j['basedLocation']),
      destination: _s(j['destinationLocation']),
      objectives: _s(j['travelObjectives']),
      description: _s(j['description']),
      departureDate: DateTime.tryParse(_s(j['departureDate'])),
      arrivalDate: DateTime.tryParse(_s(j['arrivalDate'])),
      departureTime: _time(j['departureTime']),
      arrivalTime: _time(j['arrivalTime']),
      days: _i(j['numberOfTravelDays']),
      breakfast: meal('breakfast'),
      lunch: meal('lunch'),
      dinner: meal('dinner'),
      accommodationPerNight: _d(j['accommodationAmountPerNight']),
      nights: _i(j['numberOfNightStay']),
      accommodationTotal: _d(j['accommodationTotal']),
      totalExpense: _d(j['totalExpense']),
      status: MissionStatus.tryParse(_s(j['status'])) ?? MissionStatus.draft,
      currentStep: _s(j['currentApprovalStep']),
      missionType: _s(j['missionType']),
      participants: people,
    );
  }
}

class Meal {
  const Meal({required this.amount, required this.quantity, required this.total});
  final double amount;
  final int quantity;
  final double total;
  bool get eligible => quantity > 0 || total > 0;
}

class MissionDetailRepository {
  MissionDetailRepository() : _dio = DioClient().dio;

  final Dio _dio;

  /// GET /api/missions/{id}
  Future<MissionDetail> fetch(int id) async {
    final res = await _dio.get('/api/missions/$id');
    var body = res.data;
    if (body is String) body = jsonDecode(body);
    var map = Map<String, dynamic>.from(body as Map);
    if (map['data'] is Map) map = Map<String, dynamic>.from(map['data'] as Map);
    return MissionDetail.fromJson(map);
  }
}
