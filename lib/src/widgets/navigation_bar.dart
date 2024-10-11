import 'package:domo/src/features/authentication/view/account.dart';
import 'package:domo/src/features/notifications/view/bookingsArt.dart';
import 'package:domo/src/features/booking/view/appointments.dart';
import 'package:domo/src/features/shop/view/my_shop_page.dart';
import 'package:domo/src/features/shop/view/shops.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BottomNavBar extends StatefulWidget {
  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _currentIndex = 0; // Set default page to Account
  String? _userRole;
  String? _shopId;
  bool _mounted = true;

  @override
  void initState() {
    super.initState();
    _getUserRoleAndShopId();
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  Future<void> _getUserRoleAndShopId() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.email)
          .get();
      
      String? shopId = await _getShopId();
      
      if (_mounted) {
        setState(() {
          _userRole = userDoc['role'];
          _shopId = shopId;
        });
      }
    }
  }

  Future<String?> _getShopId() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null && _userRole == 'artisan') {
    QuerySnapshot shopQuery = await FirebaseFirestore.instance
        .collection('shops')
        .where('ownerId', isEqualTo: user.email)
        .limit(1)
        .get();

    if (shopQuery.docs.isNotEmpty) {
      return shopQuery.docs.first.id;
    }
  }
  return null;
}



List<Widget> _getPages() {
  if (_userRole == 'artisan') {
    return [
      ProfilePage(),
      ShopDetailsPage(ownerId: FirebaseAuth.instance.currentUser!.email!),
      BookingsArt(ownerId: FirebaseAuth.instance.currentUser!.email!) ,
    ];
  } else {
    return [
      ProfilePage(),
      const ShopsPage(),
      const AppointmentsPage(),
    ];
  }
}

  List<BottomNavigationBarItem> _getNavBarItems() {
    if (_userRole == 'artisan') {
      return [
        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Account',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.business),
          label: 'My Shop',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Bookings',
        ),
      ];
    } else {
      return [
        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Account',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.store),
          label: 'Shops',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Appointments',
        ),
      ];
    }
  }

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _userRole == null
          ? const Center(child: CircularProgressIndicator())
          : IndexedStack(
              index: _currentIndex,
              children: _getPages(),
            ),
      bottomNavigationBar: _userRole == null
          ? null
          : BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: _onTap,
              items: _getNavBarItems(),
              type: BottomNavigationBarType.fixed,
            ),
    );
  }
}
