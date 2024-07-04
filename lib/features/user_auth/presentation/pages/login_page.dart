import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_testing/features/user_auth/firebase_authentication/firebase_auth_services.dart';
import 'package:firebase_testing/features/user_auth/presentation/pages/sign_up_page.dart';
import 'package:firebase_testing/features/user_auth/presentation/widgets/form_container_widget.dart';
import 'package:firebase_testing/global/common/toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'home_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_testing/models/UserModel.dart';
import 'sign_up_page.dart';
import 'package:firebase_testing/models/UIHelper.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isSigningIn = false;

  final FirebaseAuthService _auth = FirebaseAuthService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  void checkValues() {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email == "") {
      UIHelper.showAlertDialog(
          context, "Email field cannot be empty", "Please fill your Email!");
    } else if (password == "") {
      UIHelper.showAlertDialog(context, "Password field cannot be empty",
          "PLease fill your password!");
    } else {
      _signIn(email, password);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 174, 232, 241),
          title: Text(
            "Welcome Again!",
            style: TextStyle(
                fontSize: 30,
                color: Colors.lightBlue[900],
                fontWeight: FontWeight.bold),
          ),
        ),
        body: Stack(fit: StackFit.expand, children: [
          Positioned.fill(
            child: Image.asset(
              'login_background.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 35),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Login To Your Account",
                    style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                        color: Colors.lightBlue[900]),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  FormContainerWidget(
                    controller: _emailController,
                    hintText: "Email",
                    isPasswordField: false,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  FormContainerWidget(
                    controller: _passwordController,
                    hintText: "Password",
                    isPasswordField: true,
                  ),
                  SizedBox(
                    height: 65,
                  ),
                  CupertinoButton(
                    onPressed: () {
                      if (!_isSigningIn) {
                        checkValues();
                      }
                    },
                    color: Color.fromARGB(255, 20, 76, 122),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: double.infinity,
                      height: 20,
                      child: Center(
                        child: _isSigningIn
                            ? SizedBox(
                                width: 20.0,
                                height: 20.0,
                                child: CircularProgressIndicator(
                                  strokeWidth: 4.0,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.email_rounded,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    "Log In with Email",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account?"),
                      SizedBox(
                        width: 5,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SignUpPage()));
                        },
                        child: Text(
                          "Sign Up",
                          style: TextStyle(
                              color: Color.fromARGB(255, 20, 76, 122),
                              fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ]));
  }

  void _signIn(String email, String password) async {
    setState(() {
      _isSigningIn = true;
    });

    UserCredential? credential;

    try {
      credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (ex) {
      setState(() {
        _isSigningIn = false;
      });
      if (ex.code == 'user-not-found') {
        showToast(message: 'No user found for that email.');
      } else if (ex.code == 'wrong-password') {
        showToast(message: 'Wrong password provided.');
      } else {
        showToast(message: 'An error occurred: ${ex.code}');
      }
      return;
    }
    if (credential != null) {
      String uid = credential.user!.uid;

      DocumentSnapshot userData =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      Usermodel usermodel =
          Usermodel.fromMap(userData.data() as Map<String, dynamic>);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return HomePage(
              userModel: usermodel,
              firebaseUser: credential!.user!,
            );
          },
        ),
      );
    }
  }
}
