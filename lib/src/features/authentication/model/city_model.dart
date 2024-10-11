import 'package:cloud_firestore/cloud_firestore.dart';

class CityModel {
  final String id;
  final String name;
  final String regionId;

  CityModel({
    required this.id,
    required this.name,
    required this.regionId,
  });

  factory CityModel.fromMap(Map<String, dynamic> map, String id) {
    return CityModel(
      id: id,
      name: map['name'] ?? '',
      regionId: map['region_id'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'region_id': regionId,
    };
  }
}
