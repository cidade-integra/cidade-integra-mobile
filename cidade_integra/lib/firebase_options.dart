// ARQUIVO PLACEHOLDER — será substituído pelo `flutterfire configure`
//
// Para gerar o arquivo real, execute:
//   dart pub global activate flutterfire_cli
//   flutterfire configure --project=cidadeintegra
//
// Isso vai gerar este arquivo automaticamente com as chaves do seu projeto.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions não configurado para ${defaultTargetPlatform.name}. '
          'Execute: flutterfire configure',
        );
    }
  }

  // TODO: substituir pelos valores reais após `flutterfire configure`
  static const android = FirebaseOptions(
    apiKey: 'PLACEHOLDER',
    appId: 'PLACEHOLDER',
    messagingSenderId: 'PLACEHOLDER',
    projectId: 'cidadeintegra',
    storageBucket: 'cidadeintegra.firebasestorage.app',
  );

  static const ios = FirebaseOptions(
    apiKey: 'PLACEHOLDER',
    appId: 'PLACEHOLDER',
    messagingSenderId: 'PLACEHOLDER',
    projectId: 'cidadeintegra',
    storageBucket: 'cidadeintegra.firebasestorage.app',
    iosBundleId: 'com.example.cidadeIntegra',
  );
}
