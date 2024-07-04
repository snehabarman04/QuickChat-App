import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_testing/features/user_auth/firebase_authentication/firebase_auth_services.dart';
import 'package:firebase_testing/features/user_auth/presentation/pages/complete_profile_page.dart';
import 'package:firebase_testing/features/user_auth/presentation/pages/login_page.dart';
import 'package:firebase_testing/features/user_auth/presentation/widgets/form_container_widget.dart';
import 'package:firebase_testing/global/common/toast.dart';
import 'package:firebase_testing/models/UserModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'complete_profile_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _isSigningUp = false;

  final FirebaseAuthService _auth = FirebaseAuthService();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

  void checkValues() {
    String username = _usernameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if (username == "" ||
        email == "" ||
        password == "" ||
        confirmPassword == "") {
      showToast(message: "Please fill all the fields!");
    } else if (confirmPassword != password) {
      showToast(message: "Passwords does not match");
    } else {
      _signUp(email, password);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 174, 232, 241),
          automaticallyImplyLeading: false,
          title: Text(
            "Create an Account",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
                color: Color.fromARGB(255, 2, 64, 116)),
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
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Sign Up",
                    style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 5, 66, 116)),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  FormContainerWidget(
                    controller: _usernameController,
                    hintText: "Username",
                    isPasswordField: false,
                  ),
                  SizedBox(
                    height: 10,
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
                    hintText: " Enter Password",
                    isPasswordField: true,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  FormContainerWidget(
                    controller: _confirmPasswordController,
                    hintText: " Confirm Password",
                    isPasswordField: true,
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  CupertinoButton(
                    onPressed: () {
                      if (!_isSigningUp) {
                        checkValues();
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 45,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 12, 61, 101),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                          child: _isSigningUp
                              ? CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Text(
                                  "Sign Up",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                )),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Already have an account?"),
                      SizedBox(
                        width: 5,
                      ),
                      GestureDetector(
                          onTap: () {
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginPage()),
                                (route) => false);
                          },
                          child: Text(
                            "Login",
                            style: TextStyle(
                                color: Color.fromARGB(255, 20, 92, 151),
                                fontWeight: FontWeight.bold),
                          ))
                    ],
                  )
                ],
              ),
            ),
          ),
        ]));
  }

  void _signUp(String email, String password) async {
    setState(() {
      _isSigningUp = true;
    });

    UserCredential? credential;
    try {
      credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (ex) {
      showToast(message: 'An error occurred: ${ex.code}');
    }

    if (credential != null) {
      String uid = credential.user!.uid;

      Usermodel newUser =
          Usermodel(uid: uid, email: email, fullname: "", profilepic: "");
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .set(newUser.toMap())
          .then((value) {
        showToast(message: "Account created successfully");
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CompleteProfilePage(
            userModel: newUser,
            firebaseUser: credential!.user!,
          ),
        ),
      );
    } else {
      showToast(message: "User is not created...some error occured");
    }

    setState(() {
      _isSigningUp = false;
    });
  }
}
