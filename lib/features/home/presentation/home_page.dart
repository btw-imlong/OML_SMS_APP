import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';
import '../data/home_mock_data.dart';
import 'widgets/announcement_banner.dart';
import 'widgets/create_mission_button.dart';
import 'widgets/home_header.dart';
import 'widgets/my_requests_section.dart';
import 'widgets/recent_activity_section.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    this.onProfileTap,
    this.onCreateMission,
  });

  final VoidCallback? onProfileTap;
  final VoidCallback? onCreateMission;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          HomeHeader(
            userName: HomeMockData.userName,
            onProfileTap: onProfileTap,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const AnnouncementBanner(
                  title: 'Company Announcement',
                  subtitle: 'Annual meeting scheduled for next Friday.',
                  imagePath: 'assets/images/meeting_image.jpg',
                ),
                const SizedBox(height: 20),
                MyRequestsSection(
                  approvals: HomeMockData.approvals,
                  myRequests: HomeMockData.myRequests,
                  onViewAll: () {},
                ),
                const SizedBox(height: 16),
                CreateMissionButton(onPressed: onCreateMission ?? () {}),
                const SizedBox(height: 22),
                const RecentActivitySection(
                    missions: HomeMockData.recentMissions),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
