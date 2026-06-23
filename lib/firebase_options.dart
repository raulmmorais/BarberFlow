// Arquivo gerado a partir do google-services.json do Firebase.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('BarberFlow não suporta web no MVP.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'Plataforma ${defaultTargetPlatform.name} não suportada.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBq76JqPEKX-PG2PSaL63Io4qG_zFjoZ4o',
    appId: '1:697711167014:android:eed58a26cbbbf5a79d48e7',
    messagingSenderId: '697711167014',
    projectId: 'barberflow-4169a',
    storageBucket: 'barberflow-4169a.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBq76JqPEKX-PG2PSaL63Io4qG_zFjoZ4o',
    appId: '1:697711167014:android:eed58a26cbbbf5a79d48e7',
    messagingSenderId: '697711167014',
    projectId: 'barberflow-4169a',
    storageBucket: 'barberflow-4169a.firebasestorage.app',
    iosBundleId: 'com.barberflow.barberflow',
  );
}
