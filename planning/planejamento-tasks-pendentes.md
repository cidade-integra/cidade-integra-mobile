# Tasks Pendentes para Lançamento — Cidade Integra Mobile

> Tasks restantes para atingir a versão 1.0, seguindo o template de [`estrutura-task.md`](./estrutura-task.md).
>
> Derivadas das Fases 4 e 5 do [SDL](./planejamento-sld.md) (Verificação e Lançamento).

---

## Índice

| # | Task | Tipo | Pontos | Branch |
|---|------|------|--------|--------|
| 1 | Sanitização de Inputs e Superfícies de Ataque | 🔴 Refatoração | 8 | `security/sanitizacao-inputs` |
| 2 | Validação Server-Side com Firestore Rules | 🔵 Integração | 5 | `security/firestore-rules-validation` |
| 3 | Proteção contra Abuso e Rate Limiting | 🔵 Integração | 5 | `security/rate-limiting` |
| 4 | Integrar Firebase Crashlytics | 🔵 Integração | 5 | `feature/crashlytics` |
| 5 | Integrar Firebase Analytics | 🔵 Integração | 3 | `feature/analytics` |
| 6 | Integrar Firebase App Check | 🔵 Integração | 5 | `feature/app-check` |
| 7 | Testes de Integração E2E | 🔴 Refatoração | 8 | `test/integracao-e2e` |
| 8 | Preparar Assets para Publicação | 🟠 UX | 3 | `chore/preparar-publicacao` |

**Total: 42 pontos em 8 tasks**

---

### 🔴 [Refatoração | 8 pontos] Sanitização de Inputs e Superfícies de Ataque

#### 🧩 Descrição
Auditar e fortalecer todas as superfícies de entrada de dados do app contra ataques de injeção, XSS persistido e dados malformados. Cada ponto onde o usuário insere texto que será persistido no Firestore ou enviado a APIs externas deve ser sanitizado e validado em profundidade.

#### 🎯 Objetivo e Critérios de Aceite
- [ ] **Formulário de denúncia** (`nova_denuncia_screen.dart`): sanitizar `title` e `description` removendo tags HTML/script, caracteres de controle e espaços excessivos antes de salvar no Firestore.
- [ ] **Comentários** (`comment_section.dart`): sanitizar `message` com as mesmas regras. Implementar lista de palavras bloqueadas (`blockedWords`) como no React (`BLOCKED_WORDS`).
- [ ] **Editar perfil** (`editar_perfil_screen.dart`): sanitizar `displayName`, `bio` e `region`.
- [ ] **Registro** (`register_screen.dart`): validar formato de email com regex robusto (não apenas `contains('@')`). Sanitizar `displayName`.
- [ ] **CEP** (`nova_denuncia_screen.dart`): validar formato `00000-000` com regex antes de chamar a API ViaCEP. Tratar resposta malformada da API.
- [ ] Criar utilitário `lib/utils/input_sanitizer.dart` com funções reutilizáveis: `sanitizeText(String)`, `sanitizeHtml(String)`, `isValidEmail(String)`, `isValidCep(String)`, `containsBlockedWords(String)`.
- [ ] Adicionar limite de tamanho máximo em todos os `TextFormField` com `maxLength` (título: 100, descrição: 2000, comentário: 500, bio: 200, nome: 60).
- [ ] Validar que URLs de imagem retornadas pelo Supabase são do domínio esperado antes de exibir com `Image.network`.

#### 🔍 Referência no projeto antigo (React)
- `frontend/src/schema/DenunciaFormSchema.jsx` — validação com Zod (regex para nome, min/max lengths)
- `frontend/src/components/denuncias/ComentarioCard.jsx` — `BLOCKED_WORDS` e `containsBlockedWords`

#### 📝 O que aprender para realizar essa task? (Foco em Flutter)
- `RegExp` no Dart para validação de padrões
- Sanitização de strings: `replaceAll`, `trim`, remoção de caracteres perigosos
- Princípio de "never trust user input" — validar no client E no server (Firestore Rules)
- https://dart.dev/guides/libraries/library-tour#strings-and-regular-expressions

#### 🌱 Sugestão de Branch
`security/sanitizacao-inputs`

### 🤓 Dica: por onde começar

```dart
// lib/utils/input_sanitizer.dart

class InputSanitizer {
  static final _htmlTagRegex = RegExp(r'<[^>]*>');
  static final _controlCharRegex = RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F]');
  static final _multiSpaceRegex = RegExp(r'\s{2,}');
  static final _emailRegex = RegExp(r'^[\w\.\-]+@[\w\.\-]+\.\w{2,}$');
  static final _cepRegex = RegExp(r'^\d{5}-?\d{3}$');

  static const blockedWords = [
    'idiota', 'imbecil', 'burro', // adicionar lista completa
  ];

  static String sanitize(String input) {
    return input
        .replaceAll(_htmlTagRegex, '')
        .replaceAll(_controlCharRegex, '')
        .replaceAll(_multiSpaceRegex, ' ')
        .trim();
  }

  static bool isValidEmail(String email) => _emailRegex.hasMatch(email);
  static bool isValidCep(String cep) => _cepRegex.hasMatch(cep.replaceAll('-', ''));

  static bool containsBlockedWords(String text) {
    final lower = text.toLowerCase();
    return blockedWords.any((w) => lower.contains(w));
  }

  static String? validateImageUrl(String url) {
    final allowed = ['fyjefwpyesgedvfuewiw.supabase.co', 'firebasestorage.googleapis.com'];
    final uri = Uri.tryParse(url);
    if (uri == null || !allowed.any((d) => uri.host.contains(d))) return null;
    return url;
  }
}
```

---

### 🔵 [Integração | 5 pontos] Validação Server-Side com Firestore Rules

#### 🧩 Descrição
Fortalecer as Firestore Security Rules para validar a estrutura e o conteúdo dos dados antes de aceitar escritas. As regras client-side podem ser contornadas — a validação real precisa estar no server.

#### 🎯 Objetivo e Critérios de Aceite
- [ ] **Reports — create:** validar que `title` é string com 3-100 chars, `description` é string com 10-2000 chars, `category` está na lista permitida, `status` é `pending`, `createdAt`/`updatedAt` são timestamps do servidor.
- [ ] **Reports — update:** validar que apenas `status`, `updatedAt` e `resolvedAt` podem ser alterados (não título/descrição/userId). Validar que `status` é um dos valores permitidos.
- [ ] **Comments — create:** validar que `message` é string com 5-500 chars, `authorId` corresponde ao `request.auth.uid`, `createdAt` é server timestamp.
- [ ] **Users — update:** validar que campos sensíveis (`role`, `score`, `reportCount`) só podem ser alterados por admin. Usuário comum só pode alterar `displayName`, `bio`, `region`.
- [ ] Arquivo `firestore.rules` versionado no repositório.
- [ ] Testes de rules com Firebase Emulator (`firebase emulators:start`).

#### 🔍 Referência no projeto antigo (React)
- Regras já existentes no Firebase Console (compartilhadas pelo usuário nesta conversa)

#### 📝 O que aprender para realizar essa task? (Foco em Flutter)
- Firestore Security Rules syntax: `request.resource.data`, `resource.data`, `hasAll`, `size()`
- `request.resource.data.title is string && request.resource.data.title.size() >= 3`
- Firebase Emulator para testar rules localmente
- https://firebase.google.com/docs/firestore/security/rules-conditions
- https://firebase.google.com/docs/firestore/security/test-rules-emulator

#### 🌱 Sugestão de Branch
`security/firestore-rules-validation`

### 🤓 Dica: por onde começar

```
// firestore.rules — exemplo de validação na criação de report
match /reports/{reportId} {
  allow create: if request.auth != null
    && request.resource.data.title is string
    && request.resource.data.title.size() >= 3
    && request.resource.data.title.size() <= 100
    && request.resource.data.description is string
    && request.resource.data.description.size() >= 10
    && request.resource.data.description.size() <= 2000
    && request.resource.data.category in ['buracos','iluminacao','lixo','vazamentos','areasVerdes','outros']
    && request.resource.data.status == 'pending';
}
```

---

### 🔵 [Integração | 5 pontos] Proteção contra Abuso e Rate Limiting

#### 🧩 Descrição
Implementar mecanismos para prevenir abuso do sistema: limite de criação de denúncias por período, throttling de comentários, proteção contra spam e detecção de comportamento anômalo.

#### 🎯 Objetivo e Critérios de Aceite
- [ ] **Rate limit client-side:** limitar criação de denúncias a 5 por hora por usuário. Armazenar timestamps localmente e verificar antes de permitir envio.
- [ ] **Rate limit client-side:** limitar comentários a 10 por hora por usuário por denúncia.
- [ ] **Debounce em buscas:** garantir que chamadas de busca/filtro não disparem múltiplas requisições simultâneas (debounce de 400ms).
- [ ] **Proteção de formulários:** desabilitar botão de submit durante processamento para evitar duplo-envio.
- [ ] **Firestore Rules — rate limiting server-side:** regra que verifica `request.time` contra o último `createdAt` do usuário para impedir criação em massa.
- [ ] **Monitoramento:** log de tentativas bloqueadas para análise posterior.

#### 🔍 Referência no projeto antigo (React)
- `frontend/src/hooks/useFilteredPaginatedReports.jsx` — debounce de 400ms na busca
- Firestore Rules existentes não incluem rate limiting

#### 📝 O que aprender para realizar essa task? (Foco em Flutter)
- `SharedPreferences` para armazenar timestamps de ações locais
- `Timer` e debounce patterns no Dart
- Firestore Rules com `request.time` para rate limiting server-side
- https://firebase.google.com/docs/firestore/security/rules-conditions#access_other_documents

#### 🌱 Sugestão de Branch
`security/rate-limiting`

### 🤓 Dica: por onde começar

```dart
// lib/utils/rate_limiter.dart
import 'package:shared_preferences/shared_preferences.dart';

class RateLimiter {
  static Future<bool> canPerformAction(String actionKey, {int maxPerHour = 5}) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'rate_$actionKey';
    final timestamps = prefs.getStringList(key) ?? [];

    final now = DateTime.now();
    final oneHourAgo = now.subtract(const Duration(hours: 1));

    // Remover timestamps antigos
    final recent = timestamps
        .map(DateTime.parse)
        .where((t) => t.isAfter(oneHourAgo))
        .toList();

    if (recent.length >= maxPerHour) return false;

    recent.add(now);
    await prefs.setStringList(key, recent.map((t) => t.toIso8601String()).toList());
    return true;
  }
}

// Uso no formulário de denúncia:
// if (!await RateLimiter.canPerformAction('create_report', maxPerHour: 5)) {
//   showSnackBar('Limite de denúncias por hora atingido. Tente novamente mais tarde.');
//   return;
// }
```

---

### 🔵 [Integração | 5 pontos] Integrar Firebase Crashlytics

#### 🧩 Descrição
Adicionar o Firebase Crashlytics ao projeto para monitoramento de crashes em produção. Configurar captura automática de erros fatais e não-fatais, com envio de relatórios ao console do Firebase.

#### 🎯 Objetivo e Critérios de Aceite
- [ ] Pacote `firebase_crashlytics` adicionado e configurado.
- [ ] `FlutterError.onError` redirecionado para `FirebaseCrashlytics.instance.recordFlutterFatalError`.
- [ ] Erros não-Flutter capturados via `PlatformDispatcher.instance.onError`.
- [ ] Crashes aparecem no Firebase Console → Crashlytics.
- [ ] Serviço testado com `FirebaseCrashlytics.instance.crash()` em debug.

#### 🔍 Referência no projeto antigo (React)
- Não existia no projeto React. Funcionalidade nova para mobile.

#### 📝 O que aprender para realizar essa task? (Foco em Flutter)
- `firebase_crashlytics` package
- `FlutterError.onError` e `PlatformDispatcher.instance.onError`
- `runZonedGuarded` para captura de erros assíncronos
- https://firebase.flutter.dev/docs/crashlytics/overview

#### 🌱 Sugestão de Branch
`feature/crashlytics`

### 🤓 Dica: por onde começar

```dart
// main.dart — adicionar no void main()
FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
PlatformDispatcher.instance.onError = (error, stack) {
  FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  return true;
};
```

---

### 🔵 [Integração | 3 pontos] Integrar Firebase Analytics

#### 🧩 Descrição
Adicionar o Firebase Analytics para rastrear eventos de uso do app: telas visitadas, ações do usuário (login, criar denúncia, comentar) e métricas de engajamento.

#### 🎯 Objetivo e Critérios de Aceite
- [ ] Pacote `firebase_analytics` adicionado.
- [ ] `FirebaseAnalyticsObserver` adicionado ao `GoRouter` para tracking de telas.
- [ ] Eventos customizados logados: `login`, `register`, `create_report`, `add_comment`, `save_report`.
- [ ] Eventos aparecem no Firebase Console → Analytics.

#### 🔍 Referência no projeto antigo (React)
- Firebase Analytics já era usado no React para tracking de eventos.

#### 📝 O que aprender para realizar essa task? (Foco em Flutter)
- `firebase_analytics` package
- `FirebaseAnalytics.instance.logEvent()`
- `FirebaseAnalyticsObserver` como `navigatorObserver`
- https://firebase.flutter.dev/docs/analytics/overview

#### 🌱 Sugestão de Branch
`feature/analytics`

### 🤓 Dica: por onde começar

```dart
await FirebaseAnalytics.instance.logEvent(
  name: 'create_report',
  parameters: {'category': report.category.name},
);
```

---

### 🔵 [Integração | 5 pontos] Integrar Firebase App Check

#### 🧩 Descrição
Adicionar o Firebase App Check para proteger os backends (Firestore, Storage) contra abusos por bots e clientes não-autorizados. Garantir que apenas o app legítimo pode acessar os recursos.

#### 🎯 Objetivo e Critérios de Aceite
- [ ] Pacote `firebase_app_check` adicionado.
- [ ] App Check ativado no Firebase Console para Firestore e Storage.
- [ ] `FirebaseAppCheck.instance.activate()` chamado no `main.dart`.
- [ ] Provider configurado: `AndroidProvider.playIntegrity` (Android), `AppleProvider.appAttest` (iOS).
- [ ] Debug token configurado para desenvolvimento local.

#### 🔍 Referência no projeto antigo (React)
- `frontend/src/firebase/config.jsx` — App Check com reCAPTCHA v3

#### 📝 O que aprender para realizar essa task? (Foco em Flutter)
- `firebase_app_check` package
- Play Integrity API (Android) e App Attest (iOS)
- Debug providers para desenvolvimento
- https://firebase.flutter.dev/docs/app-check/overview

#### 🌱 Sugestão de Branch
`feature/app-check`

### 🤓 Dica: por onde começar

```dart
await FirebaseAppCheck.instance.activate(
  androidProvider: AndroidProvider.playIntegrity,
  appleProvider: AppleProvider.appAttest,
);
```

---

### 🔴 [Refatoração | 8 pontos] Testes de Integração E2E

#### 🧩 Descrição
Escrever testes de integração end-to-end que validam fluxos completos da aplicação usando o pacote `integration_test`. Cobrir os fluxos críticos de autenticação, criação de denúncia e navegação.

#### 🎯 Objetivo e Critérios de Aceite
- [ ] Pacote `integration_test` configurado.
- [ ] Teste E2E: splash → home → navegar para denúncias → ver detalhes.
- [ ] Teste E2E: login com e-mail/senha → perfil → editar perfil.
- [ ] Teste E2E: criar denúncia → verificar na listagem.
- [ ] Mocks de Firebase configurados para ambiente de teste.
- [ ] Todos os testes passam com `flutter test integration_test/`.

#### 🔍 Referência no projeto antigo (React)
- Não existiam testes E2E no projeto React.

#### 📝 O que aprender para realizar essa task? (Foco em Flutter)
- `integration_test` package
- `IntegrationTestWidgetsFlutterBinding.ensureInitialized()`
- `fake_cloud_firestore` para mocks de Firestore
- `firebase_auth_mocks` para mocks de autenticação
- https://docs.flutter.dev/testing/integration-tests

#### 🌱 Sugestão de Branch
`test/integracao-e2e`

### 🤓 Dica: por onde começar

```dart
// integration_test/app_test.dart
import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('home screen loads correctly', (tester) async {
    // app.main();
    // await tester.pumpAndSettle();
    // expect(find.text('Cidade Integra'), findsOneWidget);
  });
}
```

---

### 🟠 [UX | 3 pontos] Preparar Assets para Publicação nas Lojas

#### 🧩 Descrição
Preparar os assets necessários para publicação na Google Play Store e Apple App Store: ícone do app, splash screen nativa, screenshots e metadados.

#### 🎯 Objetivo e Critérios de Aceite
- [ ] Ícone do app customizado (substituir o ícone padrão do Flutter).
- [ ] Splash screen nativa configurada (pré-Flutter, enquanto o engine carrega).
- [ ] `applicationId` atualizado de `com.example.cidade_integra` para o definitivo.
- [ ] Screenshots capturadas para listagem na loja (pelo menos 3 telas).
- [ ] Descrição do app e textos para a loja preparados.
- [ ] `versionName` e `versionCode` atualizados para 1.0.0+1.

#### 🔍 Referência no projeto antigo (React)
- PWA icons e manifest existentes no projeto React.

#### 📝 O que aprender para realizar essa task? (Foco em Flutter)
- `flutter_launcher_icons` package para gerar ícones
- `flutter_native_splash` package para splash nativa
- Android: `AndroidManifest.xml`, keystore para release
- iOS: `Info.plist`, certificados e provisioning profiles
- https://docs.flutter.dev/deployment/android
- https://docs.flutter.dev/deployment/ios

#### 🌱 Sugestão de Branch
`chore/preparar-publicacao`

### 🤓 Dica: por onde começar

```yaml
# pubspec.yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/images/Logo.png"

flutter_native_splash:
  color: "#5BC561"
  image: "assets/images/Logo.png"
```
