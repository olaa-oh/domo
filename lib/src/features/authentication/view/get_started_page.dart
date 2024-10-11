import 'package:domo/src/features/authentication/view/create_account.dart';
import 'package:domo/src/features/authentication/view/login.dart';
import 'package:flutter/material.dart';
import 'package:domo/src/features/authentication/model/style_model.dart';

class GetStarted extends StatelessWidget {
  const GetStarted({super.key});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppTheme.border,
      body: Stack(
        children: [
          Container(
            height: size.height * 0.8,
            decoration: const BoxDecoration(
              color: AppTheme.border,
              image: DecorationImage(
                  image: AssetImage('assets/images/onboard/getStarted.png'),
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomCenter),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                height: size.height * 0.2,
                width: size.width * 1.0,
                padding:
                    const EdgeInsets.symmetric( vertical: 10),
                decoration:  const BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.only(
                    topLeft:  Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Get Started',
                        style: AppTheme.textTheme.displaySmall!.copyWith(
                          color: AppTheme.button,
                        )),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) =>  SignUp()));
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                AppTheme.button),
                          ),
                          child: Text(
                            'Sign Up',
                            style: AppTheme.textTheme.labelLarge!.copyWith(
                              color: AppTheme.background,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const Login()));
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                AppTheme.button),
                          ),
                          child:  Text(
                            'Log In',
                            style: AppTheme.textTheme.labelLarge!.copyWith(
                              color: AppTheme.background,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
