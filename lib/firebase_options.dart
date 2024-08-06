// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyA7OJNsCaela_MLgLuWlXHVx68JEGbV25k',
    appId: '1:1031065553796:web:8f6ab664c1f0081cd4ebd1',
    messagingSenderId: '1031065553796',
    projectId: 'testproject-e520b',
    authDomain: 'testproject-e520b.firebaseapp.com',
    databaseURL: 'https://testproject-e520b-default-rtdb.firebaseio.com',
    storageBucket: 'testproject-e520b.appspot.com',
    measurementId: 'G-0FCZCTLSNX',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBcD0_Mlz73kSKMl1bCsTh7JRuuvJUFm4k',
    appId: '1:1031065553796:android:7232505c44262369d4ebd1',
    messagingSenderId: '1031065553796',
    projectId: 'testproject-e520b',
    databaseURL: 'https://testproject-e520b-default-rtdb.firebaseio.com',
    storageBucket: 'testproject-e520b.appspot.com',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyA7OJNsCaela_MLgLuWlXHVx68JEGbV25k',
    appId: '1:1031065553796:web:017bc7b02c5f9b54d4ebd1',
    messagingSenderId: '1031065553796',
    projectId: 'testproject-e520b',
    authDomain: 'testproject-e520b.firebaseapp.com',
    databaseURL: 'https://testproject-e520b-default-rtdb.firebaseio.com',
    storageBucket: 'testproject-e520b.appspot.com',
    measurementId: 'G-0LEJDQSEMQ',
  );
}