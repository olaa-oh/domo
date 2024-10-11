// user_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domo/src/features/authentication/model/user_model.dart';
import 'package:domo/src/features/authentication/view/otp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class UserRespository extends GetxController {
  static UserRespository get instance => Get.find();

  final _db = FirebaseFirestore.instance;

  // store user in firestore and diaplaysnackbar if error or success
  createUsers(UserModel user) async {
    try {
      await _db.collection('users').doc(user.email).set(user.toJson());
      Get.snackbar('Success', 'User created successfully');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  // get user from firestore
  Future<UserModel?> getUser(String email) async {
    try {
      final snapshot = await _db.collection("users").doc(email).get();
      if (snapshot.exists) {
        return UserModel.fromSnapshot(snapshot);
      } else {
        print("No user found with email: $email");
        return null;
      }
    } catch (e) {
      print("Error in getUser: $e");
      return null;
    }
  }

  // update user in firestore
Future<void> updateUser(UserModel user) async {
  try {
    final docRef = _db.collection('users').doc(user.email);
    final docSnapshot = await docRef.get();
    
    if (docSnapshot.exists) {
      await docRef.update(user.toJson());
      Get.snackbar('Success', 'User updated successfully');
    } else {
      Get.snackbar('Error', 'User document does not exist');
    }
  } catch (e) {
    Get.snackbar('Error', e.toString());
    print("Error updating user: $e");
  }
}


  // how to get everything from firestore
  // Future<List<UserModel>> getUsers() async {
  //   final users = await _db.collection('users').get();
  //   final userData = users.docs.map((e) => UserModel.fromSnapshot(e)).toList();
  //   return userData;




}
