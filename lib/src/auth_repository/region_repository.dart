import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domo/src/constants/region_model.dart';

class RegionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<RegionModel>> getRegions() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('regions').get();
      return querySnapshot.docs.map((doc) {
        return RegionModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      print('Error getting regions: $e');
      return [];
    }
  }
}
