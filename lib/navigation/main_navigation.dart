import 'package:flutter/material.dart';
import 'package:flutter_sms/features/mission/presentation/mission_request_page.dart';
import 'package:flutter_sms/features/profile/profile_page.dart';

import '../features/home/home_page.dart';
import 'bottom_nav_bar.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    Center(child: Text('Mission')),
    Center(child: Text('Notification')),
    ProfilePage(),
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
