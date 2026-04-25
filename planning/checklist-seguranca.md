# Checklist de Revisão de Segurança — Cidade Integra Mobile

> Checklist para revisão pré-lançamento baseado nos requisitos do SDL (seções 1.3, 1.4, 2.2).

---

## 1. Autenticação e Autorização

- [x] Firebase Authentication configurado (email/senha + Google Sign-In)
- [x] `AuthProvider` escuta `authStateChanges()` e expõe `isLoggedIn`, `isAdmin`
- [x] Rotas protegidas via `GoRouter.redirect` (lista `_protectedRoutes`, `_adminRoutes`)
- [x] Tela de Acesso Negado (`/acesso-negado`) para tentativas de acesso admin
- [ ] Verificação de email obrigatória após registro
- [ ] Custom Claims para role admin (server-side, não apenas Firestore)

## 2. Validação e Sanitização de Dados

- [x] `InputSanitizer` centralizado com remoção de HTML, scripts, caracteres de controle
- [x] Regex robusto para email (RFC 5322), CEP (`^\d{5}-?\d{3}$`), nome (letras/acentos)
- [x] `maxLength` em todos os campos de entrada (título: 100, descrição: 2000, bio: 200, nome: 60)
- [x] Lista de palavras bloqueadas (18+ termos) verificada pré-submit
- [x] Validação de URLs de imagem via whitelist de hosts
- [ ] Validação server-side nas Firestore Rules (tipos, tamanhos, valores)

## 3. Proteção contra Abuso

- [x] Rate limiting client-side: 5 denúncias/hora, 10 comentários/hora
- [x] Debounce de 400ms em todas as buscas
- [x] Botões de submit desabilitados durante processamento
- [ ] Rate limiting server-side via Firestore Rules `request.time`
- [ ] Firebase App Check para proteger backends contra bots

## 4. Privacidade e LGPD

- [x] Opção de denúncia anônima (`isAnonymous` flag)
- [x] Desativação de conta pelo próprio usuário
- [x] Consentimento no registro (checkbox de termos)
- [x] Dados do perfil editáveis pelo dono
- [ ] Política de privacidade completa acessível no app
- [ ] Funcionalidade de exportação de dados pessoais (direito de portabilidade)
- [ ] Funcionalidade de exclusão completa de dados (direito ao esquecimento)

## 5. Firestore Security Rules

- [x] `reports`: leitura pública, escrita autenticada, edição por autor/admin
- [x] `comments`: leitura pública, escrita autenticada, edição por autor/admin
- [x] `users`: leitura pública, escrita pelo dono ou admin
- [x] `denunciasSalvas`: leitura/escrita apenas pelo dono
- [x] `auditLogs`: criação autenticada, leitura admin, imutável
- [ ] Validação de campos obrigatórios nas rules (tipos, tamanhos)
- [ ] Campos sensíveis (role, score) protegidos contra alteração por usuário comum

## 6. Armazenamento e Transmissão

- [x] Supabase Storage com validação de tipo (jpg/png/webp) e tamanho (5MB)
- [x] Anon key do Supabase é pública por design (protegida via RLS)
- [x] Firebase config via `firebase_options.dart` (não hardcoded)
- [ ] `flutter_secure_storage` para tokens sensíveis no dispositivo

## 7. Monitoramento

- [ ] Firebase Crashlytics integrado para detecção de crashes
- [ ] Firebase Analytics integrado para métricas de uso
- [x] `auditLogs` para ações administrativas

## 8. Testes de Segurança

- [x] 23 testes unitários/widget passando
- [ ] Testes E2E cobrindo fluxos críticos
- [ ] Pentest manual ou automatizado (MobSF)
- [x] `dart analyze` sem erros
- [ ] Auditoria de dependências em CI

## 9. Documentação

- [x] SDL completo (`planejamento-sld.md`)
- [x] Plano de resposta a incidentes (`plano-resposta-incidentes.md`)
- [x] README com instruções de setup e aviso sobre tokens
- [x] Superfícies de ataque mapeadas (seção 1.6 do SDL)
- [x] STRIDE aplicado com mitigações (seção 2.2 do SDL)

---

**Legenda:** ✅ = implementado e verificado | ⬜ = pendente
