import '../../features/mission/data/mission_repository.dart';
import '../../features/mission/data/models/create_mission_request.dart';
import 'dio_client.dart';

class ApiTest {
  static Future<void> testCreateMission() async {
    final repository = MissionRepository(DioClient());

    final request = CreateMissionRequest(
      position: 'Staff',
      functionName: 'IT',
      business: 'ONE MORE',
      jobLevel: 'STAFF',
      basedLocation: 'Phnom Penh',
      destinationLocation: 'Siem Reap',
      locationTier: 'TIER_3',
      travelObjectives:
          'Attend business meeting and support project activities',
      departureDate: '2026-10-06',
      departureTime: '07:00:00',
      arrivalDate: '2026-10-06',
      arrivalTime: '12:00:00',
      numberOfTravelDays: 1,
      description: 'Business trip to Siem Reap for project activities.',
      onBehalfOfUserId: 10003,
      missionType: 'INDIVIDUAL',
      participantIds: [],
    );
  }
}
