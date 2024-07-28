// otp page
import 'dart:async';
import 'package:domo/src/constants/style.dart';
import 'package:domo/src/features/authentication/controllers/verify_otp_controller.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class VerifyOTPPage extends StatefulWidget {
  final String phoneNumber;

  const VerifyOTPPage({Key? key, required this.phoneNumber}) : super(key: key);


  @override
  _VerifyOTPPageState createState() => _VerifyOTPPageState();
}

class _VerifyOTPPageState extends State<VerifyOTPPage> {
  TextEditingController otpController = TextEditingController();
  int _counter = 60;
  Timer? _timer;
  String _verificationCode = "";

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_counter == 0) {
          setState(() {
            timer.cancel();
          });
        } else {
          setState(() {
            _counter--;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    // otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.button,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("VERIFY CODE",
                style: AppTheme.textTheme.displaySmall!.copyWith(
                  color: AppTheme.background,
                )),
            const SizedBox(height: 40),
            Text(
              'Enter the OTP sent to ${widget.phoneNumber}',
              style: AppTheme.textTheme.titleMedium!.copyWith(
                color: AppTheme.background,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            PinCodeTextField(
              appContext: context,
              length: 6,
              obscureText: false,
              animationType: AnimationType.fade,
              keyboardType: TextInputType.number,
              pinTheme: PinTheme(
                activeColor: AppTheme.background,
                inactiveColor: AppTheme.border,
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(5),
                fieldHeight: 50,
                fieldWidth: 40,
                activeFillColor: Colors.white,
              ),
              animationDuration: const Duration(milliseconds: 300),
              controller: otpController,
              onCompleted: (v) {
                _verificationCode = v;
              },
              onChanged: (value) {
                setState(() {
                  _verificationCode = value;
                });
              },
            ),
            const SizedBox(height: 20),
            Text('Resend OTP in $_counter seconds',
                style: AppTheme.textTheme.labelLarge!.copyWith(
                  color: AppTheme.background,
                )),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(AppTheme.background),
              ),
              onPressed: () {
                OTPController.instance.verifyOTP(_verificationCode);
              },
              child: Text(
                'Verify OTP',
                style: AppTheme.textTheme.bodyMedium!.copyWith(
                    color: AppTheme.button, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
