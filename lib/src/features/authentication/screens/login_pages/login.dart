import 'package:domo/src/constants/style.dart';
import 'package:domo/src/features/authentication/screens/login_pages/forget_password.dart';
import 'package:domo/src/features/authentication/screens/login_pages/homepage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:domo/src/features/authentication/screens/login_pages/create_account.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _PinController = TextEditingController();
  bool _obscurePin = true;

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
                const SizedBox(height: 80),
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
                      'Forgot Pin?  ',
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
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Perform login logic here
                      print('Phone: ${_phoneController.text}');
                      print('Pin: ${_PinController.text}');
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Homepage()));
                    }
                  },
                  child: Text('Login',
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
                    Text("Do not have an account? ",
                        style: AppTheme.textTheme.titleMedium!.copyWith(
                          color: AppTheme.button,
                        )),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => const SignUp()));
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
