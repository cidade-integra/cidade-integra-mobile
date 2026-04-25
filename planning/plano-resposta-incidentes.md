# Plano de Resposta a Incidentes de Segurança — Cidade Integra

> Documento que define os procedimentos para detecção, contenção, erradicação e recuperação de incidentes de segurança.

---

## 1. Classificação de Incidentes

| Nível | Descrição | Exemplos | Tempo de Resposta |
|-------|-----------|----------|-------------------|
| **Crítico** | Comprometimento de dados pessoais ou acesso administrativo indevido | Vazamento de dados de usuários, elevação de privilégio, acesso ao Firestore sem autenticação | < 1 hora |
| **Alto** | Funcionalidade de segurança comprometida | Bypass de autenticação, falha nas Firestore Rules, upload de arquivo malicioso executado | < 4 horas |
| **Médio** | Abuso do sistema sem comprometimento de dados | Spam de denúncias em massa, DDoS no Firestore, uso indevido de API keys | < 24 horas |
| **Baixo** | Vulnerabilidade identificada mas não explorada | Dependência com CVE conhecida, warning de segurança no `dart analyze` | < 72 horas |

---

## 2. Fase 1 — Detecção

| Canal | Ferramenta | O que detecta |
|-------|-----------|---------------|
| Crashes em produção | Firebase Crashlytics | Erros fatais, exceções não tratadas |
| Uso anômalo | Firebase Analytics | Picos de requisições, padrões incomuns |
| Acesso não autorizado | Firestore Audit Logs (`auditLogs`) | Alterações de status/role por admin |
| Dependências | `flutter pub outdated` + `dart analyze` | Pacotes com vulnerabilidades conhecidas |
| Relato de usuário | Email de suporte (suporte@cidadeintegra.com) | Bugs, comportamento suspeito |

---

## 3. Fase 2 — Contenção

### Ações imediatas por nível:

**Crítico:**
1. Atualizar Firestore Rules no Firebase Console para bloquear a operação comprometida.
2. Revogar tokens de acesso (forçar re-autenticação) via Firebase Auth → "Revogar tokens de atualização".
3. Desabilitar Google Sign-In temporariamente se comprometido.
4. Notificar equipe via canal de emergência.

**Alto:**
1. Atualizar Firestore Rules para restringir a funcionalidade afetada.
2. Rotacionar chaves do Supabase Storage se necessário.
3. Bloquear usuários suspeitos via `users/{uid}.status = 'suspended'`.

**Médio:**
1. Ativar rate limiting mais restritivo via Firestore Rules.
2. Bloquear IPs/usuários abusivos via Firebase App Check enforcement.

**Baixo:**
1. Registrar a vulnerabilidade no backlog.
2. Atualizar dependências afetadas via `flutter pub upgrade`.

---

## 4. Fase 3 — Erradicação

1. Identificar a causa raiz do incidente.
2. Corrigir a vulnerabilidade no código-fonte.
3. Atualizar Firestore Rules se a causa envolver regras permissivas.
4. Atualizar dependências se a causa envolver CVE de pacotes.
5. Criar hotfix em branch `hotfix/*` e publicar via `flutter build` + deploy nas lojas.
6. Rotacionar credenciais comprometidas:
   - Firebase: rotacionar API keys no Console → Configurações → Geral.
   - Supabase: rotacionar anon key no Dashboard → Settings → API.
   - Google Sign-In: rotacionar Web Client ID.

---

## 5. Fase 4 — Recuperação

1. Restaurar dados do Firestore via backups automáticos (Firebase Console → Firestore → Importar/Exportar).
2. Verificar integridade dos dados: comparar contagens de `reports`, `users`, `comments`.
3. Reativar funcionalidades bloqueadas na fase de contenção.
4. Monitorar métricas por 48 horas após a correção.
5. Comunicar usuários afetados se houve exposição de dados pessoais (LGPD Art. 48).

---

## 6. Fase 5 — Lições Aprendidas

1. Documentar o incidente com: data, descrição, impacto, causa raiz, ações tomadas, tempo de resolução.
2. Atualizar o modelo de ameaças STRIDE no SDL (`planejamento-sld.md`).
3. Adicionar testes para a vulnerabilidade corrigida.
4. Revisar e atualizar este plano de resposta se necessário.
5. Conduzir retrospectiva com a equipe.

---

## 7. Contatos de Emergência

| Papel | Responsável | Canal |
|-------|-------------|-------|
| Tech Lead | Rafael Romano | GitHub / Slack |
| Firebase Console | Equipe de desenvolvimento | console.firebase.google.com |
| Supabase Dashboard | Equipe de desenvolvimento | supabase.com/dashboard |

---

## 8. Checklist Rápido (para impressão)

- [ ] Incidente classificado (Crítico/Alto/Médio/Baixo)
- [ ] Contenção aplicada (Rules/tokens/bloqueio)
- [ ] Causa raiz identificada
- [ ] Fix implementado e testado
- [ ] Deploy realizado
- [ ] Credenciais rotacionadas (se necessário)
- [ ] Dados restaurados (se necessário)
- [ ] Usuários notificados (se dados expostos)
- [ ] Incidente documentado
- [ ] SDL atualizado
