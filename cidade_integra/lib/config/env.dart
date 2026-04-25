/// Centraliza leitura de segredos via `--dart-define-from-file`.
///
/// Cada valor é resolvido em tempo de compilação (`const`), portanto:
/// - Para trocar um valor é necessário recompilar o app.
/// - Valores nunca aparecem em string literals do código-fonte versionado.
///
/// Uso:
///   flutter run --dart-define-from-file=env/secrets.json
///
/// O arquivo `env/secrets.json` é gerado pelo script `scripts/setup_env.sh`
/// e está listado no `.gitignore`.
class Env {
  const Env._();

  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY');

  static const String googleServerClientId =
      String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');

  static const String firebaseAndroidApiKey =
      String.fromEnvironment('FIREBASE_ANDROID_API_KEY');
  static const String firebaseAndroidAppId =
      String.fromEnvironment('FIREBASE_ANDROID_APP_ID');

  static const String firebaseIosApiKey =
      String.fromEnvironment('FIREBASE_IOS_API_KEY');
  static const String firebaseIosAppId =
      String.fromEnvironment('FIREBASE_IOS_APP_ID');

  static const String firebaseMacosApiKey =
      String.fromEnvironment('FIREBASE_MACOS_API_KEY');
  static const String firebaseMacosAppId =
      String.fromEnvironment('FIREBASE_MACOS_APP_ID');

  static const String firebaseMessagingSenderId =
      String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
  static const String firebaseProjectId =
      String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const String firebaseStorageBucket =
      String.fromEnvironment('FIREBASE_STORAGE_BUCKET');

  static const String firebaseAndroidClientId =
      String.fromEnvironment('FIREBASE_ANDROID_CLIENT_ID');
  static const String firebaseIosClientId =
      String.fromEnvironment('FIREBASE_IOS_CLIENT_ID');
  static const String firebaseIosBundleId =
      String.fromEnvironment('FIREBASE_IOS_BUNDLE_ID');

  static const String viaCepBaseUrl = String.fromEnvironment(
    'VIA_CEP_BASE_URL',
    defaultValue: 'https://viacep.com.br/ws',
  );

  /// Lança [StateError] na inicialização se algum segredo crítico estiver vazio,
  /// indicando que o app foi compilado sem `--dart-define-from-file`.
  static void assertConfigured() {
    final missing = <String>[
      if (supabaseUrl.isEmpty) 'SUPABASE_URL',
      if (supabaseAnonKey.isEmpty) 'SUPABASE_ANON_KEY',
      if (firebaseAndroidApiKey.isEmpty) 'FIREBASE_ANDROID_API_KEY',
      if (firebaseProjectId.isEmpty) 'FIREBASE_PROJECT_ID',
    ];

    if (missing.isNotEmpty) {
      throw StateError(
        'Segredos ausentes: ${missing.join(', ')}.\n'
        'Rode: ./scripts/setup_env.sh e depois ./scripts/run.sh',
      );
    }
  }
}
