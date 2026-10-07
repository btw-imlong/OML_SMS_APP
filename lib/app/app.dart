import 'package:flutter/material.dart';

import 'package:flutter_sms/features/auth/presentation/splash_screen.dart';

import 'theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Staff Mission System',
      theme: AppTheme.lightTheme,
      home: const SplashPage(),
    );
  }
}
