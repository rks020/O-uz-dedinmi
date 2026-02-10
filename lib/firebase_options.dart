// lib/firebase_options.dart
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
    apiKey: 'AIzaSyBR85XO5nYn2y9bYK-isb8vd4SWewiCdCs',
    appId: '1:537286274195:web:bd818379c4d8efbabf3166',
    messagingSenderId: '537286274195',
    projectId: 'gelirgider-a59e5',
    authDomain: 'gelirgider-a59e5.firebaseapp.com',
    databaseURL: 'https://gelirgider-a59e5-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'gelirgider-a59e5.firebasestorage.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD6ncSnqmTdypaLv1QzIEa0zWvKy1u2ApM',
    appId: '1:537286274195:ios:039bf4ada6313663bf3166',
    messagingSenderId: '537286274195',
    projectId: 'gelirgider-a59e5',
    databaseURL: 'https://gelirgider-a59e5-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'gelirgider-a59e5.firebasestorage.app',
    iosBundleId: 'com.uzelabs.odedimmi.odedimmi',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD6ncSnqmTdypaLv1QzIEa0zWvKy1u2ApM',
    appId: '1:537286274195:ios:c16b67ecf31fdb0abf3166',
    messagingSenderId: '537286274195',
    projectId: 'gelirgider-a59e5',
    databaseURL: 'https://gelirgider-a59e5-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'gelirgider-a59e5.firebasestorage.app',
    iosBundleId: 'com.oguzodedinmi.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA6T7CZ3ESveb4aqY0ujio6lYGWqXJqzSU',
    appId: '1:537286274195:android:01b695784a437df8bf3166',
    messagingSenderId: '537286274195',
    projectId: 'gelirgider-a59e5',
    databaseURL: 'https://gelirgider-a59e5-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'gelirgider-a59e5.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBR85XO5nYn2y9bYK-isb8vd4SWewiCdCs',
    appId: '1:537286274195:web:081154f0cad9232dbf3166',
    messagingSenderId: '537286274195',
    projectId: 'gelirgider-a59e5',
    authDomain: 'gelirgider-a59e5.firebaseapp.com',
    databaseURL: 'https://gelirgider-a59e5-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'gelirgider-a59e5.firebasestorage.app',
  );

}