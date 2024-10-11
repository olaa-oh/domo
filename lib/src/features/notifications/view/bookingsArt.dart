import 'package:domo/src/features/authentication/model/style_model.dart';
import 'package:domo/src/widgets/bookingCard.dart';
import 'package:flutter/material.dart';
import 'package:domo/src/features/booking/models/booking_model.dart';
import 'package:domo/src/data/auth_repository/booking_repository.dart';

class BookingsArt extends StatefulWidget {
  final String ownerId;
  const BookingsArt({Key? key, required this.ownerId}) : super(key: key);

  @override
  State<BookingsArt> createState() => _BookingsArtState();
}

class _BookingsArtState extends State<BookingsArt> {
  final BookingRepository _bookingRepository = BookingRepository();
  List<Booking> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }


  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Booking> bookings = await _bookingRepository.getOwnerBookings(widget.ownerId);
      setState(() {
        _bookings = bookings;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading bookings: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading bookings. Please try again.')),
      );
    }
  }

  Future<void> _approveBooking(Booking booking) async {
    String? note = await _showNoteDialog();
    if (note != null) {
      await _bookingRepository.updateBookingStatus(booking.id, BookingStatus.approved, note: note);
      // TODO: Add calendar invite logic here
      // TODO: Send notification to user
      _loadBookings();
    }
  }

  Future<void> _denyBooking(Booking booking) async {
    String? reason = await _showDenyDialog();
    if (reason != null) {
      await _bookingRepository.updateBookingStatus(booking.id, BookingStatus.denied, denialReason: reason);
      // TODO: Send notification to user
      _loadBookings();
    }
  }

  Future<String?> _showNoteDialog() async {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String note = '';
        return AlertDialog(
          title: const Text('Approve Booking'),
          content: TextField(
            decoration: const InputDecoration(hintText: "Enter a note for the customer"),
            onChanged: (value) => note = value,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Approve'),
              onPressed: () => Navigator.of(context).pop(note),
            ),
          ],
        );
      },
    );
  }

  Future<String?> _showDenyDialog() async {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String reason = '';
        return AlertDialog(
          title: const Text('Deny Booking'),
          content: TextField(
            decoration: const InputDecoration(hintText: "Enter reason for denial"),
            onChanged: (value) => reason = value,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Deny'),
              onPressed: () => Navigator.of(context).pop(reason),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.button,
      appBar: AppBar(
        title: const Text("Bookings"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bookings.isEmpty
              ? Center(child: Text('No bookings found'))
              : RefreshIndicator(
                  onRefresh: _loadBookings,
                  child: ListView.builder(
                    itemCount: _bookings.length,
                    itemBuilder: (context, index) {
                      final booking = _bookings[index];
                      return BookingCard(
                        booking: booking,
                        isArtisan: true,
                        onTap: booking.status == BookingStatus.pending
                            ? () => _showActionDialog(booking)
                            : null,
                      );
                    },
                  ),
                ),
    );
  }

  Future<void> _showActionDialog(Booking booking) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Booking Action'),
          content: const Text('Do you want to approve or deny this booking?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Deny'),
              onPressed: () {
                Navigator.of(context).pop();
                _denyBooking(booking);
              },
            ),
            TextButton(
              child: const Text('Approve'),
              onPressed: () {
                Navigator.of(context).pop();
                _approveBooking(booking);
              },
            ),
          ],
        );
      },
    );
  }
}