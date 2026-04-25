/// Centraliza segredos lidos via `--dart-define-from-file`.
///
/// Resolvidos em **tempo de compilação** (`const`), portanto:
/// - Trocar valor exige recompilar (desejável para secrets).
/// - Valores não aparecem como string literal no código versionado.
/// - O Dart consegue tree-shake código morto baseado nesses valores.
///
/// Uso:
///   flutter run --dart-define-from-file=env/secrets.json
///
/// O arquivo `env/secrets.json` é gerado por `scripts/setup_env.sh`
/// e está no `.gitignore`.
///
/// **Por que aqui só tem Supabase + Google?**
/// Os valores do Firebase (apiKeys, appIds, etc.) ficam em
/// `lib/firebase_options.dart`, gerado pelo `flutterfire configure` —
/// que também está gitignored. Firebase apiKeys não são "secret" no
/// sentido tradicional (veja docs do Google), a proteção real vem de
/// Firestore Rules + restrição por package name/SHA-1 no GCP Console
/// + Firebase App Check.
class Env {
  const Env._();

  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY');

  static const String googleServerClientId =
      String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');

  static const String viaCepBaseUrl = String.fromEnvironment(
    'VIA_CEP_BASE_URL',
    defaultValue: 'https://viacep.com.br/ws',
  );

  /// Lança [StateError] se algum segredo crítico estiver vazio,
  /// indicando que o app foi compilado sem `--dart-define-from-file`.
  static void assertConfigured() {
    final missing = <String>[
      if (supabaseUrl.isEmpty) 'SUPABASE_URL',
      if (supabaseAnonKey.isEmpty) 'SUPABASE_ANON_KEY',
      if (googleServerClientId.isEmpty) 'GOOGLE_SERVER_CLIENT_ID',
    ];

    if (missing.isNotEmpty) {
      throw StateError(
        'Segredos ausentes: ${missing.join(', ')}.\n'
        'Rode: ./scripts/setup_env.sh e depois ./scripts/run.sh',
      );
    }
  }
}
