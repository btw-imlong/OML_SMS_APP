import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_sms/features/auth/presentation/language_selection_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LanguageSelectionPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          width: 170,
          height: 170,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF1B4587),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              85,
            ), // Half of 170 width to make a perfect circle
            child: Image.asset(
              'assets/images/logo.png', // 👈 Put your asset path here!
              fit: BoxFit.cover, // Scales the image to fill the circular container neatly
            ),
          ),
        ),
      ),
    );
  }
}
