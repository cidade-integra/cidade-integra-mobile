# Plano de Resposta a Incidentes de Segurança — Cidade Integra

> Procedimentos para detecção, contenção, erradicação e recuperação de incidentes de segurança.
>
> **Documento principal:** [SDL — Ciclo de Vida do Desenvolvimento Seguro](./sdl.md)

---

## 1. Classificação de Incidentes

| Nível | Descrição | Exemplos | Tempo de Resposta |
|-------|-----------|----------|-------------------|
| **Crítico** | Comprometimento de dados pessoais ou acesso admin indevido | Vazamento de dados, elevação de privilégio, acesso ao Firestore sem autenticação | < 1 hora |
| **Alto** | Funcionalidade de segurança comprometida | Bypass de autenticação, falha nas Firestore Rules, upload malicioso executado | < 4 horas |
| **Médio** | Abuso do sistema sem comprometimento de dados | Spam em massa, DDoS no Firestore, uso indevido de API keys | < 24 horas |
| **Baixo** | Vulnerabilidade identificada mas não explorada | Dependência com CVE, warning no `dart analyze` | < 72 horas |

---

## 2. Detecção

| Canal | Ferramenta | Status |
|-------|-----------|--------|
| Crashes em produção | Firebase Crashlytics (`FlutterError.onError` + `PlatformDispatcher`) | ✅ Integrado |
| Métricas de uso | Firebase Analytics (eventos: login, register, create_report, etc.) | ✅ Integrado |
| Proteção de backend | Firebase App Check (Play Integrity / App Attest) | ✅ Integrado |
| Ações administrativas | Firestore `audit_logs` + Cloud Function `logAuditEvent` (imutável) | ✅ Integrado |
| Dependências | Dependabot (semanal) + CI `flutter pub outdated` | ✅ Configurado |
| Análise estática | CI `flutter analyze --fatal-infos --fatal-warnings` | ✅ Configurado |
| Relato de usuário | suporte@cidadeintegra.com | ✅ Documentado |

---

## 3. Contenção

### Por nível de severidade:

**Crítico:**
1. Atualizar Firestore Rules no Firebase Console para bloquear a operação comprometida.
2. Revogar tokens via Firebase Auth → "Revogar tokens de atualização".
3. Desabilitar método de login comprometido (Google Sign-In / email).
4. Notificar equipe via canal de emergência.

**Alto:**
1. Restringir Firestore Rules para a funcionalidade afetada.
2. Rotacionar chaves do Supabase Storage se necessário.
3. Bloquear usuários suspeitos via `users/{uid}.status = 'suspended'`.

**Médio:**
1. Aumentar restrição do rate limiting via Firestore Rules.
2. Reforçar App Check enforcement.

**Baixo:**
1. Registrar no backlog (issue com label `security`).
2. Atualizar dependências via `flutter pub upgrade` ou merge do Dependabot PR.

---

## 4. Erradicação

1. Identificar causa raiz via Crashlytics + `audit_logs`.
2. Corrigir no código-fonte (branch `hotfix/*`).
3. Atualizar `firestore.rules` se envolver regras permissivas.
4. Atualizar dependências se envolver CVE.
5. Build release + deploy nas lojas.
6. Rotacionar credenciais comprometidas:
   - Firebase: Console → Configurações → Geral.
   - Supabase: Dashboard → Settings → API.
   - Google Sign-In: rotacionar Web Client ID.

---

## 5. Recuperação

1. Restaurar dados via backups automáticos do Firestore (Console → Importar/Exportar).
2. Verificar integridade: contagens de `reports`, `users`, `comments`.
3. Reativar funcionalidades bloqueadas na contenção.
4. Monitorar Crashlytics e Analytics por 48 horas após a correção.
5. Comunicar usuários afetados se houve exposição de dados pessoais (LGPD Art. 48).

---

## 6. Lições Aprendidas

1. Documentar o incidente: data, descrição, impacto, causa raiz, ações, tempo de resolução.
2. Atualizar modelo STRIDE no SDL (§2.2).
3. Adicionar testes para a vulnerabilidade corrigida.
4. Atualizar este plano se necessário.
5. Retrospectiva com a equipe.

---

## 7. Contatos

| Papel | Responsável | Canal |
|-------|-------------|-------|
| Tech Lead | Rafael Romano | GitHub |
| Firebase Console | Equipe | console.firebase.google.com |
| Supabase Dashboard | Equipe | supabase.com/dashboard |

---

## 8. Checklist Rápido

- [ ] Incidente classificado (Crítico/Alto/Médio/Baixo)
- [ ] Contenção aplicada (Rules/tokens/bloqueio)
- [ ] Causa raiz identificada
- [ ] Fix implementado e testado
- [ ] Deploy realizado
- [ ] Credenciais rotacionadas (se necessário)
- [ ] Dados restaurados (se necessário)
- [ ] Usuários notificados (se dados expostos — LGPD Art. 48)
- [ ] Incidente documentado
- [ ] SDL atualizado
