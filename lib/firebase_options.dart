import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBDBCUxE32fife4pQq0WcQuPKuLWESTFiw',
    appId: '1:161849406643:web:7bf46691f9055d6574ecc6',
    messagingSenderId: '161849406643',
    projectId: 'fir-testing-8c79c',
    authDomain: 'fir-testing-8c79c.firebaseapp.com',
    storageBucket: 'fir-testing-8c79c.appspot.com',
    measurementId: 'G-YSSMBNF2JZ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA1LpHDHgHhrcJw1vlcYu6u8CKkxnKKMaE',
    appId: '1:161849406643:android:37e5e9d9356c7bcf74ecc6',
    messagingSenderId: '161849406643',
    projectId: 'fir-testing-8c79c',
    storageBucket: 'fir-testing-8c79c.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB3C49FFyhZsrrAfSe-GM3pwqH863tdy0s',
    appId: '1:161849406643:ios:93f0df0342be8a6674ecc6',
    messagingSenderId: '161849406643',
    projectId: 'fir-testing-8c79c',
    storageBucket: 'fir-testing-8c79c.appspot.com',
    iosBundleId: 'com.example.firebaseTesting',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB3C49FFyhZsrrAfSe-GM3pwqH863tdy0s',
    appId: '1:161849406643:ios:93f0df0342be8a6674ecc6',
    messagingSenderId: '161849406643',
    projectId: 'fir-testing-8c79c',
    storageBucket: 'fir-testing-8c79c.appspot.com',
    iosBundleId: 'com.example.firebaseTesting',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBDBCUxE32fife4pQq0WcQuPKuLWESTFiw',
    appId: '1:161849406643:web:f57368d785797fb374ecc6',
    messagingSenderId: '161849406643',
    projectId: 'fir-testing-8c79c',
    authDomain: 'fir-testing-8c79c.firebaseapp.com',
    storageBucket: 'fir-testing-8c79c.appspot.com',
    measurementId: 'G-D9WMXW7Z7R',
  );

}
