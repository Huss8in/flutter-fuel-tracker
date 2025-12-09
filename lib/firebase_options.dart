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
    apiKey: 'your-web-api-key',
    appId: '1:your-project-number:web:your-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: 'fuel-tracker-61b88',
    authDomain: 'fuel-tracker-61b88.firebaseapp.com',
    databaseURL: 'https://fuel-tracker-61b88-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'fuel-tracker-61b88.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCxRfOjX1fhTaGQ3jmZiKoDVt9YU8xbqkQ',
    appId: '1:895716190401:android:79acce04eae016afa84c40',
    messagingSenderId: '895716190401',
    projectId: 'fuel-tracker-61b88',
    databaseURL: 'https://fuel-tracker-61b88-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'fuel-tracker-61b88.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBNzwN9bUyaFejSo_VAOnA-T1gIWwNLW0Q',
    appId: '1:895716190401:ios:762e9c661795adcda84c40',
    messagingSenderId: '895716190401',
    projectId: 'fuel-tracker-61b88',
    databaseURL: 'https://fuel-tracker-61b88-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'fuel-tracker-61b88.firebasestorage.app',
    iosBundleId: 'com.example.flutterApplication1',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'your-ios-api-key',
    appId: '1:your-project-number:ios:your-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: 'fuel-tracker-61b88',
    iosBundleId: 'com.example.fuelTracker',
    databaseURL: 'https://fuel-tracker-61b88-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'fuel-tracker-61b88.appspot.com',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'your-web-api-key',
    appId: '1:your-project-number:web:your-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: 'fuel-tracker-61b88',
    authDomain: 'fuel-tracker-61b88.firebaseapp.com',
    databaseURL: 'https://fuel-tracker-61b88-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'fuel-tracker-61b88.appspot.com',
  );
}