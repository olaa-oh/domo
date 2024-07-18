// main.dart
import 'package:domo/src/features/authentication/screens/login_pages/forget_password.dart';
import 'package:domo/src/features/authentication/screens/login_pages/homepage.dart';
import 'package:domo/src/features/authentication/screens/login_pages/otp.dart';
import 'package:domo/src/features/authentication/screens/login_pages/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:domo/src/constants/style.dart';
import 'package:domo/src/widgets/navigation_bar.dart';
import 'package:firebase_core/firebase_core.dart';

void main()  async {
  await Firebase.initializeApp();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme().light,
      // darkTheme: AppTheme().dark,
      // themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}