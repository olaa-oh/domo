// File: user_interaction_models.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class UserLikes {
  final String userId;
  final List<String> likedShops;

  UserLikes({
    required this.userId,
    required this.likedShops,
  });

  factory UserLikes.fromMap(Map<String, dynamic> map, String userId) {
    return UserLikes(
      userId: userId,
      likedShops: List<String>.from(map['liked_shops'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'liked_shops': likedShops,
    };
  }

  UserLikes copyWith({
    String? userId,
    List<String>? likedShops,
  }) {
    return UserLikes(
      userId: userId ?? this.userId,
      likedShops: likedShops ?? this.likedShops,
    );
  }
}

class UserBookmarks {
  final String userId;
  final List<String> bookmarkedShops;

  UserBookmarks({
    required this.userId,
    required this.bookmarkedShops,
  });

  factory UserBookmarks.fromMap(Map<String, dynamic> map, String userId) {
    return UserBookmarks(
      userId: userId,
      bookmarkedShops: List<String>.from(map['bookmarked_shops'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookmarked_shops': bookmarkedShops,
    };
  }

  UserBookmarks copyWith({
    String? userId,
    List<String>? bookmarkedShops,
  }) {
    return UserBookmarks(
      userId: userId ?? this.userId,
      bookmarkedShops: bookmarkedShops ?? this.bookmarkedShops,
    );
  }
}