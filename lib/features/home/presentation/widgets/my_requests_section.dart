import 'package:flutter/material.dart';

import '../../../../app/app_colors.dart';

class MyRequestsSection extends StatelessWidget {
  const MyRequestsSection({
    super.key,
    required this.approvals,
    required this.myRequests,
    this.onViewAll,
  });

  final int approvals;
  final int myRequests;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('My Requests',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            GestureDetector(
              onTap: onViewAll,
              child: const Text('View all',
                  style: TextStyle(fontSize: 11, color: AppColors.primary)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                count: approvals,
                label: 'Approvals',
                icon: Icons.check_circle_outline,
                filled: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                count: myRequests,
                label: 'My Requests',
                icon: Icons.description_outlined,
                filled: false,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.count,
    required this.label,
    required this.icon,
    required this.filled,
  });

  final int count;
  final String label;
  final IconData icon;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final fg = filled ? Colors.white : AppColors.textPrimary;

    return Container(
      height: 124,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: filled ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: filled ? null : Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: filled ? Colors.white24 : AppColors.approvedBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon,
                size: 18, color: filled ? Colors.white : AppColors.approvedFg),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$count',
                  style: TextStyle(
                      fontSize: 26,
                      height: 1.1,
                      fontWeight: FontWeight.w800,
                      color: fg)),
              Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      color:
                          filled ? Colors.white70 : AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}
