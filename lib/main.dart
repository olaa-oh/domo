// main.dart
import 'package:domo/src/features/authentication/pages/homepage.dart';
import 'package:domo/src/features/authentication/pages/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:domo/src/constants/style.dart';
import 'package:domo/src/widgets/navigation_bar.dart';

void main() {
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
      home: SplashScreen(),
    );
  }
}