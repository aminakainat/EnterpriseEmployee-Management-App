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
    apiKey: 'AIzaSyDiJ4QZbN-8QX7QCymtcH96Kr0Sm1qvMmk',
    appId: '1:1093751883125:web:9da703dec181101130ff3c',
    messagingSenderId: '1093751883125',
    projectId: 'employee-mangement-ead31',
    authDomain: 'employee-mangement-ead31.firebaseapp.com',
    storageBucket: 'employee-mangement-ead31.firebasestorage.app',
    measurementId: 'G-FTKWLSFKQN',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD0GZFr7BJDokLveIeMJa406Mn8W0hUmd8',
    appId: '1:1093751883125:android:d5b2f2222b74a9f430ff3c',
    messagingSenderId: '1093751883125',
    projectId: 'employee-mangement-ead31',
    storageBucket: 'employee-mangement-ead31.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyACQmWK49Q9ajYzOxxd3lmgyq_Pw3bi6q8',
    appId: '1:1093751883125:ios:203ecab81f88c82530ff3c',
    messagingSenderId: '1093751883125',
    projectId: 'employee-mangement-ead31',
    storageBucket: 'employee-mangement-ead31.firebasestorage.app',
    iosBundleId: 'com.example.flutterTask2',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyACQmWK49Q9ajYzOxxd3lmgyq_Pw3bi6q8',
    appId: '1:1093751883125:ios:203ecab81f88c82530ff3c',
    messagingSenderId: '1093751883125',
    projectId: 'employee-mangement-ead31',
    storageBucket: 'employee-mangement-ead31.firebasestorage.app',
    iosBundleId: 'com.example.flutterTask2',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDiJ4QZbN-8QX7QCymtcH96Kr0Sm1qvMmk',
    appId: '1:1093751883125:web:57f6063367f1462530ff3c',
    messagingSenderId: '1093751883125',
    projectId: 'employee-mangement-ead31',
    authDomain: 'employee-mangement-ead31.firebaseapp.com',
    storageBucket: 'employee-mangement-ead31.firebasestorage.app',
    measurementId: 'G-W5VFJN2R83',
  );
}
