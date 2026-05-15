# Spike: Autenticação de Dois Fatores (2FA)

## Contexto
Avaliação de viabilidade de 2FA via Firebase Authentication Multi-Factor para o Cidade Integra.

## Análise

### Firebase Auth MFA — SMS
- **Suporte Flutter:** `firebase_auth` suporta `multiFactor` enrollment e sign-in.
- **Custo:** Firebase cobra por SMS enviado (pricing varia por país). Para BR: ~$0.06/SMS.
- **Complexidade:** Requer configuração de Phone Auth no Firebase Console, verificação de número, enrollment flow.
- **UX:** Adiciona fricção no login. Usuários do Cidade Integra são majoritariamente cidadãos reportando problemas — 2FA pode reduzir engajamento.

### Alternativas avaliadas
| Opção | Prós | Contras |
|-------|------|---------|
| SMS MFA (Firebase) | Nativo, seguro | Custo por SMS, fricção |
| TOTP (app authenticator) | Gratuito, seguro | Firebase não suporta nativamente no Flutter |
| Email link (passwordless) | Simples, já temos email verification | Não é verdadeiro 2FA |
| Biometria local | Zero custo, boa UX | Protege apenas o device, não a conta |

## Recomendação
**Não implementar 2FA neste momento.** Motivos:
1. O público-alvo (cidadãos) não lida com dados financeiros — o risco não justifica a fricção.
2. A verificação de e-mail (já implementada) + Firestore Rules cobre a mitigação de Spoofing do STRIDE.
3. O custo de SMS não é sustentável para um projeto acadêmico.

**Ação futura:** Reavaliar se o app for adotado por prefeituras como ferramenta oficial, onde o nível de confiança precisa ser maior.
