// profile controller 
import 'dart:io';

import 'package:domo/src/auth_repository/authentication_repository.dart';
import 'package:domo/src/auth_repository/user_repository.dart';
import 'package:domo/src/constants/user_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  static ProfileController get instance => Get.find();
  final _authRepo = Get.put(AuthenticationRepository());
  final userRepo = Get.put(UserRespository());



  Future<UserModel?> getUser() async {
    try {
      final id = _authRepo.firebaseUser.value?.email;
      if (id != null) {
        return await userRepo.getUser(id);
      } else {
        Get.snackbar('Error', 'User not found');
        return null;
      }
    } catch (e) {
      print("Error in getUser: $e");
      Get.snackbar('Error', 'Failed to fetch user data');
      return null;
    }
  }

  Future<void> updateUser(UserModel user) async {
  try {
    print("Updating user with ID: ${user.id} and email: ${user.email}");
    await userRepo.updateUser(user);
  } catch (e) {
    print("Error in ProfileController.updateUser: $e");
    Get.snackbar('Error', e.toString());
  }
  }

  // update the profile image

  Future<String?> uploadProfilePicture(String filePath) async {
    try {
      final file = File(filePath);
      final userId = _authRepo.firebaseUser.value?.email;
      if (userId == null) {
        Get.snackbar('Error', 'User not authenticated');
        return null;
      }

      final ref = FirebaseStorage.instance.ref().child('profilePics/$userId.jpg');
      await ref.putFile(file);
      final url = await ref.getDownloadURL();

      // Update user's imageUrl in Firestore
      final user = await getUser();
      if (user != null) {
        user.imageUrl = url;
        await updateUser(user);
      }

      return url;
    } catch (e) {
      print("Error uploading profile picture: $e");
      Get.snackbar('Error', 'Failed to upload profile picture');
      return null;
    }
  }
}