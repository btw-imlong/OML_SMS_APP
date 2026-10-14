import 'package:flutter/material.dart';

import '../../../../app/app_colors.dart';
import '../../data/models/home_mission.dart';
import 'status_chip.dart';

class MissionCard extends StatelessWidget {
  const MissionCard({super.key, required this.mission, this.onTap});

  final HomeMission mission;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (mission.code != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(mission.code!,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textSecondary)),
                  StatusChip(status: mission.status),
                ],
              )
            else
              Align(
                alignment: Alignment.centerRight,
                child: StatusChip(status: mission.status),
              ),
            const SizedBox(height: 4),
            Text(mission.title,
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            _InfoRow(icon: Icons.location_on_outlined, text: mission.location),
            _InfoRow(
                icon: Icons.calendar_today_outlined, text: mission.dateText),
            _InfoRow(
                icon: Icons.directions_car_outlined, text: mission.travelText),
            const Divider(height: 20, color: AppColors.border),
            Row(
              children: [
                Text(mission.footerNote,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
                const Spacer(),
                Text('\$${mission.amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w800)),
                const Icon(Icons.chevron_right,
                    size: 16, color: AppColors.textSecondary),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }
}