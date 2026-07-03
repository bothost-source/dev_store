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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyDQjfnDKuT4G6qSsF13Kq_wY2DMWjq3YGQ',
    appId: '1:271046870393:web:e9690eb3ab9a9369cedba8',
    messagingSenderId: '271046870393',
    projectId: 'devstore-88439',
    authDomain: 'devstore-88439.firebaseapp.com',
    storageBucket: 'devstore-88439.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCqP9tETf4E43fkq_OnBaez2MHgqNJPdGw',
    appId: '1:271046870393:android:294739c7a822e910cedba8',
    messagingSenderId: '271046870393',
    projectId: 'devstore-88439',
    storageBucket: 'devstore-88439.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBMStWcDgTwOBwBBsDZmY8Qtq4l_IbooeQ',
    appId: '1:271046870393:ios:483f4890e2bd6c58cedba8',
    messagingSenderId: '271046870393',
    projectId: 'devstore-88439',
    storageBucket: 'devstore-88439.firebasestorage.app',
    iosBundleId: 'com.devstore.app',
  );
}
