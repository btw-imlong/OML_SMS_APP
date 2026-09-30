class MissionRequest {
  final String? missionCode;
  final int requesterId;
  final String requesterName;
  final String position;
  final String function;
  final String business;
  final JobLevel jobLevel;

  final String basedLocation;
  final String destinationLocation;
  final LocationTier locationTier;

  final String travelObjectives;

  final DateTime departureDate;
  final DateTime? departureTime;
  final DateTime arrivalDate;
  final DateTime? arrivalTime;

  final int numberOfTravelDays;

  const MissionRequest({
    this.missionCode,
    required this.requesterId,
    required this.requesterName,
    required this.position,
    required this.function,
    required this.business,
    required this.jobLevel,
    required this.basedLocation,
    required this.destinationLocation,
    required this.locationTier,
    required this.travelObjectives,
    required this.departureDate,
    this.departureTime,
    required this.arrivalDate,
    this.arrivalTime,
    required this.numberOfTravelDays,
  });
}

enum JobLevel { executive, functionManager, subFunctionManager, staff, driver }

enum LocationTier { tier1, tier2, tier3 }
