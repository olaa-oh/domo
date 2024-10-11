import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domo/src/features/booking/models/booking_model.dart';
import 'package:domo/src/features/authentication/model/interactions_model.dart';
import 'package:domo/src/features/authentication/model/shop_model.dart';


class ShopRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // get the shop by shop ID

  Future<ShopModel?> getShopById(String shopId) async {
    try {
      print('Fetching shop for shop ID: $shopId'); // Debug print
      QuerySnapshot querySnapshot = await _firestore
          .collection('shops')
          .where(FieldPath.documentId, isEqualTo: shopId)
          .limit(1)
          .get();
      
      print('Query snapshot docs length: ${querySnapshot.docs.length}'); // Debug print
      
      if (querySnapshot.docs.isNotEmpty) {
        print('Shop found for shop ID: $shopId'); // Debug print
        return ShopModel.fromMap(
          querySnapshot.docs.first.data() as Map<String, dynamic>,
          querySnapshot.docs.first.id
        );
      }
      print('No shop found for shop ID: $shopId'); // Debug print
      return null;
    } catch (e) {
      print('Error getting shop by shop ID: $e');
      return null;
    }
  }
// get shops by owner ID
Future<ShopModel?> getShopByOwnerId(String ownerId) async {
  try {
    print('Fetching shop for owner ID: $ownerId'); // Debug print
    QuerySnapshot querySnapshot = await _firestore
        .collection('shops')
        .where('ownerId', isEqualTo: ownerId)
        .limit(1)
        .get();
    
    print('Query snapshot docs length: ${querySnapshot.docs.length}'); // Debug print
    
    if (querySnapshot.docs.isNotEmpty) {
      print('Shop found for owner ID: $ownerId'); // Debug print
      return ShopModel.fromMap(
        querySnapshot.docs.first.data() as Map<String, dynamic>,
        querySnapshot.docs.first.id
      );
    }
    print('No shop found for owner ID: $ownerId'); // Debug print
    return null;
  } catch (e) {
    print('Error getting shop by owner ID: $e');
    return null;
  }
}



// get all shops
  Future<ShopQueryResult> getAllShops({int limit = 10, DocumentSnapshot? startAfter}) async {
    try {
      print('Fetching shops with limit: $limit, startAfter: ${startAfter?.id}');
      Query query = _firestore.collection('shops').orderBy('name').limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      QuerySnapshot querySnapshot = await query.get();
      print('Fetched ${querySnapshot.docs.length} shops');

      List<ShopModel> shops = [];
      for (var doc in querySnapshot.docs) {
        try {
          print('Processing shop: ${doc.id}');
          shops.add(ShopModel.fromMap(doc.data() as Map<String, dynamic>, doc.id));
        } catch (e) {
          print('Error processing shop ${doc.id}: $e');
          // Skip this shop and continue with the next one
        }
      }

      print('Successfully processed ${shops.length} shops');
      return ShopQueryResult(
        shops: shops,
        lastDocument: querySnapshot.docs.isNotEmpty ? querySnapshot.docs.last : null,
      );
    } catch (e) {
      print('Error getting all shops: $e');
      rethrow;
    }
  }



// create shop

  Future<String?> createShop(ShopModel shop) async {
    try {
      Map<String, dynamic> shopData = shop.toMap();
      shopData['searchTerms'] = ShopModel.generateSearchTerms(shop);
      shopData['likes'] = 0;
      shopData['booked'] = 0;
      shopData['createdAt'] = FieldValue.serverTimestamp();
      shopData['updatedAt'] = FieldValue.serverTimestamp();
      // does not track ownerid


      DocumentReference docRef = await _firestore.collection('shops').add(shopData);
      return docRef.id;
    } catch (e) {
      print('Error creating shop: $e');
      return null;
    }
  }
// update shop
  Future<bool> updateShop(ShopModel shop) async {
    try {
      Map<String, dynamic> shopData = shop.toMap();
      shopData['searchTerms'] = ShopModel.generateSearchTerms(shop);
      shopData['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore.collection('shops').doc(shop.id).update(shopData);
      return true;
    } catch (e) {
      print('Error updating shop: $e');
      return false;
    }
  }


// search shops
// Add this method to the ShopRepository class in shopRepository.dart

Future<List<ShopModel>> searchShops(String query) async {
  try {
    QuerySnapshot querySnapshot = await _firestore
        .collection('shops')
        .where('searchTerms', arrayContains: query.toLowerCase().trim())
        .limit(20)
        .get();

    List<ShopModel> shops = querySnapshot.docs
        .map((doc) => ShopModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();

    return shops;
  } catch (e) {
    print('Error searching shops: $e');
    return [];
  }
}

// like shop
  Future<bool> incrementShopLikes(String shopId) async {
    try {
      await _firestore.collection('shops').doc(shopId).update({
        'likes': FieldValue.increment(1),
      });
      return true;
    } catch (e) {
      print('Error incrementing shop likes: $e');
      return false;
    }
  }

  // bookmark shop
  Future<bool> incrementShopBooked(String shopId) async {
    try {
      await _firestore.collection('shops').doc(shopId).update({
        'booked': FieldValue.increment(1),
      });
      return true;
    } catch (e) {
      print('Error incrementing shop booked: $e');
      return false;
    }
  }

  // Method to update existing documents with searchTerms and likes
  Future<void> updateExistingDocuments() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('shops').get();

      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        ShopModel shop = ShopModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        List<String> searchTerms = ShopModel.generateSearchTerms(shop);

        await doc.reference.update({
          'searchTerms': searchTerms,
          'likes': shop.likes ?? 0,
        });
      }

      print('All existing documents updated successfully');
    } catch (e) {
      print('Error updating existing documents: $e');
    }
  }


// delete shop
  Future<bool> deleteShop(String shopId) async {
    try {
      await _firestore.collection('shops').doc(shopId).delete();
      return true;
    } catch (e) {
      print('Error deleting shop: $e');
      return false;
    }
  }

Future<bool> toggleShopLike(String shopId, String userId) async {
    try {
      DocumentReference userLikesRef = _firestore.collection('user_likes').doc(userId);
      DocumentReference shopRef = _firestore.collection('shops').doc(shopId);

      return await _firestore.runTransaction((transaction) async {
        DocumentSnapshot userLikesDoc = await transaction.get(userLikesRef);
        DocumentSnapshot shopDoc = await transaction.get(shopRef);

        UserLikes userLikes;
        if (!userLikesDoc.exists) {
          userLikes = UserLikes(userId: userId, likedShops: []);
        } else {
          userLikes = UserLikes.fromMap(userLikesDoc.data() as Map<String, dynamic>, userId);
        }

        if (userLikes.likedShops.contains(shopId)) {
          userLikes = userLikes.copyWith(likedShops: List.from(userLikes.likedShops)..remove(shopId));
          transaction.update(shopRef, {'likes': FieldValue.increment(-1)});
        } else {
          userLikes = userLikes.copyWith(likedShops: List.from(userLikes.likedShops)..add(shopId));
          transaction.update(shopRef, {'likes': FieldValue.increment(1)});
        }

        transaction.set(userLikesRef, userLikes.toMap());

        return userLikes.likedShops.contains(shopId);
      });
    } catch (e) {
      print('Error toggling shop like: $e');
      return false;
    }
  }

  Future<bool> toggleShopBookmark(String shopId, String userId) async {
    try {
      DocumentReference userBookmarksRef = _firestore.collection('user_bookmarks').doc(userId);
      DocumentReference shopRef = _firestore.collection('shops').doc(shopId);

      return await _firestore.runTransaction((transaction) async {
        DocumentSnapshot userBookmarksDoc = await transaction.get(userBookmarksRef);
        DocumentSnapshot shopDoc = await transaction.get(shopRef);

        UserBookmarks userBookmarks;
        if (!userBookmarksDoc.exists) {
          userBookmarks = UserBookmarks(userId: userId, bookmarkedShops: []);
        } else {
          userBookmarks = UserBookmarks.fromMap(userBookmarksDoc.data() as Map<String, dynamic>, userId);
        }

        if (userBookmarks.bookmarkedShops.contains(shopId)) {
          userBookmarks = userBookmarks.copyWith(bookmarkedShops: List.from(userBookmarks.bookmarkedShops)..remove(shopId));
          transaction.update(shopRef, {'booked': FieldValue.increment(-1)});
        } else {
          userBookmarks = userBookmarks.copyWith(bookmarkedShops: List.from(userBookmarks.bookmarkedShops)..add(shopId));
          transaction.update(shopRef, {'booked': FieldValue.increment(1)});
        }

        transaction.set(userBookmarksRef, userBookmarks.toMap());

        return userBookmarks.bookmarkedShops.contains(shopId);
      });
    } catch (e) {
      print('Error toggling shop bookmark: $e');
      return false;
    }
  }

  Future<bool> isShopLikedByUser(String shopId, String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('user_likes').doc(userId).get();
      if (doc.exists) {
        UserLikes userLikes = UserLikes.fromMap(doc.data() as Map<String, dynamic>, userId);
        return userLikes.likedShops.contains(shopId);
      }
      return false;
    } catch (e) {
      print('Error checking if shop is liked: $e');
      return false;
    }
  }

  Future<bool> isShopBookmarkedByUser(String shopId, String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('user_bookmarks').doc(userId).get();
      if (doc.exists) {
        UserBookmarks userBookmarks = UserBookmarks.fromMap(doc.data() as Map<String, dynamic>, userId);
        return userBookmarks.bookmarkedShops.contains(shopId);
      }
      return false;
    } catch (e) {
      print('Error checking if shop is bookmarked: $e');
      return false;
    }
  }

// get liked shops
  Future<List<ShopModel>> getLikedShops(String userId) async {
  try {
    DocumentSnapshot userLikesDoc = await _firestore.collection('user_likes').doc(userId).get();
    if (userLikesDoc.exists) {
      UserLikes userLikes = UserLikes.fromMap(userLikesDoc.data() as Map<String, dynamic>, userId);
      List<ShopModel> likedShops = [];
      for (String shopId in userLikes.likedShops) {
        ShopModel? shop = await getShopById(shopId);
        if (shop != null) {
          likedShops.add(shop);
        }
      }
      return likedShops;
    }
    return [];
  } catch (e) {
    print('Error getting liked shops: $e');
    return [];
  }
}

// get booked shops
// Future<List<ShopModel>> getBookedShops(String userId) async {
//   try {
//     DocumentSnapshot userBookmarksDoc = await _firestore.collection('user_bookmarks').doc(userId).get();
//     if (userBookmarksDoc.exists) {
//       UserBookmarks userBookmarks = UserBookmarks.fromMap(userBookmarksDoc.data() as Map<String, dynamic>, userId);
//       List<ShopModel> bookedShops = [];
//       for (String shopId in userBookmarks.bookmarkedShops) {
//         ShopModel? shop = await getShopById(shopId);
//         if (shop != null) {
//           bookedShops.add(shop);
//         }
//       }
//       return bookedShops;
//     }
//     return [];
//   } catch (e) {
//     print('Error getting booked shops: $e');
//     return [];
//   }
// }

// add shop to favorites
Future<void> addShopToFavorites(String userId, ShopModel shop) async {
  try {
    await _firestore.collection('user_likes').doc(userId).update({
      'liked_shops': FieldValue.arrayUnion([shop.id])
    });
  } catch (e) {
    print('Error adding shop to favorites: $e');
  }
}
// remove shop from favorites
Future<void> removeShopFromFavorites(String userId, String shopId) async {
  try {
    await _firestore.collection('user_likes').doc(userId).update({
      'liked_shops': FieldValue.arrayRemove([shopId])
    });
  } catch (e) {
    print('Error removing shop from favorites: $e');
  }
}
// add shops to appointments
Future<void> addShopToAppointments(String userId, ShopModel shop) async {
  try {
    await _firestore.collection('user_bookmarks').doc(userId).update({
      'bookmarked_shops': FieldValue.arrayUnion([shop.id])
    });
  } catch (e) {
    print('Error adding shop to appointments: $e');
  }
}
// remove shop from appointments
Future<void> removeShopFromAppointments(String userId, String shopId) async {
  try {
    await _firestore.collection('user_bookmarks').doc(userId).update({
      'bookmarked_shops': FieldValue.arrayRemove([shopId])
    });
  } catch (e) {
    print('Error removing shop from appointments: $e');
  }
}


// Managing bookings
  // Future<List<Booking>> getBookingsForShop(String shopId) async {
  //   final querySnapshot = await _firestore
  //       .collection('bookings')
  //       .where('shopId', isEqualTo: shopId)
  //       .get();

  //   return querySnapshot.docs
  //       .map((doc) => Booking.fromMap(doc.data(), doc.id))
  //       .toList();
  // }

  Future<List<Booking>> getBookingsForUser(String userId) async {
    final querySnapshot = await _firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .get();

    return querySnapshot.docs
        .map((doc) => Booking.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> createBooking(Booking booking) async {
    await _firestore.collection('bookings').add(booking.toMap());
  }

  // Future<void> updateBookingStatus(String bookingId, BookingStatus status, {String? note, String? denialReason}) async {
  //   await _firestore.collection('bookings').doc(bookingId).update({
  //     'status': status.index,
  //     if (note != null) 'note': note,
  //     if (denialReason != null) 'denialReason': denialReason,
  //   });
  // }


  


  final CollectionReference _shopsCollection = FirebaseFirestore.instance.collection('shops');
  final CollectionReference _bookingsCollection = FirebaseFirestore.instance.collection('bookings');



  Future<List<ShopModel>> getBookedShops(String userId) async {
    QuerySnapshot bookingsSnapshot = await _bookingsCollection.where('userId', isEqualTo: userId).get();
    List<String> shopIds = bookingsSnapshot.docs.map((doc) => (doc.data() as Map<String, dynamic>)['shopId'] as String).toList();

    QuerySnapshot shopsSnapshot = await _shopsCollection.where(FieldPath.documentId, whereIn: shopIds).get();
    return shopsSnapshot.docs.map((doc) => ShopModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
  }

  Future<List<Booking>> getBookingsForShop(String shopId) async {
    QuerySnapshot querySnapshot = await _bookingsCollection.where('shopId', isEqualTo: shopId).get();
    return querySnapshot.docs.map((doc) => Booking.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
  }

  Future<void> updateBookingStatus(String bookingId, BookingStatus status, {String? note, String? denialReason}) async {
    await _bookingsCollection.doc(bookingId).update({
      'status': status.index,
      if (note != null) 'note': note,
      if (denialReason != null) 'denialReason': denialReason,
    });
  }

  Future<void> updateShopBookedCount(String shopId, int count) async {
    await _shopsCollection.doc(shopId).update({'booked': count});
  }







  
}

class ShopQueryResult {
  final List<ShopModel> shops;
  final DocumentSnapshot? lastDocument;

  ShopQueryResult({required this.shops, this.lastDocument});
}