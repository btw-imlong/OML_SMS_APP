import 'package:flutter/material.dart';
import 'package:flutter_sms/features/mission/presentation/mission_request_page.dart';
import 'package:flutter_sms/features/profile/profile_page.dart';

import '../features/home/home_page.dart';
import 'package:flutter_sms/core/models/user_role.dart';
import 'package:flutter_sms/features/approver/approver_home_page.dart';

import 'package:flutter_sms/features/home/data/mission_refresh.dart';
import 'bottom_nav_bar.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key, this.role = UserRole.staff});

  final UserRole role;

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  late final List<Widget> _pages = [
    widget.role.isStaff
        ? const HomePage()
        : ApproverHomePage(role: widget.role, onSeeAll: () => _selectPage(1)),
    const Center(child: Text('Mission')),
    const Center(child: Text('Notification')),
    const ProfilePage(),
  ];

  void _selectPage(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _createMission() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MissionRequestPage()),
    );
    // Back from the create page: reload the home list.
    notifyMissionsChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],

      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onItemSelected: _selectPage,
        onCreateMission: _createMission,
        approver: !widget.role.isStaff,
      ),
    );
  }
}
