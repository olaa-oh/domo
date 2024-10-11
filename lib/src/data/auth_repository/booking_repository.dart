import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domo/src/features/booking/models/booking_model.dart';

class BookingRepository {
  final CollectionReference _bookingsCollection = FirebaseFirestore.instance.collection('bookings');

Future<List<Booking>> getUserBookings(String userEmail) async {
  print('getUserBookings called with userEmail: $userEmail');
  QuerySnapshot querySnapshot = await _bookingsCollection.where('userEmail', isEqualTo: userEmail).get();
  print('Firestore query returned ${querySnapshot.docs.length} documents');
  
  List<Booking> bookings = querySnapshot.docs.map((doc) {
    try {
      return Booking.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      print('Error parsing booking document ${doc.id}: $e');
      return null;
    }
  }).whereType<Booking>().toList();
  
  print('Parsed ${bookings.length} valid bookings');
  return bookings;
}

// get bookings for owner
Future<List<Booking>> getOwnerBookings(String ownerId) async {
  print('Fetching bookings for ownerId: $ownerId');
  QuerySnapshot querySnapshot = await _bookingsCollection.where('ownerId', isEqualTo: ownerId).get();
  print('Firestore query returned ${querySnapshot.docs.length} documents');
  
  List<Booking> bookings = querySnapshot.docs.map((doc) {
    try {
      return Booking.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      print('Error parsing booking document ${doc.id}: $e');
      return null;
    }
  }).whereType<Booking>().toList();
  
  print('Parsed ${bookings.length} valid bookings');
  return bookings;
}

  // create booking
  Future<void> createBooking(Booking booking) async {
    await _bookingsCollection.add(booking.toMap());
  }

  Future<void> updateBookingStatus(String bookingId, BookingStatus status, {String? note, String? denialReason}) async {
    await _bookingsCollection.doc(bookingId).update({
      'status': status.index,
      if (note != null) 'note': note,
      if (denialReason != null) 'denialReason': denialReason,
    });
  }

  Future<void> deleteBooking(String bookingId) async {
    await _bookingsCollection.doc(bookingId).delete();
  }

  // edit booking
    Future<void> updateBooking(Booking booking) async {
    await _bookingsCollection.doc(booking.id).update(booking.toMap());
  }


  Future<int> getBookingsCountForShop(String shopId) async {
    try {
      QuerySnapshot querySnapshot = await _bookingsCollection
          .where('shopId', isEqualTo: shopId)
          .get();
      return querySnapshot.docs.length;
    } catch (e) {
      print("Error getting bookings count: $e");
      return 0;
    }
  }

  // sending notifications
  //  Future<void> sendNotificationToArtisan(String artisanToken, String shopName, String customerEmail) async {
  //   try {
  //     final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('sendNotification');
  //     await callable.call({
  //       'token': artisanToken,
  //       'title': 'New Booking',
  //       'body': 'A new booking has been made for $shopName by $customerEmail',
  //       'data': {
  //         'type': 'new_booking',
  //         'shopName': shopName,
  //         'customerEmail': customerEmail,
  //       },
  //     });
  //   } catch (e) {
  //     print('Error sending notification: $e');
  //   }
  // }

  // Future<void> sendNotificationToCustomer(String customerToken, String shopName, BookingStatus status) async {
  //   try {
  //     final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('sendNotification');
  //     await callable.call({
  //       'token': customerToken,
  //       'title': 'Booking Update',
  //       'body': 'Your booking for $shopName has been ${status.toString().split('.').last}',
  //       'data': {
  //         'type': 'booking_update',
  //         'shopName': shopName,
  //         'status': status.index.toString(),
  //       },
  //     });
  //   } catch (e) {
  //     print('Error sending notification: $e');
  //   }
  // }




}
