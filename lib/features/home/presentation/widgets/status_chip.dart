import 'package:flutter/material.dart';

import '../../../../app/app_colors.dart';
import '../../data/models/home_mission.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final HomeMissionStatus status;

  @override
  Widget build(BuildContext context) {
    late String label;
    late Color bg;
    late Color fg;

    switch (status) {
      case HomeMissionStatus.approved:
        label = 'Approved';
        bg = AppColors.approvedBg;
        fg = AppColors.approvedFg;
        break;
      case HomeMissionStatus.draft:
        label = 'DRAFT';
        bg = AppColors.draftBg;
        fg = AppColors.draftFg;
        break;
      case HomeMissionStatus.completed:
        label = 'COMPLETED';
        bg = AppColors.completedBg;
        fg = AppColors.completedFg;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(label,
          style:
              TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }
}