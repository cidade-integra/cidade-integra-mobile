# Scripts — Cidade Integra

Automação local para gerenciar segredos (Firebase + Supabase + outras APIs)
sem expô-los no código versionado.

## TL;DR

```bash
chmod +x scripts/*.sh        # primeira vez apenas
./scripts/setup_env.sh        # preenche segredos interativamente
./scripts/run.sh              # roda o app com os segredos injetados
```

## Como funciona

1. **`setup_env.sh`** — pergunta cada segredo no terminal e grava em
   `env/secrets.json`. Esse arquivo está no `.gitignore`, com permissão `600`,
   e nunca é commitado.

2. **`run.sh`** — wrapper de `flutter` que injeta `--dart-define-from-file=env/secrets.json`.
   Os valores chegam ao Dart como constantes em tempo de compilação via
   `String.fromEnvironment(...)` em [`lib/config/env.dart`](../lib/config/env.dart).

3. **`env/secrets.example.json`** — template versionado mostrando quais chaves
   existem (sem valores reais). Use como referência.

## Comandos

| Comando | O que faz |
|---|---|
| `./scripts/setup_env.sh` | Modo interativo. Mantém valores existentes ao pressionar Enter. |
| `./scripts/setup_env.sh --check` | Valida que todos os segredos esperados estão preenchidos. |
| `./scripts/setup_env.sh --reset` | Apaga e recria do zero. |
| `./scripts/run.sh` | `flutter run` com segredos. |
| `./scripts/run.sh -d chrome` | Passa flags extras pro `flutter run`. |
| `./scripts/run.sh build apk` | `flutter build apk` com segredos. |
| `./scripts/run.sh test` | `flutter test` com segredos. |

## Onde os segredos eram expostos antes

| Antes | Agora |
|---|---|
| `lib/main.dart` (Supabase URL + anonKey, Google serverClientId) | `Env.supabaseUrl`, `Env.supabaseAnonKey`, `Env.googleServerClientId` |
| `lib/firebase_options.dart` (apiKeys Android/iOS/macOS) | `Env.firebaseAndroidApiKey`, `Env.firebaseIosApiKey`, etc. |

## Dúvidas comuns

**Por que `--dart-define-from-file` em vez de `flutter_dotenv`?**
Sem dependência nova, valores viram `const` (tree-shake melhor) e não vão para
o asset bundle do APK/IPA — onde poderiam ser extraídos com unzip.

**Preciso recompilar pra trocar um segredo?**
Sim. Como `String.fromEnvironment` é compile-time, qualquer mudança em
`secrets.json` exige um novo `flutter run`. Para segredos isso é até desejável.

**E o `google-services.json` e `GoogleService-Info.plist`?**
Esses arquivos ainda contêm IDs do Firebase. Como são necessários no build
nativo (Gradle/Xcode), o ideal é gerá-los a partir de templates no CI ou
mantê-los fora do repositório público. Para o escopo deste script, ficamos
focados nos segredos lidos pelo Dart.

**E se eu rodar `flutterfire configure` de novo?**
Ele sobrescreverá `lib/firebase_options.dart`. Reaplique o patch substituindo
literais por `Env.firebase...` (veja o cabeçalho do arquivo).
