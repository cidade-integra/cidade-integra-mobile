# Tasks Pendentes para Lançamento — Cidade Integra Mobile

> Tasks restantes para atingir a versão 1.0, seguindo o template de [`estrutura-task.md`](./estrutura-task.md).
>
> Derivadas das Fases 4 e 5 do [SDL](./planejamento-sld.md) (Verificação e Lançamento).

---

## Índice

| # | Task | Tipo | Pontos | Branch |
|---|------|------|--------|--------|
| 1 | Integrar Firebase Crashlytics | 🔵 Integração | 5 | `feature/crashlytics` |
| 2 | Integrar Firebase Analytics | 🔵 Integração | 3 | `feature/analytics` |
| 3 | Integrar Firebase App Check | 🔵 Integração | 5 | `feature/app-check` |
| 4 | Testes de Integração E2E | 🔴 Refatoração | 8 | `test/integracao-e2e` |
| 5 | Preparar Assets para Publicação | 🟠 UX | 3 | `chore/preparar-publicacao` |

**Total: 24 pontos em 5 tasks**

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
