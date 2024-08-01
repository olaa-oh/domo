import 'package:cloud_firestore/cloud_firestore.dart';

class RegionModel {
  final String id;
  final String name;
  final String regionId;

  RegionModel({
    required this.id,
    required this.name,
    required this.regionId,
  });

  factory RegionModel.fromMap(Map<String, dynamic> map, String id) {
    return RegionModel(
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
