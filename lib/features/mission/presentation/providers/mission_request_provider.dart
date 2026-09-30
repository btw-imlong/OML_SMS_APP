import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/mission_request_draft.dart';

final missionRequestProvider =
    NotifierProvider<MissionRequestNotifier, MissionRequestDraft>(
      MissionRequestNotifier.new,
    );

class MissionRequestNotifier extends Notifier<MissionRequestDraft> {
  @override
  MissionRequestDraft build() {
    return const MissionRequestDraft();
  }

  void setMissionType(MissionType type) {
    state = state.copyWith(missionType: type);
  }
}
