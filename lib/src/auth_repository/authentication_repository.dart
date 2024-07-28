// authentication page
import 'package:domo/src/features/authentication/screens/login_pages/otp.dart';
import 'package:domo/src/features/authentication/screens/login_pages/splash_screen.dart';
import 'package:domo/src/features/authentication/screens/allusers/homepage.dart';
import 'package:domo/src/features/authentication/screens/login_pages/login.dart';
import 'package:domo/src/widgets/navigation_bar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domo/src/auth_repository/exceptions/signup_exceptions.dart';

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

  // firebase authentication variables
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  late final Rx<User?> firebaseUser;
  var verificationId = ''.obs;
  bool isInitialLaunch = true;

  @override
  void onReady() {
    Future.delayed(const Duration(seconds: 6));
    firebaseUser = Rx<User?>(_auth.currentUser);
    firebaseUser.bindStream(_auth.userChanges());
    ever(firebaseUser, _setInitialScreen);
  }

  _setInitialScreen(User? user) {
    if (user == null) {
      if (isInitialLaunch) {
        isInitialLaunch = false;
        Get.offAll(() => const SplashScreen());
      } else {
        Get.offAll(() => const Login());
      }
    } else {
      Get.offAll(() => const Login());
    }
  }

  // phone with otp authentication
  void phoneNumberAuthentication(String phonenumber) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phonenumber,
      verificationCompleted: (credential) async {
        await _auth.signInWithCredential(credential);
      },
      codeSent: (verificationId, resendingToken) {
        this.verificationId.value = verificationId;
        Get.to(() => VerifyOTPPage(phoneNumber: phonenumber));
      },
      codeAutoRetrievalTimeout: ((verificationId) {
        this.verificationId.value = verificationId;
      }),
      verificationFailed: (e) {
        if (e.code == 'invalid-phone-number') {
          Get.snackbar('Error', 'The phone number provided is not valid');
        } else {
          Get.snackbar('Error', 'Something went wrong');
        }
      },
    );
  }

  // actual otp verification
  Future<bool> verifyOtp(String otp) async {
    try {
      UserCredential credential = await _auth.signInWithCredential(
          PhoneAuthProvider.credential(
              verificationId: this.verificationId.value, smsCode: otp));
      return credential.user != null;
    } catch (e) {
      print("Error verifying OTP: $e");
      return false;
    }
  }

  // create user with email, password, and role
  Future<void> createUser(String name, String email, String password,
      String role, String phonenumber) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      // Store user role in Firestore
      await _firestore.collection('users').doc(userCredential.user!.email).set({
        'name': name,
        'role': role,
        'email': email,
        'password': password,
        'id': email,
        'phonenumber': phonenumber,
        'imageUrl': '',
      });

      firebaseUser.value != null
          ? Get.offAll(() => const Login())
          : Get.offAll(() => const SplashScreen());
    } on FirebaseAuthException catch (e) {
      final ex = loginUserExceptions.code(e.code);
      print("FIREBASE AUTH EXCEPTIONS: ${ex.message}");
      throw ex;
    } catch (_) {
      const ex = loginUserExceptions();
      print("FIREBASE AUTH EXCEPTIONS: ${ex.message}");
      throw ex;
    }
  }

  // sign in with email and password
  Future<UserCredential?> loginUser(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      final ex = loginUserExceptions.code(e.code);
      print("FIREBASE AUTH EXCEPTION: ${ex.message}");
      Get.snackbar('Login Error', ex.message);
      return null;
    } catch (_) {
      const ex = loginUserExceptions();
      print("FIREBASE AUTH EXCEPTION: ${ex.message}");
      Get.snackbar('Login Error', ex.message);
      return null;
    }
  }

  // get user role
  Future<String?> getUserRole() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userData =
            await _firestore.collection('users').doc(user.email).get();
        return userData['role'] as String?;
      }
      return null;
    } catch (e) {
      print("Error getting user role: $e");
      return null;
    }
  }

  // sign out user
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      isInitialLaunch = false;
      Get.snackbar('Success', 'User Logged Out');
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Error signing out', e.toString());
    } catch (e) {
      Get.snackbar('Error signing out', e.toString());
    }
  }
}
