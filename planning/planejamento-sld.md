# Ciclo de Vida do Desenvolvimento Seguro (SDL) — Cidade Integra Mobile

> **Security Development Lifecycle** — Documento preenchido com base no repositório `cidade-integra-mobile` e no projeto Firebase `cidadeintegra`.

---

## Fase 1 — Requisitos

### 1.1 Requisitos Funcionais

Regras de negócio implementadas na aplicação:

| # | Requisito | Descrição | Status |
|---|-----------|-----------|--------|
| 1 | **Autenticação** | Login com e-mail/senha e Google Sign-In via Firebase Auth. Cadastro com criação de perfil no Firestore. Recuperação de senha por e-mail. | ✅ Implementado |
| 2 | **Autorização** | Controle de acesso por `role` (user/admin) armazenado em `users/{uid}.role`. Rotas protegidas via `GoRouter.redirect`. Admin pode alterar role e status de outros usuários. | ✅ Implementado |
| 3 | **Auditoria** | Registro de ações administrativas na coleção `auditLogs` com timestamp, userId, reportId, ação e comentário. Utiliza batch writes para atomicidade. | ✅ Implementado |
| 4 | **CRUD Usuário** | Criação automática do documento em `users/{uid}` no registro. Leitura do perfil. Atualização de nome, bio e região. Desativação de conta (status → inactive + signOut). | ✅ Implementado |
| 5 | **Denúncias** | Criação com título, descrição, categoria (6 opções), endereço (autopreenchimento via ViaCEP), geocodificação (Nominatim), upload de imagens (Supabase Storage), checkbox anônima. Listagem com busca, filtros por status/categoria e paginação. Detalhes com galeria de imagens, mapa OpenStreetMap e informações completas. | ✅ Implementado |
| 6 | **Comentários** | Subcoleção `reports/{id}/comments` com StreamBuilder para tempo real. Criação por usuários autenticados com validação (5-500 chars). Exibição com avatar, badge de role e tempo relativo. | ✅ Implementado |
| 7 | **Notificações** | Firebase Cloud Messaging (FCM) com permissão, token salvo no Firestore, foreground via `flutter_local_notifications`, background handler. | ✅ Implementado |
| 8 | **Painel Administrativo** | Dashboard com estatísticas e gráficos. Gestão de denúncias (busca, filtros, alteração de status com audit log). Gestão de usuários (busca, alteração de role e status). Exportação CSV. | ✅ Implementado |
| 9 | **Gamificação** | Sistema de badges baseado em score, reportCount e verified. 5 badges: Iniciante, Engajado, Vigilante Urbano, Reportador Frequente, Verificado. | ✅ Implementado |
| 10 | **Favoritos** | Salvar/remover denúncias na subcoleção `users/{uid}/denunciasSalvas`. Ícone de bookmark nos detalhes. Listagem na aba "Salvas" do perfil. | ✅ Implementado |

### 1.2 Requisitos Não-Funcionais

#### 1.2.1 Segurança

- **Proteção contra acessos não autorizados:** Firebase Authentication com JWT stateless. Regras de segurança no Firestore com verificação de `request.auth` e validação de `role` via `get()`.
- **Resistência a ataques:** Validação de entradas em todos os formulários (título mín. 3 chars, descrição mín. 10, email válido, senha mín. 6). Sanitização de dados antes de persistir no Firestore.
- **Conformidade com regulamentos:** Adesão à LGPD — denúncias anônimas disponíveis, dados pessoais protegidos por regras Firestore, `isAnonymous` flag no documento.

#### 1.2.2 Desempenho

- **Tempo de resposta:** Queries Firestore com `orderBy` e `limit` para paginação eficiente. Carregamento client-side com filtros para listagem.
- **Eficiência de recursos:** Imagens comprimidas antes do upload (`imageQuality: 80`, `maxWidth: 1920`). Assets SVG para logos e ícones.
- **Escalabilidade:** Firestore auto-escalável. Supabase Storage para imagens separado do banco de dados.

#### 1.2.3 Confiabilidade

- **Disponibilidade:** Firebase e Supabase oferecem 99.95% de uptime SLA.
- **Recuperação de falhas:** Firestore com backups automáticos. Try-catch em todas as operações assíncronas com feedback via SnackBar.
- **Tratamento de erros:** Mapa de erros Firebase Auth em português (`auth_error_mapper.dart`). Estados de loading, erro e vazio em todas as telas.

#### 1.2.4 Manutenibilidade

- **Documentação técnica:** Planejamento de tasks com 10 milestones e ~40 tasks documentadas.
- **Modularidade:** Separação em camadas: `models/`, `services/`, `providers/`, `widgets/`, `screens/`, `routes/`, `utils/`.
- **Testes automatizados:** 23 testes unitários e de widget cobrindo models, badge rules, StatusBadge e CardDenuncia.

#### 1.2.5 Portabilidade

- **Compatibilidade multiplataforma:** Flutter com suporte a Android e iOS. `minSdk = 23` (Android 6.0+).
- **Adaptação a ambientes:** Design responsivo com `SingleChildScrollView`, `Wrap` e `MediaQuery`. Layouts adaptáveis para diferentes tamanhos de tela.

#### 1.2.6 Usabilidade

- **Interface intuitiva:** Design com identidade visual consistente (cores da marca via `AppTheme`). Splash screen animada. Drawer com navegação condicional.
- **Acessibilidade:** `Semantics` em widgets interativos (`CardDenuncia`, `StatusBadge`). `semanticLabel` em imagens. Tooltips em botões de ícone.

#### 1.2.7 Conformidade

- **Padrões técnicos:** Firebase Authentication (OAuth 2.0), Firestore Security Rules, Conventional Commits, GoRouter para navegação declarativa.
- **Legislação:** LGPD — opção de denúncia anônima, desativação de conta, dados pessoais protegidos.

#### 1.2.8 Interoperabilidade

- **APIs externas integradas:**
  - **ViaCEP** (`https://viacep.com.br/ws/{cep}/json/`) — autopreenchimento de endereço
  - **Nominatim/OpenStreetMap** (`nominatim.openstreetmap.org`) — geocodificação
  - **Supabase Storage** — upload de imagens no bucket `reports`
  - **Firebase** — Auth, Firestore, Cloud Messaging
- **Padronização de formatos:** JSON para comunicação com APIs. `Timestamp` para datas no Firestore.

#### 1.2.9 Ética e Privacidade

- **Proteção de dados pessoais:** Flag `isAnonymous` nas denúncias. Dados do perfil editáveis e desativáveis pelo próprio usuário.
- **Transparência:** Tela de termos de uso e política de privacidade referenciada no registro.

#### 1.2.10 Padrões Organizacionais

- **Políticas internas:** Conventional Commits em inglês. Branches por feature/fix/enhancement. PRs com descrição e critérios de aceite.
- **Infraestrutura:** Firebase projeto `cidadeintegra`. Supabase projeto `fyjefwpyesgedvfuewiw`.

### 1.3 Requisitos de Segurança

| # | Requisito | Descrição | Implementação |
|---|-----------|-----------|---------------|
| 1 | **Tipo da aplicação** | Aplicação multiplataforma (Flutter — Android e iOS) | `pubspec.yaml` com `sdk: ^3.7.0`, `minSdk: 23` |
| 2 | **Autenticação** | Firebase Authentication com e-mail/senha e Google Sign-In | `firebase_auth: ^6.2.0`, `google_sign_in: ^7.2.0`, `AuthProvider` com `authStateChanges` |
| 3 | **Validação de telas** | Rotas protegidas e admin com redirect no GoRouter | `app_router.dart` com listas `_protectedRoutes` e `_adminRoutes`, verificação de `auth.isLoggedIn` e `auth.isAdmin` |
| 4 | **Armazenamento seguro** | Dados no Firestore com regras de segurança. Imagens no Supabase com RLS | Regras Firestore no console; Supabase com anon key (público para leitura, upload autenticado) |

### 1.4 Requisitos de Privacidade

| Âmbito | Norma aplicável | Implementação no projeto |
|--------|----------------|--------------------------|
| Nacional | **LGPD** — Lei Geral de Proteção de Dados | Denúncia anônima (`isAnonymous`), desativação de conta, dados pessoais protegidos por Firestore Rules |
| Internacional | **GDPR** — General Data Protection Regulation | Mesmas proteções da LGPD; consentimento no registro (checkbox de termos) |

### 1.5 Identificação de Riscos

| # | Risco | Probabilidade | Impacto | Mitigação |
|---|-------|--------------|---------|-----------|
| 1 | Acesso não autorizado ao painel admin | Média | Alto | Verificação de `role` no Firestore Rules + redirect no GoRouter |
| 2 | Upload de arquivos maliciosos | Baixa | Médio | Validação de tipo (jpg/png/webp) e tamanho (5MB) no `SupabaseService` |
| 3 | Exposição de dados pessoais em denúncias | Média | Alto | Flag `isAnonymous`, regras Firestore por `userId` |
| 4 | Spam de denúncias/comentários | Média | Médio | Validação de min/max chars; autenticação obrigatória para escrita |
| 5 | Token FCM exposto | Baixa | Baixo | Token salvo apenas no doc do próprio usuário com regras de escrita |
| 6 | Chaves Supabase no código-fonte | Alta | Baixo | Anon key é pública por design; proteção via RLS no Supabase |

---

## Fase 2 — Design

### 2.1 Modelagem de Ameaças

**Fluxo de Dados Principal:**

```
Usuário → Flutter App → Firebase Auth (autenticação)
                      → Firestore (dados: reports, users, comments, auditLogs)
                      → Supabase Storage (imagens)
                      → Nominatim API (geocodificação)
                      → ViaCEP API (endereço)
                      → FCM (notificações push)
```

**Coleções Firestore:**

| Coleção | Leitura | Escrita | Observação |
|---------|---------|---------|------------|
| `reports` | Pública | Autenticada (criar); Autor/Admin (editar/deletar) | Denúncias |
| `reports/{id}/comments` | Pública | Autenticada (criar); Autor/Admin (editar/deletar) | Comentários |
| `users` | Pública | Próprio usuário ou Admin | Perfis |
| `users/{uid}/denunciasSalvas` | Próprio usuário | Próprio usuário | Favoritos |
| `auditLogs` | Admin | Autenticada (criar); Imutável (update/delete) | Logs de auditoria |

### 2.2 STRIDE — Aplicação ao Cidade Integra

| Ameaça | Cenário no Cidade Integra | Mitigação implementada |
|--------|---------------------------|------------------------|
| **Spoofing** | Atacante cria conta falsa para denúncias fraudulentas ou se passa por admin. | Firebase Auth com verificação de e-mail; `role` validado server-side via Firestore Rules `get()`. |
| **Tampering** | Adulteração de denúncia (localização, descrição, fotos) após envio. | Firestore Rules: apenas autor ou admin podem editar. `updatedAt` com `serverTimestamp()`. |
| **Repudiation** | Usuário nega ter criado denúncia ou comentário. | `auditLogs` com timestamp, userId, userName, ação e comentário. `createdAt` com server timestamp. |
| **Information Disclosure** | Exposição de dados pessoais do denunciante. | `isAnonymous` flag; regras Firestore restritivas em `users`; `denunciasSalvas` acessível apenas pelo dono. |
| **Denial of Service** | Spam de denúncias ou requisições excessivas. | Validação de campos (min/max chars); autenticação obrigatória; validação de tipo/tamanho de imagem. |
| **Elevation of Privilege** | Usuário comum tenta acessar painel admin. | GoRouter redirect para `/acesso-negado`; Firestore Rules com `role == "admin"` via `get()`. |

### 2.3 Análise de Design

**Arquitetura implementada:**

```
lib/
├── models/          → Camada de Domínio (entidades de negócio)
├── services/        → Camada de Infraestrutura (Firebase, Supabase, APIs)
├── providers/       → Camada de Aplicação (gerenciamento de estado)
├── screens/         → Camada de Apresentação (telas)
├── widgets/         → Camada de Apresentação (componentes reutilizáveis)
├── routes/          → Navegação e guards
├── utils/           → Utilitários (tema, erros, badges)
└── data/            → Dados estáticos (categorias, equipe, FAQ)
```

**Padrões utilizados:**
- **Provider** para gerenciamento de estado (AuthProvider com ChangeNotifier)
- **GoRouter** para navegação declarativa com redirect guards
- **ShellRoute** para layout compartilhado (AppBar + Drawer + Footer)
- **NoTransitionPage** para evitar overflow durante transições
- **Singleton** para NotificationService

---

## Fase 3 — Implementação

### 3.1 Codificação Segura

| # | Prática | Implementação no projeto |
|---|---------|--------------------------|
| 1 | **Validação de entrada** | Todos os formulários (`Form` + `TextFormField.validator`): login, registro, nova denúncia, editar perfil, comentários |
| 2 | **Regras de segurança (Firestore)** | Regras granulares por coleção: `reports` (leitura pública, escrita autenticada), `users` (escrita pelo dono ou admin), `auditLogs` (imutável) |
| 3 | **Autenticação via Firebase Auth** | `authStateChanges()` no `AuthProvider`; `signInWithEmailAndPassword`, `signInWithCredential` (Google), `createUserWithEmailAndPassword` |
| 4 | **Mapeamento de erros** | `auth_error_mapper.dart` com 15 códigos de erro traduzidos para português |
| 5 | **Proteção de rotas** | `GoRouter.redirect` com listas de rotas protegidas e admin; verificação de `isLoggedIn` e `isAdmin` |
| 6 | **Upload seguro** | `SupabaseService.uploadImage` valida extensão (jpg/png/webp) e tamanho (max 5MB) antes do upload |
| 7 | **Dependências atualizadas** | 20 dependências Flutter gerenciadas via `pubspec.yaml` com versionamento semântico |

### 3.2 Dependências e Integrações

| Dependência | Versão | Finalidade |
|-------------|--------|-----------|
| `firebase_core` | ^4.5.0 | Inicialização Firebase |
| `firebase_auth` | ^6.2.0 | Autenticação |
| `cloud_firestore` | ^6.1.3 | Banco de dados |
| `firebase_messaging` | ^16.2.0 | Notificações push |
| `google_sign_in` | ^7.2.0 | Login com Google |
| `supabase_flutter` | ^2.12.0 | Storage de imagens |
| `go_router` | ^17.0.0 | Navegação e guards |
| `provider` | ^6.1.5+1 | Gerenciamento de estado |
| `flutter_map` | ^8.3.0 | Mapas OpenStreetMap |
| `flutter_local_notifications` | ^19.5.0 | Notificações foreground |
| `image_picker` | ^1.2.1 | Seleção de imagens |
| `share_plus` | ^12.0.2 | Compartilhamento de CSV |
| `http` | ^1.6.0 | Requisições HTTP (ViaCEP, Nominatim) |
| `intl` | ^0.20.2 | Formatação de datas pt_BR |
| `flutter_svg` | ^2.0.17 | Renderização de SVGs |
| `uuid` | ^4.5.3 | Nomes únicos para uploads |
| `latlong2` | ^0.9.1 | Coordenadas geográficas |
| `path_provider` | ^2.1.5 | Diretório temporário |

---

## Fase 4 — Verificação

### 4.1 Testes de Segurança

| # | Tipo de teste | Status | Detalhes |
|---|--------------|--------|----------|
| 1 | **Testes unitários** | ✅ 14 testes | `Report` model (serialização, labels, cores), `ReportLocation` (fromMap/toMap), `Badge Rules` (5 regras + caso negativo) |
| 2 | **Testes de widget** | ✅ 9 testes | `StatusBadge` (4 status), `CardDenuncia` (título, categoria, status, data, callback) |
| 3 | **Testes de integração** | 📋 Pendente | Fluxo completo: login → criar denúncia → ver detalhes → comentar |
| 4 | **Teste de penetração** | 📋 Pendente | Tentativas de acesso admin sem permissão, manipulação de requests |
| 5 | **Análise estática** | ✅ Parcial | `dart analyze` sem erros; linter configurado via `flutter_lints` |

### 4.2 Revisão de Segurança

1. ✅ Requisitos de segurança (1.3) — autenticação, autorização e validação implementados.
2. ✅ Mitigações STRIDE (2.2) — todas as 6 categorias com mitigações implementadas.
3. ✅ Conformidade LGPD — denúncia anônima, desativação de conta, termos no registro.

---

## Fase 5 — Lançamento

### 5.1 Plano de Resposta a Incidentes

1. **Detecção:** Firebase Crashlytics (a integrar), Firebase Analytics, logs no console.
2. **Contenção:** Firestore Rules podem ser atualizadas em tempo real para bloquear funcionalidades comprometidas.
3. **Erradicação:** Deploy de hotfix via `flutter build` + publicação nas lojas.
4. **Recuperação:** Backups automáticos do Firestore; Supabase com retenção de dados.
5. **Lições aprendidas:** Atualização do modelo de ameaças e do `auditLogs`.

### 5.2 Revisão Final

1. 📋 Revisão final de segurança e privacidade pendente.
2. 📋 Validação de todas as mitigações STRIDE em ambiente de produção.
3. 📋 Checklist de conformidade LGPD com DPO.
4. 📋 Preparação para publicação nas lojas (Google Play / App Store).

---

> **Tasks pendentes para lançamento:** consulte o arquivo [`planejamento-tasks-pendentes.md`](./planejamento-tasks-pendentes.md).
