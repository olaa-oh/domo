// homepage.dart
import 'package:domo/src/constants/style.dart';
// import 'package:domo/widgets/navigation_bar.dart';
import 'package:flutter/material.dart';

class Homepage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Homepage',
          style: AppTheme.textTheme.bodyLarge,
        ),
      ),
      // bottomNavigationBar: BottomNavBar(),
    );
  }
}
