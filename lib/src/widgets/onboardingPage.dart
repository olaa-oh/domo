
import 'package:domo/classes/OnboardingStrings.dart';
import 'package:domo/classes/onboardingModel.dart';
import 'package:domo/styles/style.dart';
import 'package:flutter/material.dart';

class OnBoardingPage extends StatelessWidget {
  const OnBoardingPage({
    super.key,
    required this.model,
  });

  final OnboardingModel model;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: model.color,
      child: Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 20),
        child: Column(
          children: [
            SizedBox(
              height: model.height * 0.05,
            ),
            // Text(model.onboardingCounter, style: AppTheme.textTheme.bodyMedium?.copyWith(color: model.textColor)),
            SizedBox(
              height: model.height * 0.05,
            ),
            Text(
              model.title,
              style: AppTheme.textTheme.headlineMedium?.copyWith(color: model.textColor),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: model.height * 0.05,
            ),
            Text(
              model.description,
              style: AppTheme.textTheme.titleLarge?.copyWith(color: model.textColor),
            ),
            Spacer(
              flex: 1,
            ),
            Image(
              height: model.height * 0.45,
              image: AssetImage(model.image),
              fit: BoxFit.fill,
            ),
          ],
        ),
      ),
    );
  }
}
