// booking_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum BookingStatus { pending, approved, denied }

class Booking {
  final String id;
  final String shopId;
  final String userEmail;
  final String shopName;
  final String ownerId; 
  final DateTime bookingDate;
  final BookingStatus status;
  final String? note;
  final String? denialReason;

  Booking({
    required this.id,
    required this.shopId,
    required this.userEmail,
    required this.ownerId,
    required this.shopName,
    required this.bookingDate,
    required this.status,
    this.note,
    this.denialReason,
  });

  factory Booking.fromMap(Map<String, dynamic> map, String id) {
    return Booking(
      id: id,
      shopId: map['shopId'],
      userEmail: map['userEmail'],
      ownerId: map['ownerId'] ,
      shopName: map['shopName'],
      bookingDate: (map['bookingDate'] as Timestamp).toDate(),
      status: BookingStatus.values[map['status']],
      note: map['note'],
      denialReason: map['denialReason'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'shopId': shopId,
      'userEmail': userEmail,
      'shopName': shopName,
      'ownerId' : ownerId,
      'bookingDate': Timestamp.fromDate(bookingDate),
      'status': status.index,
      'note': note,
      'denialReason': denialReason,
    };
  }

    // Add this method to the Booking class
  Booking copyWith({
    String? id,
    String? shopId,
    String? userEmail,
    String? shopName,
    String? ownerId,
    DateTime? bookingDate,
    BookingStatus? status,
    String? note,
    String? denialReason,
  }) {
    return Booking(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      userEmail: userEmail ?? this.userEmail,
      shopName: shopName ?? this.shopName,
      ownerId: ownerId ?? this.ownerId,
      bookingDate: bookingDate ?? this.bookingDate,
      status: status ?? this.status,
      note: note ?? this.note,
      denialReason: denialReason ?? this.denialReason,
    );
  }






}
