// create account controller
import 'package:domo/src/auth_repository/authentication_repository.dart';
import 'package:domo/src/auth_repository/user_repository.dart';
import 'package:domo/src/constants/user_model.dart';
import 'package:domo/src/features/authentication/screens/login_pages/otp.dart';
// import 'package:domo/src/features/authentication/screens/login_pages/create_account.dart';
// import 'package:domo/src/features/authentication/screens/other_pages/homepage.dart';
import 'package:domo/src/widgets/navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateAccountController extends GetxController {
  static CreateAccountController get instance => Get.find();

  final name = TextEditingController();
  final email = TextEditingController();
  final phoneNumber = TextEditingController();
  final password = TextEditingController();
  final password2 = TextEditingController();
  final Rx<String> role = ''.obs;
  final RxBool isArtisan = false.obs;

  
  final userRepo = Get.put(UserRespository());

  @override
  void onInit() {
    super.onInit();
    role.value = 'customer'; // Set default role to customer
  }

  // function to register a user
  void registerUser(String name, String email, String password, String role,
      String phonenumber,bool isArtisan) async {
    AuthenticationRepository.instance
        .createUser(name, email, password, role, phonenumber);
  }

  Future<void> signInUser(String email, String password) async {
    final userCredential =
        await AuthenticationRepository.instance.loginUser(email, password);
    if (userCredential != null && userCredential.user != null) {
      // Login successful
      await AuthenticationRepository.instance.getUserRole();
      Get.offAll(
          () => BottomNavBar()); // Replace HomePage with your actual home page
    } else {
      // Login failed
      Get.snackbar('Login Failed',
          'Please check your email and password and try again.');
    }
  }

  // Set role of the user
  void setRole(String newRole) {
    role.value = newRole;
  }

  // phone authentication
  void phoneAuthentication(String phonenumber) {
    AuthenticationRepository.instance.phoneNumberAuthentication(phonenumber);
  }

  Future<void> signOut() async {
    await AuthenticationRepository.instance.signOut();
  }

  Future<void> createUsers(UserModel user)async  {
 await userRepo.createUsers(user);
  phoneAuthentication(user.phonenumber);
    Get.to(() => VerifyOTPPage(phoneNumber: user.phonenumber));

}

}

