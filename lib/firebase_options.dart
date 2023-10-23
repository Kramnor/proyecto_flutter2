// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyCGARHwLVR40oA-A1oaxpxkPgN4MsTo9zQ',
    appId: '1:896219871119:web:af9a6902f4da47966ebdfa',
    messagingSenderId: '896219871119',
    projectId: 'computacion-movil-55117',
    authDomain: 'computacion-movil-55117.firebaseapp.com',
    storageBucket: 'computacion-movil-55117.appspot.com',
    measurementId: 'G-JE92YVDQ79',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBRzcnR_bUkhMIWQNBJ9bcSreprdvgSGYA',
    appId: '1:896219871119:android:0c47b5ded12cc52a6ebdfa',
    messagingSenderId: '896219871119',
    projectId: 'computacion-movil-55117',
    storageBucket: 'computacion-movil-55117.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAWE2u6qYbHEbx0EwIrKhftWwnyCJfL3sg',
    appId: '1:896219871119:ios:5715d48c0b3541e56ebdfa',
    messagingSenderId: '896219871119',
    projectId: 'computacion-movil-55117',
    storageBucket: 'computacion-movil-55117.appspot.com',
    iosBundleId: 'com.migueltapia.crudFirebase',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAWE2u6qYbHEbx0EwIrKhftWwnyCJfL3sg',
    appId: '1:896219871119:ios:17c80b74852dad5e6ebdfa',
    messagingSenderId: '896219871119',
    projectId: 'computacion-movil-55117',
    storageBucket: 'computacion-movil-55117.appspot.com',
    iosBundleId: 'com.migueltapia.crudFirebase.RunnerTests',
  );
}