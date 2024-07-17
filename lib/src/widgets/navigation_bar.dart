import 'package:flutter/material.dart';
import 'package:domo/src/features/authentication/screens/login_pages/account.dart';
import 'package:domo/src/features/authentication/screens/login_pages/homepage.dart';
import 'package:domo/src/features/authentication/screens/login_pages/appointments.dart';


class BottomNavBar extends StatefulWidget {
  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _currentIndex = 1; // Set default page to Home

  final List<Widget> _pages = [
    AccountPage(),
    Homepage(),
    AppointmentsPage(),
  ];

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Account',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Appointments',
          ),
        ],
      ),
    );
  }
}
