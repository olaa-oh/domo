// splash screen
import 'package:domo/src/features/authentication/screens/login_pages/onboarding_screen.dart';
import 'package:domo/src/widgets/navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:domo/src/constants/style.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  @override
@override
void initState() {
  super.initState();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  Future.delayed(const Duration(seconds: 4), () {
    if (mounted) {  // Add this check
      Get.off(() => OnboardingScreen());
    }
  });
}
  @override
  void dispose() {
    // TODO: implement dispose
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: prefer_const_constructors
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Center(
            child: Image(
              image: AssetImage(
                "assets/images/flashscreen.png",
              ),
              fit: BoxFit.cover,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Text(
              "Do More",
              style: AppTheme.textTheme.headlineSmall,
            ),
          ),
        ],
      ),
    );
  }
}
