import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domo/src/features/authentication/model/city_model.dart';

class CityRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<CityModel>> getCities(String regionId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('cities').where('region_id', isEqualTo: regionId).get();
      return querySnapshot.docs.map((doc) {
        return CityModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      print('Error getting cities: $e');
      return [];
    }
  }
}
