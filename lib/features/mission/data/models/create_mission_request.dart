class CreateMissionRequest {
  final String position;
  final String functionName;
  final String business;
  final String jobLevel;
  final String basedLocation;
  final String destinationLocation;
  final String locationTier;
  final String travelObjectives;
  final String departureDate;
  final String departureTime;
  final String arrivalDate;
  final String arrivalTime;
  final int numberOfTravelDays;
  final String description;
  final int? onBehalfOfUserId;
  final String missionType;
  final List<int> participantIds;

  CreateMissionRequest({
    required this.position,
    required this.functionName,
    required this.business,
    required this.jobLevel,
    required this.basedLocation,
    required this.destinationLocation,
    required this.locationTier,
    required this.travelObjectives,
    required this.departureDate,
    required this.departureTime,
    required this.arrivalDate,
    required this.arrivalTime,
    required this.numberOfTravelDays,
    required this.description,
    this.onBehalfOfUserId,
    required this.missionType,
    required this.participantIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'position': position,
      'functionName': functionName,
      'business': business,
      'jobLevel': jobLevel,
      'basedLocation': basedLocation,
      'destinationLocation': destinationLocation,
      'locationTier': locationTier,
      'travelObjectives': travelObjectives,
      'departureDate': departureDate,
      'departureTime': departureTime,
      'arrivalDate': arrivalDate,
      'arrivalTime': arrivalTime,
      'numberOfTravelDays': numberOfTravelDays,
      'description': description,
      'onBehalfOfUserId': onBehalfOfUserId,
      'missionType': missionType,
      'participantIds': participantIds,
    };
  }
}
