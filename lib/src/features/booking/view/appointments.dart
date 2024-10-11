import 'package:domo/src/widgets/bookingCard.dart';
import 'package:flutter/material.dart';
import 'package:domo/src/features/booking/models/booking_model.dart';
import 'package:domo/src/features/authentication/model/style_model.dart';
import 'package:domo/src/data/auth_repository/booking_repository.dart';
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

  Future<void> _loadBookings() async {
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
        child: Stack(
          children: [
            ListView(
              children: _isLoading
                  ? [
                      SizedBox(
                        height: MediaQuery.of(context).size.height - AppBar().preferredSize.height,
                        child: const Center(child: CircularProgressIndicator()),
                      )
                    ]
                  : _bookings.isEmpty
                      ? [
                          SizedBox(
                            height: MediaQuery.of(context).size.height - AppBar().preferredSize.height,
                            child: const Center(child: Text('No booked appointments yet')),
                          )
                        ]
                      : _bookings.map((booking) => BookingCard(
                            booking: booking,
                            onTap: () {
                              // Handle tap
                            },
                          )).toList(),
            ),
            if (_isLoading)
              const Positioned.fill(
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}