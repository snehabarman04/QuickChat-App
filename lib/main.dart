import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_testing/features/app/splash_screen/splash_screen.dart';
import 'package:firebase_testing/features/user_auth/firebase_authentication/firebase_auth_services.dart';
import 'package:firebase_testing/features/user_auth/presentation/pages/complete_profile_page.dart';
import 'package:firebase_testing/features/user_auth/presentation/pages/login_page.dart';
import 'package:firebase_testing/models/UserModel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_testing/firebase_options.dart';
import 'package:firebase_testing/features/user_auth/presentation/pages/home_page.dart';
import 'package:firebase_testing/features/user_auth/presentation/pages/login_page.dart';
import 'package:firebase_testing/features/user_auth/presentation/pages/sign_up_page.dart';
import 'package:firebase_testing/features/user_auth/presentation/pages/complete_profile_page.dart';
import 'package:uuid/uuid.dart';

var uuid = Uuid();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyBVUEw8mqVyjzXCIJE1eZgWUip_a-guyuE",
          authDomain: "fir-testing-c7047.firebaseapp.com",
          appId: "1:985059466613:web:21468add8664380da1473c",
          messagingSenderId: "985059466613",
          storageBucket: "fir-testing-c7047.appspot.com",
          projectId: "fir-testing-c7047"),
    );
  } else {
    await Firebase.initializeApp();
    options:
    DefaultFirebaseOptions.currentPlatform;
  }

  User? currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    //user is logged in
    Usermodel? thisUserModel =
        await FirebaseHelper.getUserModelById(currentUser.uid);
    if (thisUserModel != null) {
      runApp(
          MyAppLoggedIn(userModel: thisUserModel, firebaseUser: currentUser));
    } else {
      runApp(MyApp());
    }
  } else {
    //if user is not logged in
    runApp(MyApp());
  }
}

//not logged in
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chat App',
      routes: {
        '/': (context) => SplashScreen(
              child: LoginPage(),
            ),
        '/login': (context) => LoginPage(),
        '/home': (context) => HomePage(
              userModel: Usermodel(),
              firebaseUser: FirebaseAuth.instance.currentUser!,
            ),
      },
    );
  }
}

//already logged in
class MyAppLoggedIn extends StatelessWidget {
  final Usermodel userModel;
  final User firebaseUser;
  const MyAppLoggedIn(
      {Key? key, required this.userModel, required this.firebaseUser})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(
        userModel: userModel,
        firebaseUser: firebaseUser,
      ),
    );
  }
}
