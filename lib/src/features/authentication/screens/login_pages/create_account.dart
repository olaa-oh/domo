import 'package:domo/src/constants/style.dart';
import 'package:domo/src/features/authentication/screens/login_pages/login.dart';
import 'package:domo/src/features/authentication/screens/login_pages/otp.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _PinController = TextEditingController();
  final _PinController2 = TextEditingController();
  bool _obscurePin = true;
  bool _obscurePin2 = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _PinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                const SizedBox(height: 120),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Create an your new account",
                    style: AppTheme.textTheme.titleMedium!.copyWith(
                      fontSize: 27,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    hintText: 'Enter your phone number',
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
                      return 'Please enter your phone number';
                    }
                    if (value.length < 10) {
                      return 'Phone number must be at least 10 digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _PinController,
                  obscureText: _obscurePin,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    hintText: 'Enter your Pin',
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
                      return 'Please enter your Pin';
                    }
                    if (value.length < 6) {
                      return 'Pin must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                // reenter your pin
                const SizedBox(height: 30),
                TextFormField(
                  controller: _PinController2,
                  obscureText: _obscurePin2,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    hintText: 'Re-enter your Pin',
                    hintStyle: TextStyle(
                      color: AppTheme.button.withOpacity(0.5),
                    ),
                    prefixIcon: const Icon(Icons.lock, color: AppTheme.button),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePin2 ? Icons.visibility_off : Icons.visibility,
                        color: AppTheme.button,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePin2 = !_obscurePin2;
                        });
                      },
                    ),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your Pin';
                    }
                    if (value.length < 6) {
                      return 'Pin must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

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
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Perform SignUp logic here
                      print('Phone: ${_phoneController.text}');
                      print('Pin: ${_PinController.text}');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VerifyOTPPage(),
                        ),
                      );
                    }
                  },
                  child: Text('SignUp',
                      style: AppTheme.textTheme.labelLarge!.copyWith(
                        color: AppTheme.background,
                      )),
                ),
                const SizedBox(height: 40),
                Text(
                  'Or continue with Google',
                  style: AppTheme.textTheme.titleSmall!.copyWith(
                    color: AppTheme.button,
                  ),
                ),
                const SizedBox(height: 20),
                const CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage(
                    'assets/images/google.png',
                  ),
                  backgroundColor: Colors.transparent,
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
                      child: Text("Login",
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
