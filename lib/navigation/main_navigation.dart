import 'package:flutter/material.dart';
import 'package:flutter_sms/features/mission/presentation/mission_request_page.dart';
import 'package:flutter_sms/features/profile/profile_page.dart';

import '../features/home/presentation/home_page.dart';
import 'bottom_nav_bar.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  List<Widget> get _pages => [
        HomePage(
          onProfileTap: () => _selectPage(3),
          onCreateMission: _createMission,
        ),
        const Center(child: Text('Mission')),
        const Center(child: Text('Notification')),
        const ProfilePage(),
      ];

  void _selectPage(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _createMission() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MissionRequestPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onItemSelected: _selectPage,
        onCreateMission: _createMission,
      ),
    );
  }
}
