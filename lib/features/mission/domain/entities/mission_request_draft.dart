class MissionRequestDraft {
  final MissionType? missionType;

  const MissionRequestDraft({this.missionType});

  MissionRequestDraft copyWith({MissionType? missionType}) {
    return MissionRequestDraft(missionType: missionType ?? this.missionType);
  }
}

enum MissionType { individual, group }
