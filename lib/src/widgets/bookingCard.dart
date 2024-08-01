import 'package:domo/src/auth_repository/booking_repository.dart';
import 'package:flutter/material.dart';
import 'package:domo/src/constants/booking_model.dart';
import 'package:domo/src/constants/style.dart';

class BookingCard extends StatefulWidget {
  final BookingRepository _bookingRepository = BookingRepository();
  final Booking booking;
  final VoidCallback? onTap;
  final bool isArtisan;

  BookingCard({
    Key? key,
    required this.booking,
    this.onTap,
    this.isArtisan = false,
  }) : super(key: key);

  @override
  State<BookingCard> createState() => _BookingCardState();
}

class _BookingCardState extends State<BookingCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: InkWell(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.isArtisan
                        ? 'Booking from ${widget.booking.userEmail}'
                        : 'Booking for ${widget.booking.shopName}',
                    style: AppTheme.textTheme.titleMedium!
                        .copyWith(fontWeight: FontWeight.bold, color: AppTheme.button),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _showEditDialog,
                        child: const Icon(
                          Icons.edit,
                          color: AppTheme.button,
                        ),
                      ),
                      if (!widget.isArtisan) ...[
                        SizedBox(width: 16),
                        GestureDetector(
                          onTap: _showDeleteConfirmationDialog,
                          child: const Icon(
                            Icons.delete_outline,
                            color: AppTheme.button,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Date: ${_formatDateTime(widget.booking.bookingDate)}',
                style: AppTheme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Status: ${widget.booking.status.toString().split('.').last}',
                    style: AppTheme.textTheme.bodyMedium?.copyWith(
                      color: _getStatusColor(widget.booking.status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.isArtisan && widget.booking.status == BookingStatus.pending)
                    Row(
                      children: [
        
                        IconButton(
                          icon: const Icon(Icons.more_horiz, color: AppTheme.button),
                          onPressed: widget.onTap,
                        ),
                        
                        // IconButton(
                        //   icon: const Icon(Icons.close, color: Colors.red),
                        //   onPressed: widget.onTap,
                        // ),
                      ],
                    ),
                ],
              ),
              if (widget.booking.note != null && widget.booking.note!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Note: ${widget.booking.note}',
                    style: AppTheme.textTheme.bodySmall,
                  ),
                ),
              if (widget.booking.status == BookingStatus.denied &&
                  widget.booking.denialReason != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Reason for denial: ${widget.booking.denialReason}',
                    style: AppTheme.textTheme.bodySmall
                        ?.copyWith(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this booking?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                _deleteBooking();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteBooking() async {
    try {
      await widget._bookingRepository.deleteBooking(widget.booking.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking deleted successfully')),
      );
      // You might want to refresh the list of bookings here
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting booking: $e')),
      );
    }
  }

  Future<void> _showEditDialog() async {
    DateTime editDate = widget.booking.bookingDate;
    TimeOfDay editTime = TimeOfDay.fromDateTime(widget.booking.bookingDate);

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Edit Booking'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text('Date: ${editDate.toString().split(' ')[0]}'),
                    ElevatedButton(
                      onPressed: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: editDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(Duration(days: 365)),
                        );
                        if (picked != null && picked != editDate) {
                          setState(() {
                            editDate = picked;
                          });
                        }
                      },
                      child: Text('Change Date'),
                    ),
                    SizedBox(height: 16),
                    Text('Time: ${_formatTime(editTime)}'),
                    ElevatedButton(
                      onPressed: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: editTime,
                        );
                        if (picked != null && picked != editTime) {
                          setState(() {
                            editTime = picked;
                          });
                        }
                      },
                      child: Text('Change Time'),
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Save'),
                  onPressed: () {
                    _updateBooking(editDate, editTime);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _updateBooking(DateTime date, TimeOfDay time) async {
    final updatedBooking = widget.booking.copyWith(
      bookingDate: DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      ),
    );

    try {
      await widget._bookingRepository.updateBooking(updatedBooking);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking updated successfully')),
      );
      // Refresh the booking card
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating booking: $e')),
      );
    }
  }
  
  String _formatDateTime(DateTime dateTime) {
    final date = "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : (dateTime.hour == 0 ? 12 : dateTime.hour);
    final time = "${hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    return "$date $time";
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return AppTheme.border;
      case BookingStatus.approved:
        return Color.fromARGB(255, 9, 91, 24);
      case BookingStatus.denied:
        return Colors.red;
    }
  }
}