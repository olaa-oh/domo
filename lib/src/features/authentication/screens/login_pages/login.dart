// login page
import 'package:domo/src/constants/style.dart';
import 'package:domo/src/features/authentication/controllers/create_account_controller.dart';
import 'package:domo/src/features/authentication/screens/login_pages/forget_password.dart';
import 'package:domo/src/widgets/navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:domo/src/features/authentication/screens/login_pages/create_account.dart';
import 'package:get/get.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final controller = Get.put(CreateAccountController());

  bool _obscurePin = true;

  @override
  void dispose() {
    super.dispose();
    // controller.email.dispose();
    // controller.password.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final controller = Get.put(CreateAccountController());
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
                const SizedBox(height: 110),
                Container(
                  height: 100,
                  width: 100,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.background,
                    image: DecorationImage(
                      image: AssetImage('assets/images/domoologo.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Login to your account",
                    style: AppTheme.textTheme.titleMedium!.copyWith(
                      fontSize: 27,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: controller.email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Enter your email',
                    hintStyle: TextStyle(
                      color: AppTheme.button.withOpacity(0.5),
                    ),
                    prefixIcon: const Icon(Icons.phone, color: AppTheme.button),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                  ),
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
                  controller: controller.password,
                  obscureText: _obscurePin,
                  keyboardType: TextInputType.text,
                  // inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    hintText: 'Enter your Password',
                    hintStyle: TextStyle(
                      color: AppTheme.button.withOpacity(0.5),
                    ),
                    prefixIcon: const Icon(Icons.lock, color: AppTheme.button),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePin ? Icons.visibility_off : Icons.visibility,
                        color: AppTheme.button,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePin = !_obscurePin;
                        });
                      },
                    ),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your Password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 8 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ForgetPassword(),
                        ),
                      );
                    },
                    child: Text(
                      'Forgot Password?  ',
                      style: AppTheme.textTheme.titleSmall!.copyWith(
                        color: AppTheme.button,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(AppTheme.button),
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                    ),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await controller.signInUser(controller.email.text.trim(),
                          controller.password.text.trim());
                      // Navigation is now handled in the signInUser method
                    }
                  },
                  child: Text('Login',
                      style: AppTheme.textTheme.labelLarge!.copyWith(
                        color: AppTheme.background,
                      )),
                ),
                const SizedBox(height: 40),
                
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Do not have an account? ",
                        style: AppTheme.textTheme.titleMedium!.copyWith(
                          color: AppTheme.button,
                        )),
                    GestureDetector(
                      onTap: () {
                      Get.to(() => const SignUp());
                      },
                      child: Text("Sign Up",
                          style: AppTheme.textTheme.titleMedium!.copyWith(
                              color: AppTheme.darkBackground,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
