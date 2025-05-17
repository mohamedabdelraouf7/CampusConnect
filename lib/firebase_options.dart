import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.windows:
        return windows;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAYega8p98F9biIUuH_KdRfis3KZnGUt40',
    appId: '1:629663839766:web:YOUR_WEB_APP_ID',
    messagingSenderId: '629663839766',
    projectId: 'campusconnect-27361',
    authDomain: 'campusconnect-27361.firebaseapp.com',
    storageBucket: 'campusconnect-27361.firebasestorage.app',
    databaseURL: 'https://campusconnect-27361-default-rtdb.firebaseio.com/',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAYega8p98F9biIUuH_KdRfis3KZnGUt40',
    appId: '1:629663839766:android:6e270e6b53ae575ed7e737',
    messagingSenderId: '629663839766',
    projectId: 'campusconnect-27361',
    storageBucket: 'campusconnect-27361.firebasestorage.app',
    databaseURL: 'https://campusconnect-27361-default-rtdb.firebaseio.com/',
  );

  // --- Desktop platform configs (fill in with your Firebase Console values) ---
  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAYega8p98F9biIUuH_KdRfis3KZnGUt40',
    appId: '1:629663839766:android:6e270e6b53ae575ed7e737',
    messagingSenderId: '629663839766',
    projectId: 'campusconnect-27361',
    storageBucket: 'campusconnect-27361.appspot.com',
    databaseURL: 'https://campusconnect-27361-default-rtdb.firebaseio.com/',
  );

 
}