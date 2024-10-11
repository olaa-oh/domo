import 'package:domo/src/features/authentication/model/user_model.dart';
import 'package:domo/src/features/authentication/controllers/create_account_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:domo/src/features/authentication/model/style_model.dart';
import 'package:domo/src/features/authentication/view/login.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  bool _obscurePassword = true;
  bool _obscurePassword2 = true;
  final controller = Get.put(CreateAccountController());

  @override
  void dispose() {
    super.dispose();
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    String pattern =
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{6,}$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'Password must include at least one uppercase letter, one lowercase letter, one digit, and one special character';
    }
    return null;
  }

String? validatePhoneNumber(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter your phone number';
  }
  if (!RegExp(r'^\+[1-9]\d{1,14}$').hasMatch(value)) {
    return 'Please enter your country code';
  }
  return null;
}
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Create your new account",
                      style: AppTheme.textTheme.titleMedium!.copyWith(
                        fontSize: 27,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: controller.name,
                    decoration: InputDecoration(
                      hintText: 'Adam Eve',
                      hintStyle: TextStyle(
                        color: AppTheme.button.withOpacity(0.5),
                      ),
                      prefixIcon:
                          const Icon(Icons.person, color: AppTheme.button),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: controller.email,
                    decoration: InputDecoration(
                      hintText: 'app@domo.com',
                      hintStyle: TextStyle(
                        color: AppTheme.button.withOpacity(0.5),
                      ),
                      prefixIcon:
                          const Icon(Icons.email, color: AppTheme.button),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: controller.phoneNumber,
                    decoration: InputDecoration(
                      hintText: '+233012345678',
                      hintStyle: TextStyle(
                        color: AppTheme.button.withOpacity(0.5),
                      ),
                      prefixIcon:
                          const Icon(Icons.phone, color: AppTheme.button),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                    // initialValue: '+233',
                    validator: validatePhoneNumber,
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: controller.password,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: 'Enter your password',
                      hintStyle: TextStyle(
                        color: AppTheme.button.withOpacity(0.5),
                      ),
                      prefixIcon:
                          const Icon(Icons.lock, color: AppTheme.button),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppTheme.button,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                    validator: validatePassword,
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: controller.password2,
                    obscureText: _obscurePassword2,
                    decoration: InputDecoration(
                      hintText: 'Re-enter your password',
                      hintStyle: TextStyle(
                        color: AppTheme.button.withOpacity(0.5),
                      ),
                      prefixIcon:
                          const Icon(Icons.lock, color: AppTheme.button),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword2
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppTheme.button,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword2 = !_obscurePassword2;
                          });
                        },
                      ),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please re-enter your password';
                      }
                      if (value != controller.password.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  Text(
                    "Select your role",
                    style: AppTheme.textTheme.titleMedium,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Obx(() => Radio<String>(
                            value: 'customer',
                            groupValue: controller.role.value,
                            onChanged: (value) => controller.setRole(value!),
                          )),
                      const Text('Customer'),
                      const SizedBox(width: 30),
                      Obx(() => Radio<String>(
                            value: 'artisan',
                            groupValue: controller.role.value,
                            onChanged: (value) => controller.setRole(value!),
                          )),
                      const Text('Artisan'),
                    ],
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(AppTheme.button),
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 10),
                      ),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        if (controller.role.value.isEmpty) {
                          Get.snackbar('Error', 'Please select a role');
                        } else {
                          // CreateAccountController.instance.registerUser(
                          //   controller.name.text.trim(),
                          //   controller.email.text.trim(),
                          //   controller.password.text.trim(),
                          //   controller.role.value,
                          //   controller.phoneNumber.text.trim()
                          // );
                          // CreateAccountController.instance
                          //     .phoneAuthentication(controller.phoneNumber.text.trim());
                              
                          // print('Name: ${controller.name.text}');
                          // print('Email: ${controller.email.text}');
                          // print('Phone: ${controller.phoneNumber.text}');
                          // print('Password: ${controller.password.text}');
                          // print('Role: ${controller.role.value}');

                          final user = UserModel(
                            name: controller.name.text.trim(),
                            email: controller.email.text.trim(),
                            phonenumber: controller.phoneNumber.text.trim(),
                            password: controller.password.text.trim(),
                            role: controller.role.value,
                            // isArtisan: controller.role.value == 'artisan',
                          );
                          CreateAccountController.instance.createUsers(user);

                      



                        }
                      }
                    },
                    child: Text('Sign Up',
                        style: AppTheme.textTheme.titleMedium!.copyWith(
                          color: AppTheme.background,
                        )),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Already have an account? ",
                          style: AppTheme.textTheme.titleMedium!.copyWith(
                            color: AppTheme.button,
                          )),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Login()));
                        },
                        child: Text(
                          "Log In",
                          style: AppTheme.textTheme.titleMedium!.copyWith(
                              color: AppTheme.darkBackground,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ]),
          ),
        ),
      ),
    );
  }
}
