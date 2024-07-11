import 'package:domo/src/constants/OnboardingStrings.dart';
import 'package:domo/src/features/authentication/classes/onboardingModel.dart';
import 'package:domo/main.dart';
import 'package:domo/widgets/onboardingPage.dart';
import 'package:domo/src/constants/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:liquid_swipe/liquid_swipe.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

 class OnboardingScreen extends StatefulWidget {
   OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
    final controller = LiquidController();

    int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pages = [
      OnBoardingPage(
        model: OnboardingModel(
            title: OnboardingStrings.title1,
            description: OnboardingStrings.description1,
            image: OnboardingStrings.onboard1,
            color: AppTheme.caption,
            textColor: AppTheme.darkBackground,
            onboardingCounter: OnboardingStrings.onboardingCounter,
            height: size.height),
      ),
      OnBoardingPage(
        model: OnboardingModel(
            title: OnboardingStrings.title2,
            description: OnboardingStrings.description2,
            image: OnboardingStrings.onboard2,
            color: AppTheme.darkText,
            textColor: AppTheme.darkBackground,
            onboardingCounter: OnboardingStrings.onboardingCounter2,
            height: size.height),
      ),
      OnBoardingPage(
        model: OnboardingModel(
            title: OnboardingStrings.title3,
            description: OnboardingStrings.description3,
            image: OnboardingStrings.onboard3,
            color: const Color.fromARGB(255, 115, 136, 192),
            textColor: AppTheme.darkBackground,
            onboardingCounter: OnboardingStrings.onboardingCounter3,
            height: size.height),
      ),
    ];

    return Scaffold(
      body: Stack(
        children: [
          LiquidSwipe(
            slideIconWidget: const Icon(Icons.arrow_back_ios),
            enableSideReveal: true,
            pages: pages,
            liquidController: controller,
            onPageChangeCallback: OnPageChangeCallback,
          ),
          Positioned(
            top: 50,
            right: 20,
            child: TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MainApp(),
                  ),
                );
              },
              child: const Icon(
                Icons.close,
                color: AppTheme.darkBackground,
              ),
            ),
          ),
          Positioned(
              bottom: 30,
              left: size.width / 2 - 35,
              child: AnimatedSmoothIndicator(
                  activeIndex: controller.currentPage,
                  count: 3,
                  effect: const WormEffect(
                    dotWidth: 15,
                    dotHeight: 7,
                    activeDotColor:  Colors.white,
                    dotColor: Color.fromARGB(255, 70, 79, 97),
                  )))
        ],
      ),
    );

    
  }

OnPageChangeCallback(int activePageIndex) {
  setState(() {
    currentPage = activePageIndex;
  });
  }
}



