import '../../../core/network/dio_client.dart';
import 'models/create_mission_request.dart';
import 'models/employee.dart';
import 'models/mission_response.dart';

class MissionRepository {
  final DioClient _dioClient;

  MissionRepository(this._dioClient);

  Future<MissionResponse> createMission(CreateMissionRequest request) async {
    final response = await _dioClient.dio.post(
      '/api/missions',
      data: request.toJson(),
    );

    final responseData = response.data as Map<String, dynamic>;

    final data = responseData['data'];

    if (data is Map<String, dynamic>) {
      return MissionResponse.fromJson(data);
    }

    return MissionResponse.fromJson(responseData);
  }

  Future<MissionResponse> getMission(int id) async {
    final response = await _dioClient.dio.get('/api/missions/$id');

    final responseData = response.data as Map<String, dynamic>;

    final data = responseData['data'];

    if (data is Map<String, dynamic>) {
      return MissionResponse.fromJson(data);
    }

    return MissionResponse.fromJson(responseData);
  }

  Future<List<MissionResponse>> getMissions() async {
    final response = await _dioClient.dio.get('/api/missions');

    final responseData = response.data as Map<String, dynamic>;

    final data = responseData['data'];

    if (data is Map<String, dynamic>) {
      final items = data['items'] as List<dynamic>? ?? [];

      return items
          .map((item) => MissionResponse.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    final items = responseData['items'] as List<dynamic>? ?? [];

    return items
        .map((item) => MissionResponse.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> deleteMission(int id) async {
    await _dioClient.dio.delete('/api/missions/$id');
  }

  Future<void> updateParticipants(
    int missionId,
    List<int> participantIds,
  ) async {
    await _dioClient.dio.put(
      '/api/missions/$missionId/participants',
      data: {'participantIds': participantIds},
    );
  }

  Future<List<Employee>> getEmployees() async {
    final response = await _dioClient.dio.get('/api/users');

    final responseData = response.data as Map<String, dynamic>;

    final data = responseData['data'];

    if (data is Map<String, dynamic>) {
      final items = data['items'] as List<dynamic>? ?? [];

      return items
          .map((item) => Employee.fromJson(item as Map<String, dynamic>))
          .where((employee) => employee.isActive)
          .toList();
    }

    return [];
  }
}
