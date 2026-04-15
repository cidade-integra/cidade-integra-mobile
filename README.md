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

### 4. Rodar o app

```bash
flutter run
```

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
├── main.dart              # Ponto de entrada + inicialização
├── firebase_options.dart   # Config Firebase (gerado)
├── models/                 # Entidades (Report, AppUser, Comment)
├── services/               # Firestore, Supabase, APIs externas
├── providers/              # AuthProvider (estado global)
├── screens/                # Telas do app
├── widgets/                # Componentes reutilizáveis
├── routes/                 # GoRouter + guards de autenticação
├── utils/                  # Tema, erros, badges
└── data/                   # Dados estáticos (categorias, FAQ, equipe)
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

- [`planning/planejamento-tasks.md`](planning/planejamento-tasks.md) — Plano completo de tasks (10 milestones)
- [`planning/planejamento-sld.md`](planning/planejamento-sld.md) — Documento SDL (Security Development Lifecycle)
- [`planning/planejamento-tasks-pendentes.md`](planning/planejamento-tasks-pendentes.md) — Tasks pendentes para v1.0
