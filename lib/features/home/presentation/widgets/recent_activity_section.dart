import 'package:flutter/material.dart';

import '../../data/models/home_mission.dart';
import 'mission_card.dart';

class RecentActivitySection extends StatelessWidget {
  const RecentActivitySection({super.key, required this.missions});

  final List<HomeMission> missions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recent activity',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        for (final m in missions) ...[
          MissionCard(mission: m),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}
