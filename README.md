# Cidade Integra Mobile

Aplicativo Flutter para reportar e acompanhar problemas urbanos. Reescrita mobile do projeto web React.

## Pré-requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (>= 3.7.0)
- [Firebase CLI](https://firebase.google.com/docs/cli) (`npm install -g firebase-tools`)
- [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/) (`dart pub global activate flutterfire_cli`)
- Emulador Android ou dispositivo físico conectado

## Setup rápido

### 1. Clonar e instalar dependências

```bash
git clone https://github.com/cidade-integra/cidade-integra-mobile.git
cd cidade-integra-mobile/cidade_integra
flutter pub get
```

### 2. Configurar Firebase

```bash
firebase login
flutterfire configure --project=cidadeintegra
```

Isso gera automaticamente o `lib/firebase_options.dart` e os arquivos de configuração nativos (`google-services.json`, `GoogleService-Info.plist`).

### 3. Configurar Google Sign-In (Android)

1. Acesse o [Firebase Console](https://console.firebase.google.com) → **Authentication** → **Sign-in method** → **Google** e ative.
2. Copie o **Web Client ID**.
3. Atualize em `lib/main.dart` na chamada `GoogleSignIn.instance.initialize(serverClientId: ...)`.
4. Adicione o SHA-1 do seu certificado de debug no Firebase Console → **Configurações** → **Seus apps** → **Adicionar impressão digital**:

```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android
```

### 4. Configurar segredos (Supabase + Google)

Os segredos vivem em `cidade_integra/env/secrets.json` (no `.gitignore`) e são injetados em tempo de build via `--dart-define-from-file`. Para criar o arquivo:

```bash
cd cidade_integra
./scripts/setup_env.sh
```

O script vai pedir interativamente:
- `SUPABASE_URL` e `SUPABASE_ANON_KEY` — Supabase Dashboard → Project Settings → API
- `GOOGLE_SERVER_CLIENT_ID` — Google Cloud Console → Credentials → OAuth 2.0 Client IDs (Web)

### 5. Rodar o app

```bash
# Sempre via script wrapper para garantir que os segredos são injetados
./scripts/run.sh
```

Se executar direto `flutter run` sem segredos, o app exibe uma tela de configuração explicando como corrigir (em vez de crashar). Isso é intencional para que estudantes/colaboradores que clonem o repo entendam imediatamente o que falta.

## Segurança — o que NÃO commitar

Os seguintes arquivos contêm chaves e tokens sensíveis. Verifique que estão no `.gitignore` antes de qualquer commit:

| Arquivo | Contém |
|---------|--------|
| `google-services.json` | API keys do Firebase (Android) |
| `GoogleService-Info.plist` | API keys do Firebase (iOS/macOS) |
| `firebase_options.dart` | Chaves do Firebase geradas pelo FlutterFire |
| `key.properties` | Senhas da keystore de release |
| `*.jks` | Keystore de assinatura |

> Se algum desses arquivos já foi commitado no repositório, considere rotacionar as chaves no Firebase Console.

## Estrutura do projeto

```
lib/
├── main.dart              # Ponto de entrada + tela de erro de config
├── firebase_options.dart   # Config Firebase (gerado, .gitignored)
├── models/                 # Entidades (Report, AppUser, Comment + UserStatus)
├── services/               # Firestore, Supabase, APIs externas, Privacy
├── providers/              # AuthProvider (estado global + bloqueio LGPD)
├── screens/                # 18 telas (incl. config_error, legal, admin)
├── widgets/                # Componentes (layout, denuncias, common/image_viewer)
├── routes/                 # GoRouter + guards
├── utils/                  # Tema, InputSanitizer, RateLimiter, ScrollToTop
├── config/                 # Env (segredos via --dart-define)
└── data/                   # Dados estáticos (categorias, FAQ, equipe)

assets/legal/               # Termos de Uso e Política de Privacidade (.md)
firestore.rules             # Regras versionadas + validação server-side
functions/                  # Cloud Functions (setAdminClaim, logAuditEvent)
```

## Tecnologias

| Camada | Tecnologia |
|--------|-----------|
| Framework | Flutter / Dart |
| Auth | Firebase Authentication + Google Sign-In |
| Banco de dados | Cloud Firestore |
| Storage de imagens | Supabase Storage |
| Notificações | Firebase Cloud Messaging |
| Mapas | flutter_map + OpenStreetMap |
| Estado | Provider (ChangeNotifier) |
| Navegação | go_router |

## Documentação

- [`planning/sdl.md`](planning/sdl.md) — **SDL (Security Development Lifecycle)** — documento único de segurança, inclui matriz LGPD do ciclo de conta (active/suspended/banned/deleted)
- [`planning/plano-resposta-incidentes.md`](planning/plano-resposta-incidentes.md) — Plano de Resposta a Incidentes
- [`planning/planejamento-tasks.md`](planning/planejamento-tasks.md) — Plano de desenvolvimento (10 milestones, ~40 tasks)
