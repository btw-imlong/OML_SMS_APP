class MissionResponse {
  final int id;
  final String missionCode;
  final int requesterId;
  final String requesterName;

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

  final double? breakfastAmount;
  final int? breakfastQuantity;
  final double? breakfastTotal;

  final double? lunchAmount;
  final int? lunchQuantity;
  final double? lunchTotal;

  final double? dinnerAmount;
  final int? dinnerQuantity;
  final double? dinnerTotal;

  final double? accommodationAmountPerNight;
  final int? numberOfNightStay;
  final double? accommodationTotal;

  final double? totalExpense;

  final String description;
  final String status;
  final String? currentApprovalStep;

  final String createdAt;
  final String updatedAt;

  final String missionType;

  final List<MissionParticipant> participants;

  MissionResponse({
    required this.id,
    required this.missionCode,
    required this.requesterId,
    required this.requesterName,
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
    this.breakfastAmount,
    this.breakfastQuantity,
    this.breakfastTotal,
    this.lunchAmount,
    this.lunchQuantity,
    this.lunchTotal,
    this.dinnerAmount,
    this.dinnerQuantity,
    this.dinnerTotal,
    this.accommodationAmountPerNight,
    this.numberOfNightStay,
    this.accommodationTotal,
    this.totalExpense,
    required this.description,
    required this.status,
    this.currentApprovalStep,
    required this.createdAt,
    required this.updatedAt,
    required this.missionType,
    required this.participants,
  });

  factory MissionResponse.fromJson(Map<String, dynamic> json) {
    return MissionResponse(
      id: json['id'] as int,
      missionCode: json['missionCode'] as String,
      requesterId: json['requesterId'] as int,
      requesterName: json['requesterName'] as String,

      position: json['position'] as String,
      functionName: json['functionName'] as String,
      business: json['business'] as String,
      jobLevel: json['jobLevel'] as String,

      basedLocation: json['basedLocation'] as String,
      destinationLocation: json['destinationLocation'] as String,
      locationTier: json['locationTier'] as String,

      travelObjectives: json['travelObjectives'] as String,

      departureDate: json['departureDate'] as String,
      departureTime: json['departureTime'] as String,

      arrivalDate: json['arrivalDate'] as String,
      arrivalTime: json['arrivalTime'] as String,

      numberOfTravelDays: json['numberOfTravelDays'] as int,

      breakfastAmount: (json['breakfastAmount'] as num?)?.toDouble(),
      breakfastQuantity: json['breakfastQuantity'] as int?,
      breakfastTotal: (json['breakfastTotal'] as num?)?.toDouble(),

      lunchAmount: (json['lunchAmount'] as num?)?.toDouble(),
      lunchQuantity: json['lunchQuantity'] as int?,
      lunchTotal: (json['lunchTotal'] as num?)?.toDouble(),

      dinnerAmount: (json['dinnerAmount'] as num?)?.toDouble(),
      dinnerQuantity: json['dinnerQuantity'] as int?,
      dinnerTotal: (json['dinnerTotal'] as num?)?.toDouble(),

      accommodationAmountPerNight: (json['accommodationAmountPerNight'] as num?)
          ?.toDouble(),

      numberOfNightStay: json['numberOfNightStay'] as int?,

      accommodationTotal: (json['accommodationTotal'] as num?)?.toDouble(),

      totalExpense: (json['totalExpense'] as num?)?.toDouble(),

      description: json['description'] as String,
      status: json['status'] as String,
      currentApprovalStep: json['currentApprovalStep'] as String?,

      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,

      missionType: json['missionType'] as String,

      participants: (json['participants'] as List<dynamic>? ?? [])
          .map(
            (item) => MissionParticipant.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}

class MissionParticipant {
  final int id;
  final int employeeId;
  final String employeeCode;
  final String fullName;
  final String jobLevel;
  final String functionName;
  final String business;
  final bool requester;

  final double breakfastTotal;
  final double lunchTotal;
  final double dinnerTotal;
  final double accommodationTotal;
  final double totalExpense;

  MissionParticipant({
    required this.id,
    required this.employeeId,
    required this.employeeCode,
    required this.fullName,
    required this.jobLevel,
    required this.functionName,
    required this.business,
    required this.requester,
    required this.breakfastTotal,
    required this.lunchTotal,
    required this.dinnerTotal,
    required this.accommodationTotal,
    required this.totalExpense,
  });

  factory MissionParticipant.fromJson(Map<String, dynamic> json) {
    return MissionParticipant(
      id: json['id'] as int,
      employeeId: json['employeeId'] as int,
      employeeCode: json['employeeCode'] as String,
      fullName: json['fullName'] as String,
      jobLevel: json['jobLevel'] as String,
      functionName: json['functionName'] as String,
      business: json['business'] as String,
      requester: json['requester'] as bool,
      breakfastTotal: (json['breakfastTotal'] as num? ?? 0).toDouble(),
      lunchTotal: (json['lunchTotal'] as num? ?? 0).toDouble(),
      dinnerTotal: (json['dinnerTotal'] as num? ?? 0).toDouble(),
      accommodationTotal: (json['accommodationTotal'] as num? ?? 0).toDouble(),
      totalExpense: (json['totalExpense'] as num? ?? 0).toDouble(),
    );
  }
}
