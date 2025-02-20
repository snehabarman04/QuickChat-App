import 'package:firebase_testing/features/user_auth/presentation/pages/complete_profile_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_testing/features/user_auth/presentation/pages/complete_profile_page.dart';

import 'package:firebase_testing/features/user_auth/presentation/pages/login_page.dart';

//this is the first screen that is shown for 3 seconds and then it navigates into
//the login page
class SplashScreen extends StatefulWidget {
  final Widget? child;
  const SplashScreen({super.key, this.child});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Future.delayed(Duration(seconds: 3), () {
      //we do not want the user to navigate back to the splash screen once it goes to the login page
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => widget.child!),
          (route) => false);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/background.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Text(
              "Welcome To QuickChat",
              style: TextStyle(
                color: Colors
                    .white,
                fontWeight: FontWeight.bold,
                fontSize: 45,
                shadows: [
                  Shadow(
                    blurRadius: 10.0,
                    color: Colors.black45,
                    offset: Offset(2.0, 2.0),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
