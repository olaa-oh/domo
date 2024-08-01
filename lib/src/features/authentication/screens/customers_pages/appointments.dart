import 'package:domo/src/widgets/bookingCard.dart';
import 'package:flutter/material.dart';
import 'package:domo/src/constants/booking_model.dart';
import 'package:domo/src/constants/style.dart';
import 'package:domo/src/auth_repository/booking_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({Key? key}) : super(key: key);

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  final BookingRepository _bookingRepository = BookingRepository();
  List<Booking> _bookings = [];
  bool _isLoading = true;
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    _loadBookings();
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

Future _loadBookings() async {
  if (!_isMounted) return;

  setState(() {
    _isLoading = true;
  });

  try {
    String userEmail = FirebaseAuth.instance.currentUser?.email ?? '';
    print('Fetching bookings for user email: $userEmail');
    
    List<Booking> bookings = await _bookingRepository.getUserBookings(userEmail);
    print('Fetched ${bookings.length} bookings');

    for (var booking in bookings) {
      print('Booking: ${booking.id}, Shop: ${booking.shopId}, Date: ${booking.bookingDate}, Status: ${booking.status}');
    }

    if (_isMounted) {
      setState(() {
        _bookings = bookings;
        _isLoading = false;
      });
    }
  } catch (e) {
    print('Error loading bookings: $e');
    if (_isMounted) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading bookings: $e')),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    backgroundColor: AppTheme.button,
      appBar: AppBar(
        title: Text('Appointments', style: AppTheme.textTheme.headlineSmall),
      ),
      body: RefreshIndicator(
        onRefresh: _loadBookings,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _bookings.isEmpty
                ? const Center(child: Text('No booked appointments yet'))
                : ListView.builder(
                    itemCount: _bookings.length,
                    itemBuilder: (context, index) {
                      return BookingCard(
                        booking: _bookings[index],
                        onTap: () {
                          
                        },
                      );
                    },
                  ),
      ),
    );
  }
}