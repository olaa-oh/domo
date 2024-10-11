// verify otp controller page
import 'package:domo/src/data/auth_repository/authentication_repository.dart';
import 'package:domo/src/features/authentication/controllers/create_account_controller.dart';
import 'package:domo/src/features/authentication/view/login.dart';
import 'package:get/get.dart';

class OTPController extends GetxController {
  static OTPController get instance => Get.find();
  final CreateAccountController _createAccountController = Get.find();


 void verifyOTP(String otp) async {
    var isVerified = await AuthenticationRepository.instance.verifyOtp(otp);
    if (isVerified) {
      // OTP verified, now register the user
      _createAccountController.registerUser(
        _createAccountController.name.text.trim(),
        _createAccountController.email.text.trim(),
        _createAccountController.password.text.trim(),
        _createAccountController.role.value,
        _createAccountController.phoneNumber.text.trim(),
        _createAccountController.isArtisan.value,
   
      );
    } else {
      Get.snackbar('Error', 'Invalid OTP. Please try again.');
    }
  }
}
