// File generated manually from google-services.json
// DO NOT EDIT — re-run FlutterFire CLI to regenerate if project changes.

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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for iOS. '
          'Reconfigure using FlutterFire CLI.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAuP86bLjvWxS2VGps8IA8EdrIwoDrp1O4',
    appId: '1:312069394942:android:8bc58a760885a4f75cf0af',
    messagingSenderId: '312069394942',
    projectId: 'agriportal-9ee3d',
    databaseURL: 'https://agriportal-9ee3d-default-rtdb.firebaseio.com',
    storageBucket: 'agriportal-9ee3d.firebasestorage.app',
  );

  // Web config — AgriPortalApp (from Firebase Console > Project Settings > Web apps)
  static const FirebaseOptions web = FirebaseOptions(
    apiKey:            'AIzaSyAwR5a3W2jZEzB0Piz5Qc7oP_aTFwdVYRA',
    appId:             '1:312069394942:web:08d4b4026fbafa425cf0af',
    messagingSenderId: '312069394942',
    projectId:         'agriportal-9ee3d',
    databaseURL:       'https://agriportal-9ee3d-default-rtdb.firebaseio.com',
    storageBucket:     'agriportal-9ee3d.firebasestorage.app',
    authDomain:        'agriportal-9ee3d.firebaseapp.com',
    measurementId:     'G-PVRLBRKXZ4',
  );
}
