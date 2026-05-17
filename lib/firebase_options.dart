
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

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

  static FirebaseOptions get web => FirebaseOptions(
    apiKey: 'AIzaSyAczwjKXzsojNCjgG7Ow3xqg13px6SwIbY',
    appId: '1:273062394661:web:5d3ddf9c03b107a40478cc',
    messagingSenderId: '273062394661',
    projectId: 'expensivo-7ff86',
    authDomain: 'expensivo-7ff86.firebaseapp.com',
    storageBucket: 'expensivo-7ff86.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCiNjwC7ODzRb1TNLMWxP34eCVtX8cZ0I8',
    appId: '1:273062394661:android:440e85b50753ec370478cc',
    messagingSenderId: '273062394661',
    projectId: 'expensivo-7ff86',
    storageBucket: 'expensivo-7ff86.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAZWwrHGhcldcjv1sKOoIc4HynX_u2-9Bk',
    appId: '1:273062394661:ios:bf9f963158a784720478cc',
    messagingSenderId: '273062394661',
    projectId: 'expensivo-7ff86',
    storageBucket: 'expensivo-7ff86.firebasestorage.app',
    iosBundleId: 'com.example.expensivoApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAZWwrHGhcldcjv1sKOoIc4HynX_u2-9Bk',
    appId: '1:273062394661:ios:bf9f963158a784720478cc',
    messagingSenderId: '273062394661',
    projectId: 'expensivo-7ff86',
    storageBucket: 'expensivo-7ff86.firebasestorage.app',
    iosBundleId: 'com.example.expensivoApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAczwjKXzsojNCjgG7Ow3xqg13px6SwIbY',
    appId: '1:273062394661:web:a451b0a0c5d8aefb0478cc',
    messagingSenderId: '273062394661',
    projectId: 'expensivo-7ff86',
    authDomain: 'expensivo-7ff86.firebaseapp.com',
    storageBucket: 'expensivo-7ff86.firebasestorage.app',
  );
}


