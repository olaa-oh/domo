import 'package:cloud_firestore/cloud_firestore.dart';

class WorkingHours {
  String open;
  String close;

  WorkingHours({required this.open, required this.close});

  Map<String, dynamic> toMap() {
    return {
      'open': open,
      'close': close,
    };
  }

  factory WorkingHours.fromMap(Map<String, dynamic> map) {
    return WorkingHours(
      open: map['open'] ?? '',
      close: map['close'] ?? '',
    );
  }
}

class ShopModel {
  final String id;
  final String name;
  final String regionId;
  final String regionName;
  final String cityId;
  final String cityName;
  final String phoneNumber;
  final Map<String, WorkingHours> workingHours;
  final String description;
  final List<String> services;
  final String ownerId;
  final GeoPoint? location;
  final String profileImageUrl;
  final List<String> galleryImageUrls;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<String> searchTerms;
  int likes;
  int booked;

  ShopModel({
    required this.id,
    required this.name,
    required this.regionId,
    required this.regionName,
    required this.cityId,
    required this.cityName,
    required this.phoneNumber,
    required this.workingHours,
    required this.description,
    required this.services,
    required this.ownerId,
    this.location,
    required this.profileImageUrl,
    required this.galleryImageUrls,
    this.createdAt,
    this.updatedAt,
    required this.searchTerms,
    required this.likes,
    required this.booked,
  });

  factory ShopModel.fromMap(Map<String, dynamic> map, String id) {
    Map<String, WorkingHours> workingHoursMap = {};
    if (map['workingHours'] != null) {
      map['workingHours'].forEach((key, value) {
        workingHoursMap[key] = WorkingHours.fromMap(value);
      });
    }

    return ShopModel(
      id: id,
      name: map['name'] ?? '',
      regionId: map['regionId'] ?? '',
      regionName: map['regionName'] ?? '',
      cityId: map['cityId'] ?? '',
      cityName: map['cityName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      workingHours: workingHoursMap,
      description: map['description'] ?? '',
      services: List<String>.from(map['services'] ?? []),
      ownerId: map['ownerId'] ?? '',
      location: map['location'] is GeoPoint ? map['location'] : null,
      profileImageUrl: map['profileImageUrl'] ?? '',
      galleryImageUrls: List<String>.from(map['galleryImageUrls'] ?? []),
      createdAt: _parseTimestamp(map['createdAt']),
      updatedAt: _parseTimestamp(map['updatedAt']),
      searchTerms: List<String>.from(map['searchTerms'] ?? []),
      likes: map['likes'] ?? 0,
      booked: map['booked'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> workingHoursMap = {};
    workingHours.forEach((key, value) {
      workingHoursMap[key] = value.toMap();
    });

    return {
      'name': name,
      'regionId': regionId,
      'regionName': regionName,
      'cityId': cityId,
      'cityName': cityName,
      'phoneNumber': phoneNumber,
      'workingHours': workingHoursMap,
      'description': description,
      'services': services,
      'ownerId': ownerId,
      'location': location,
      'profileImageUrl': profileImageUrl,
      'galleryImageUrls': galleryImageUrls,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'searchTerms': searchTerms,
      'likes': likes,
      'booked': booked,
    };
  }

  static DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        print('Error parsing date string: $value');
        return null;
      }
    }
    print('Unexpected type for timestamp: ${value.runtimeType}');
    return null;
  }

  static List<String> generateSearchTerms(ShopModel shop) {
    Set<String> terms = Set<String>();
    terms.addAll(shop.name.toLowerCase().split(' '));
    terms.add(shop.regionName.toLowerCase());
    terms.add(shop.cityName.toLowerCase());
    terms.addAll(shop.services.map((s) => s.toLowerCase()));
    return terms.toList();
  }

  ShopModel copyWith({
    String? id,
    String? name,
    String? regionId,
    String? regionName,
    String? cityId,
    String? cityName,
    String? phoneNumber,
    Map<String, WorkingHours>? workingHours,
    String? description,
    List<String>? services,
    String? ownerId,
    GeoPoint? location,
    String? profileImageUrl,
    List<String>? galleryImageUrls,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? searchTerms,
    int? likes,
    int? booked,
  }) {
    return ShopModel(
      id: id ?? this.id,
      name: name ?? this.name,
      regionId: regionId ?? this.regionId,
      regionName: regionName ?? this.regionName,
      cityId: cityId ?? this.cityId,
      cityName: cityName ?? this.cityName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      workingHours: workingHours ?? this.workingHours,
      description: description ?? this.description,
      services: services ?? this.services,
      ownerId: ownerId ?? this.ownerId,
      location: location ?? this.location,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      galleryImageUrls: galleryImageUrls ?? this.galleryImageUrls,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      searchTerms: searchTerms ?? this.searchTerms,
      likes: likes ?? this.likes,
      booked: booked ?? this.booked,
    );
  }
}