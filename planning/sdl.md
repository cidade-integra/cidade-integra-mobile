# Ciclo de Vida do Desenvolvimento Seguro (SDL) — Cidade Integra Mobile

> **Security Development Lifecycle** — Documento único de segurança do projeto, cobrindo requisitos, design, implementação, verificação e lançamento.
>
> **Documento complementar:** [Plano de Resposta a Incidentes](./plano-resposta-incidentes.md)

---

## Fase 1 — Requisitos

### 1.1 Requisitos Funcionais

| # | Requisito | Descrição |
|---|-----------|-----------|
| 1 | **Autenticação** | Login com e-mail/senha e Google Sign-In via Firebase Auth. Cadastro com criação de perfil no Firestore. Recuperação de senha por e-mail. Verificação de e-mail obrigatória. |
| 2 | **Autorização** | Controle de acesso por `role` (user/admin) em `users/{uid}.role`. Rotas protegidas via `GoRouter.redirect`. Custom Claims via Cloud Function `setAdminClaim`. |
| 3 | **Auditoria** | Coleção `audit_logs` imutável (create only, no update/delete). Cloud Function `logAuditEvent` com enriquecimento de IP e UID. Batch writes para atomicidade. |
| 4 | **CRUD Usuário** | Criação de perfil em `users/{uid}`. Edição de nome, bio e região. Desativação de conta. Exclusão completa com anonimização (LGPD). Exportação de dados pessoais (JSON). |
| 5 | **Denúncias** | Criação com título, descrição, categoria, endereço (ViaCEP), geocodificação (Nominatim), upload de imagens (Supabase Storage), opção anônima. Listagem com filtros e paginação. Detalhes com galeria, mapa e comentários. |
| 6 | **Comentários** | Subcoleção `reports/{id}/comments` com StreamBuilder (tempo real). Validação 5-500 chars. Filtro de palavras ofensivas. |
| 7 | **Notificações** | Firebase Cloud Messaging com token salvo de forma segura (`flutter_secure_storage`). Foreground via `flutter_local_notifications`. |
| 8 | **Painel Administrativo** | Dashboard com estatísticas. Gestão de denúncias com alteração de status + audit log. Gestão de usuários com alteração de role/status. Exportação CSV. |
| 9 | **Gamificação** | 5 badges: Iniciante, Engajado, Vigilante Urbano, Reportador Frequente, Verificado. |
| 10 | **Favoritos** | Subcoleção `users/{uid}/denunciasSalvas`. Bookmark nos detalhes. |

### 1.2 Requisitos Não-Funcionais

#### 1.2.1 Segurança
- **Autenticação:** Firebase Auth com JWT stateless + verificação de e-mail + Google Sign-In.
- **Autorização:** Firestore Rules com funções `isAuth()`, `isOwner()`, `isAdmin()`. GoRouter redirect client-side.
- **Sanitização:** `InputSanitizer` centralizado — remoção de HTML/scripts, blocked words, regex RFC 5322 para email.
- **Rate limiting:** Client-side (5 denúncias/h, 10 comentários/h) via `RateLimiter` + debounce 400ms em buscas.
- **Armazenamento seguro:** `flutter_secure_storage` para tokens sensíveis. Credenciais via `--dart-define-from-file`.
- **Monitoramento:** Firebase Crashlytics (crash reporting) + Firebase Analytics (eventos) + App Check (proteção de backends).

#### 1.2.2 Desempenho
- Queries Firestore com `orderBy` + `limit`. Imagens comprimidas (quality 80, max 1920px). Assets SVG.

#### 1.2.3 Confiabilidade
- Firebase/Supabase com 99.95% SLA. Try-catch em todas as operações async. Mapa de erros Auth em pt-BR.

#### 1.2.4 Manutenibilidade
- Arquitetura em camadas (`models/`, `services/`, `providers/`, `screens/`, `widgets/`). 48 testes automatizados. CI com `flutter analyze` + `dart format` + `flutter test`.

#### 1.2.5 Portabilidade
- Flutter para Android (minSdk 23) e iOS. Design responsivo.

#### 1.2.6 Usabilidade
- Identidade visual consistente (`AppTheme`). `Semantics` e `semanticLabel` para acessibilidade.

#### 1.2.7 Conformidade
- **LGPD:** Denúncia anônima, exportação de dados pessoais (JSON), exclusão de conta com anonimização de comentários, política de privacidade (`assets/legal/politica_privacidade.md`), termos de uso (`assets/legal/termos_de_uso.md`), consentimento no registro.

#### 1.2.8 Interoperabilidade
- APIs: Firebase (Auth, Firestore, FCM, Crashlytics, Analytics, App Check), Supabase Storage, ViaCEP, Nominatim/OpenStreetMap. Formato JSON.

### 1.3 Requisitos de Segurança

| # | Requisito | Implementação |
|---|-----------|---------------|
| 1 | **Tipo da aplicação** | Flutter — Android e iOS (`sdk: ^3.7.0`, `minSdk: 23`) |
| 2 | **Autenticação** | `firebase_auth` + `google_sign_in` + `sendEmailVerification()` |
| 3 | **Validação de telas** | `GoRouter.redirect` com `_protectedRoutes` e `_adminRoutes` |
| 4 | **Armazenamento seguro** | `flutter_secure_storage` para tokens. `--dart-define-from-file` para credenciais. Firestore Rules server-side. |

### 1.4 Requisitos de Privacidade

| Âmbito | Norma | Implementação |
|--------|-------|---------------|
| Nacional | **LGPD** | Denúncia anônima, exportação de dados, exclusão de conta, política de privacidade, consentimento |
| Internacional | **GDPR** | Mesmas proteções da LGPD; consentimento explícito no registro |

### 1.5 Identificação de Riscos

| # | Risco | Prob. | Impacto | Mitigação |
|---|-------|-------|---------|-----------|
| 1 | Acesso não autorizado ao admin | Média | Alto | Firestore Rules `isAdmin()` + GoRouter redirect + Custom Claims |
| 2 | Upload de arquivos maliciosos | Baixa | Médio | Validação tipo (jpg/png/webp) + tamanho (5MB) + whitelist de URLs |
| 3 | Exposição de dados pessoais | Média | Alto | `isAnonymous` flag + `userId` forçado a null + Firestore Rules |
| 4 | Spam de denúncias/comentários | Média | Médio | Rate limiting (5/h denúncias, 10/h comentários) + blocked words + debounce |
| 5 | Injeção de HTML/script | Média | Alto | `InputSanitizer.sanitize()` + Firestore Rules com validação de tipos/tamanhos |
| 6 | Bypass de validação client-side | Alta | Alto | Firestore Rules versionadas (`firestore.rules`) com validação server-side |
| 7 | Abuso por bots | Média | Médio | Firebase App Check (Play Integrity / App Attest) |
| 8 | Elevação de privilégio | Média | Alto | Custom Claims via Cloud Function + Firestore Rules `request.auth.token.admin` |

### 1.6 Superfícies de Ataque

| # | Superfície | Entrada | Proteção implementada |
|---|-----------|---------|----------------------|
| 1 | Formulário de denúncia | `title`, `description`, `address` | `InputSanitizer.sanitize` + blocked words + `maxLength` (100/2000/200) + Firestore Rules |
| 2 | Comentários | `message` | Sanitização + blocked words + min 5 / max 500 + rate limit 10/h + email verified |
| 3 | Edição de perfil | `displayName`, `bio`, `region` | Sanitização + `validateName` + `maxLength` 60/200 |
| 4 | Registro | `displayName`, `email`, `password` | `validateName` + `validateEmail` (RFC 5322) + `sendEmailVerification()` |
| 5 | Upload de imagens | Arquivo binário | Tipo (jpg/png/webp) + tamanho (5MB) + `validateImageUrl` (whitelist) |
| 6 | Busca por CEP | `cep` | Regex `^\d{5}-?\d{3}$` + `maxLength: 9` |
| 7 | Alteração de status (admin) | `status`, `comment` | Firestore Rules `isAdmin()` + audit log + batch write |
| 8 | Alteração de role (admin) | `role` | Cloud Function `setAdminClaim` + Custom Claims |

### 1.7 Utilitários de Segurança

**`InputSanitizer`** (`lib/utils/input_sanitizer.dart`):

| Método | Proteção |
|--------|----------|
| `sanitize(String)` | Remove HTML, `javascript:`/`on*=`, chars de controle, normaliza espaços |
| `validateEmail(String)` | Regex RFC 5322 |
| `validateName(String)` | Min/max + regex letras/acentos |
| `validateText(String)` | Min/max + sanitização + blocked words |
| `isValidCep(String)` | Regex `^\d{5}-?\d{3}$` |
| `containsBlockedWords(String)` | 18+ palavras ofensivas pt-BR |
| `validateImageUrl(String)` | Whitelist de hosts (Supabase, Firebase Storage) |

**`RateLimiter`** (`lib/utils/rate_limiter.dart`):

| Método | Proteção |
|--------|----------|
| `canPerform(key, maxPerHour)` | Limite de ações por hora via SharedPreferences |
| `Debouncer(duration)` | Atrasa execução até input parar (400ms default) |

---

## Fase 2 — Design

### 2.1 Modelagem de Ameaças

**Fluxo de Dados:**

```
Usuário → Flutter App → Firebase Auth (autenticação + email verification)
                      → Firestore (reports, users, comments, audit_logs)
                      → Supabase Storage (imagens)
                      → Nominatim API (geocodificação)
                      → ViaCEP API (endereço)
                      → FCM (notificações push)
                      → Cloud Functions (custom claims, audit log)
```

**Permissões Firestore:**

| Coleção | Leitura | Escrita |
|---------|---------|---------|
| `reports` | Pública | Auth (criar) + validação server-side; Autor/Admin (editar) |
| `reports/{id}/comments` | Pública | Auth (criar) + `authorId == uid` + 5-500 chars; Autor/Admin (editar) |
| `users` | Pública | Próprio usuário ou Admin |
| `users/{uid}/denunciasSalvas` | Próprio | Próprio |
| `audit_logs` | Admin | Auth (criar); **Imutável** (update/delete: false) |
| `auditLogs` | Admin | Auth (criar); **Imutável** |

### 2.2 STRIDE — Aplicação ao Cidade Integra

| Ameaça | Cenário | Mitigação |
|--------|---------|-----------|
| **Spoofing** | Conta falsa para denúncias fraudulentas | Firebase Auth + verificação de e-mail + bloqueio de escrita sem verificação |
| **Tampering** | Adulteração de denúncia após envio | Firestore Rules: apenas autor/admin editam. `updatedAt` server timestamp |
| **Repudiation** | Negação de autoria de denúncia/comentário | `audit_logs` imutável com timestamp, UID, IP (Cloud Function) |
| **Information Disclosure** | Exposição de dados do denunciante | `isAnonymous` flag + `userId` forçado a null + export/exclusão de dados (LGPD) |
| **Denial of Service** | Spam em massa | Rate limiting (5/h) + App Check + blocked words + debounce |
| **Elevation of Privilege** | Acesso admin indevido | Custom Claims via Cloud Function + Firestore Rules `request.auth.token.admin` |

### 2.3 Avaliação de 2FA

**Decisão:** Não implementar neste momento. A verificação de e-mail + Firestore Rules cobre o cenário de Spoofing. 2FA via SMS (Firebase MFA) tem custo (~$0.06/SMS) incompatível com projeto acadêmico. Reavaliar se adotado por prefeituras.

### 2.4 Arquitetura

```
lib/
├── models/          → Domínio (Report, AppUser, Comment)
├── services/        → Infraestrutura (Firebase, Supabase, APIs, Privacy, Analytics)
├── providers/       → Estado (AuthProvider)
├── screens/         → Telas (17 screens + 3 admin)
├── widgets/         → Componentes (layout, denuncias, perfil, home, sobre)
├── routes/          → GoRouter + guards
├── utils/           → InputSanitizer, RateLimiter, AppTheme, BadgeRules
├── config/          → Env (credenciais via dart-define)
└── data/            → Dados estáticos
```

---

## Fase 3 — Implementação

### 3.1 Práticas de Codificação Segura

| # | Prática | Evidência |
|---|---------|-----------|
| 1 | **Validação de entrada** | `Form` + `TextFormField.validator` + `maxLength` em todos os campos |
| 2 | **Sanitização** | `InputSanitizer` aplicado em todas as submissões antes de persistir |
| 3 | **Filtro de conteúdo** | 18+ blocked words verificadas pré-submit |
| 4 | **Validação de URLs** | Whitelist de hosts para `Image.network` |
| 5 | **Firestore Rules** | `firestore.rules` versionado com funções `isAuth()`, `isOwner()`, `isAdmin()` e validação de tipos/tamanhos |
| 6 | **Autenticação** | `authStateChanges()` + `sendEmailVerification()` + bloqueio de escrita sem verificação |
| 7 | **Proteção de rotas** | `GoRouter.redirect` + `EmailVerificationBanner` persistente |
| 8 | **Rate limiting** | `RateLimiter` (5/h denúncias, 10/h comentários) + `Debouncer` (400ms) |
| 9 | **Upload seguro** | Tipo (jpg/png/webp) + tamanho (5MB) + UUID para nomes |
| 10 | **Armazenamento seguro** | `flutter_secure_storage` (encrypted) para FCM token. Limpa no logout |
| 11 | **Crash reporting** | `FirebaseCrashlytics` captura `FlutterError` + `PlatformDispatcher` errors |
| 12 | **App Check** | `playIntegrity` (Android) + `appAttest` (iOS) para proteger backends |
| 13 | **Credenciais** | `--dart-define-from-file` para secrets. Nada hardcoded |
| 14 | **CI/CD** | GitHub Actions: `flutter analyze` + `dart format` + `flutter test`. Dependabot semanal |

### 3.2 Cloud Functions

| Função | Finalidade | Segurança |
|--------|-----------|-----------|
| `setAdminClaim` | Atribuir/revogar custom claim `admin` | Apenas callable por admins existentes |
| `logAuditEvent` | Registrar evento em `audit_logs` com IP | Auth required, coleção imutável |

---

## Fase 4 — Verificação

### 4.1 Testes Automatizados

| Tipo | Quantidade | Cobertura |
|------|-----------|-----------|
| Testes unitários | 35 | `Report`, `AppUser`, `InputSanitizer`, `BadgeRules`, `ReportLocation` |
| Testes de widget | 13 | `StatusBadge`, `CardDenuncia` |
| Testes E2E | Configurado | `integration_test/app_test.dart` com `IntegrationTestWidgetsFlutterBinding` |
| Análise estática | CI | `flutter analyze --fatal-infos --fatal-warnings` |
| **Total** | **48** | |

### 4.2 Checklist de Pentest (OWASP MASVS)

Baseado no [OWASP MASVS](https://mas.owasp.org/MASVS/) — níveis L1/L2:

| Categoria | Itens | Status |
|-----------|-------|--------|
| V1 — Arquitetura | Componentes identificados, STRIDE criado, dados classificados | ✅ |
| V2 — Armazenamento | `flutter_secure_storage` para tokens, credenciais via `--dart-define-from-file`, sem hardcoded | ✅ |
| V3 — Criptografia | Firebase Auth JWT, TLS em todas as comunicações, sem chaves simétricas hardcoded | ✅ |
| V4 — Autenticação | Firebase Auth, sessão JWT, logout invalida sessão, verificação de e-mail, 2FA avaliado | ✅ |
| V5 — Rede | TLS obrigatório (Firebase/Supabase forçam HTTPS), certificado verificado pelo runtime | ✅ |
| V6 — Plataforma | Inputs sanitizados via `InputSanitizer`, sem WebView, sem deep links expostos | ✅ |
| V7 — Código | Debugging desabilitado em release, CI com análise estática e formatação, Dependabot semanal | ✅ |

**Ferramenta de análise:** MobSF sobre APK release para validação automatizada.

### 4.3 Revisão de Segurança

| Requisito | Status |
|-----------|--------|
| Autenticação (1.3) | ✅ Firebase Auth + email verification + Google Sign-In |
| Autorização (1.3) | ✅ Firestore Rules + GoRouter redirect + Custom Claims |
| Mitigações STRIDE (2.2) | ✅ Todas as 6 categorias com mitigações implementadas |
| Conformidade LGPD (1.4) | ✅ Anonimato, exportação, exclusão, política, consentimento |
| Superfícies de ataque (1.6) | ✅ 8 superfícies mapeadas e protegidas |

---

## Fase 5 — Lançamento

### 5.1 Plano de Resposta a Incidentes

Documento completo em [`plano-resposta-incidentes.md`](./plano-resposta-incidentes.md), cobrindo:
- Classificação de incidentes (Crítico/Alto/Médio/Baixo)
- Fases: Detecção → Contenção → Erradicação → Recuperação → Lições Aprendidas
- Ferramentas: Firebase Crashlytics, Analytics, Firestore Audit Logs
- Checklist rápido para impressão

### 5.2 Revisão Final

| Item | Status |
|------|--------|
| Requisitos de segurança (1.3) cumpridos | ✅ |
| Requisitos de privacidade (1.4) cumpridos | ✅ |
| Mitigações STRIDE implementadas e testadas | ✅ |
| Plano de resposta a incidentes documentado | ✅ |
| CI/CD configurado com análise estática | ✅ |
| 48 testes automatizados passando | ✅ |
| Firestore Rules versionadas e deployadas | ✅ |
| Política de privacidade e termos de uso | ✅ |
| Pentest checklist OWASP MASVS verificado | ✅ |
