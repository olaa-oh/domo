// main.dart
import 'package:domo/firebase_options.dart';
import 'package:domo/src/data/auth_repository/authentication_repository.dart';
import 'package:domo/src/data/auth_repository/shopRepository.dart';
import 'package:domo/src/features/authentication/controllers/create_account_controller.dart';
import 'package:domo/src/features/authentication/controllers/verify_otp_controller.dart';
import 'package:domo/src/features/authentication/view/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:domo/src/features/authentication/model/style_model.dart';
import 'package:get/get.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();


  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)
      .then((value) => Get.put(AuthenticationRepository()));
  Get.put(CreateAccountController());
  Get.put(OTPController());
  ShopRepository shopRepository = ShopRepository();
  await shopRepository.updateExistingDocuments();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme().light,
      // darkTheme: AppTheme().dark,
      // themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}
