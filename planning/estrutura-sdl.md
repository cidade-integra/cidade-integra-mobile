# Ciclo de Vida do Desenvolvimento Seguro (SDL)

> **Security Development Lifecycle** — Processo estruturado para integrar segurança em todas as fases do desenvolvimento de software.

---

## Fase 1 — Requisitos

### 1.1 Requisitos Funcionais

Regras de negócio do domínio da aplicação:

| # | Requisito | Descrição |
|---|-----------|-----------|
| 1 | **Autenticação** | Processo de identificação do usuário (login, cadastro, recuperação de senha) |
| 2 | **Autorização** | Validação do perfil e nível de acesso do usuário |
| 3 | **Auditoria** | Histórico de acesso e log de ações do usuário |
| 4 | **CRUD Usuário** | Operações de criação, leitura, atualização e exclusão |
| 5 | **Denúncias** | Criação, listagem, detalhamento e acompanhamento de denúncias |
| 6 | **Comentários** | Interação entre usuários nas denúncias |
| 7 | **Notificações** | Alertas sobre atualizações de status e atividades relevantes |
| 8 | **Painel Administrativo** | Gestão de denúncias, usuários e métricas do sistema |

### 1.2 Requisitos Não-Funcionais

Tudo que oferece suporte ao funcionamento do sistema:

#### 1.2.1 Segurança

- **Proteção contra acessos não autorizados:** Autenticação de dois fatores, criptografia de dados sensíveis e auditoria de logs.
- **Resistência a ataques:** Validação de entradas, proteção contra injeção SQL e XSS (Cross-Site Scripting), atualizações de patches de segurança.
- **Conformidade com regulamentos:** Adesão a LGPD, GDPR e normas setoriais aplicáveis.

#### 1.2.2 Desempenho

- **Tempo de resposta:** Processamento de requisições em menos de 2 segundos sob carga máxima.
- **Eficiência de recursos:** Uso otimizado de memória e processamento para evitar gargalos.
- **Escalabilidade:** Capacidade de aumentar capacidade conforme demanda (escalonamento horizontal).

#### 1.2.3 Confiabilidade

- **Disponibilidade:** Garantia de operação contínua (ex.: 99,9% de uptime).
- **Recuperação de falhas:** Mecanismos de backup e redundância para minimizar downtime.
- **Testes de estresse:** Validação sob condições extremas para identificar pontos de falha.

#### 1.2.4 Manutenibilidade

- **Atualizações automáticas:** Implementação de patches e correções sem interrupção do serviço.
- **Documentação técnica:** Especificações claras para facilitar modificações futuras.
- **Modularidade:** Arquitetura que permite atualizações isoladas de componentes.

#### 1.2.5 Portabilidade

- **Compatibilidade multiplataforma:** Funcionamento em Android e iOS.
- **Adaptação a ambientes:** Execução em diferentes dispositivos móveis com ajustes mínimos via design responsivo.

#### 1.2.6 Usabilidade

- **Interface intuitiva:** Design centrado no usuário para reduzir erros e tempo de aprendizado.
- **Acessibilidade:** Conformidade com padrões WCAG para inclusão de usuários com deficiências.

#### 1.2.7 Conformidade

- **Padrões técnicos:** Uso de frameworks e protocolos estabelecidos (ex.: Firebase Authentication, OAuth).
- **Legislação:** Cumprimento de leis locais e internacionais (LGPD no Brasil, GDPR na Europa).

#### 1.2.8 Interoperabilidade

- **Comunicação com sistemas externos:** Integração via APIs REST para troca de dados.
- **Padronização de formatos:** Uso de JSON como formato padrão de comunicação.

#### 1.2.9 Ética e Privacidade

- **Proteção de dados pessoais:** Anonimização de informações e consentimento explícito para uso.
- **Transparência:** Divulgação clara de políticas de coleta e armazenamento de dados.

#### 1.2.10 Padrões Organizacionais

- **Políticas internas:** Adesão às diretrizes de segurança definidas para o projeto.
- **Infraestrutura:** Especificações de hardware e rede para suportar o sistema.

### 1.3 Requisitos de Segurança

Derivados dos requisitos não-funcionais **1.2.1 (Segurança)** e **1.2.10 (Padrões Organizacionais)**, além de:

| # | Requisito | Descrição |
|---|-----------|-----------|
| 1 | **Tipo da aplicação** | Aplicação multiplataforma (Flutter — Android e iOS) |
| 2 | **Autenticação** | Firebase Authentication com suporte a e-mail/senha; avaliar necessidade de SSO |
| 3 | **Validação de telas** | Todas as telas e recursos devem ter controle de acesso adequado ao perfil do usuário |
| 4 | **Armazenamento seguro** | Dados sensíveis armazenados de forma criptografada no dispositivo e no servidor |

### 1.4 Requisitos de Privacidade

Derivados dos requisitos não-funcionais **1.2.7 (Conformidade)** e **1.2.9 (Ética e Privacidade)**, além de:

| Âmbito | Norma aplicável | Observação |
|--------|----------------|------------|
| Nacional | **LGPD** — Lei Geral de Proteção de Dados | Norma brasileira baseada na GDPR europeia |
| Internacional | **GDPR** — General Data Protection Regulation | Norma da União Europeia, aplicável quando houver usuários europeus |

### 1.5 Identificação de Riscos

Identificar os riscos potenciais associados ao software e definir os requisitos de segurança necessários para mitigá-los. A identificação de riscos é um processo contínuo e deve ser revisitada ao longo de todo o ciclo de desenvolvimento.

---

## Fase 2 — Design

### 2.1 Modelagem de Ameaças

Modelos de ameaças são criados para identificar, categorizar e classificar potenciais ameaças de acordo com o risco. Diagramas de Fluxo de Dados (DFDs) são usados para representar visualmente as interações, tipos de dados, portas e protocolos utilizados.

### 2.2 STRIDE — Modelo de Classificação de Ameaças

O **STRIDE** é um modelo de classificação de ameaças desenvolvido pela Microsoft, amplamente utilizado na etapa de modelagem de ameaças do SDL. Cada letra representa uma categoria de ameaça:

| Categoria | Significado | Descrição | Propriedade violada |
|-----------|-------------|-----------|---------------------|
| **S** — Spoofing | Falsificação de identidade | Um atacante se passa por outro usuário ou sistema para obter acesso indevido. | Autenticação |
| **T** — Tampering | Adulteração de dados | Modificação não autorizada de dados em trânsito ou em repouso. | Integridade |
| **R** — Repudiation | Repúdio | O usuário nega ter realizado uma ação e o sistema não consegue provar o contrário. | Não-repúdio |
| **I** — Information Disclosure | Divulgação de informações | Exposição de dados sensíveis a usuários não autorizados. | Confidencialidade |
| **D** — Denial of Service | Negação de serviço | Tornar o sistema indisponível para usuários legítimos por sobrecarga ou ataque. | Disponibilidade |
| **E** — Elevation of Privilege | Elevação de privilégio | Um usuário com permissões limitadas obtém acesso de nível superior (ex.: admin). | Autorização |

#### 2.2.1 Aplicação do STRIDE ao Cidade Integra

| Ameaça | Cenário no Cidade Integra | Mitigação |
|--------|---------------------------|-----------|
| **Spoofing** | Atacante cria conta falsa para registrar denúncias fraudulentas ou se passa por administrador. | Firebase Authentication com verificação de e-mail; validação de perfil no backend antes de conceder papel de admin. |
| **Tampering** | Adulteração de dados de uma denúncia (localização, descrição, fotos) após o envio. | Regras de segurança no Firestore que impedem edição por usuários não autorizados; logs de alteração. |
| **Repudiation** | Usuário nega ter criado determinada denúncia ou comentário ofensivo. | Registro de auditoria com timestamp, UID do autor e IP; logs imutáveis no Firestore. |
| **Information Disclosure** | Exposição de dados pessoais do denunciante (nome, e-mail, localização) a outros usuários. | Regras de leitura no Firestore restritas por perfil; anonimização de dados pessoais nas listagens públicas. |
| **Denial of Service** | Envio massivo de denúncias ou requisições para sobrecarregar o sistema. | Rate limiting nas Cloud Functions; regras de escrita no Firestore com validação; monitoramento de uso anômalo. |
| **Elevation of Privilege** | Usuário comum manipula requisições para acessar o painel administrativo ou alterar status de denúncias. | Verificação de custom claims do Firebase Auth em todas as rotas protegidas; validação server-side do papel do usuário. |

### 2.3 Análise de Design

As equipes utilizam ferramentas de modelagem de ameaças (como a **Threat Modeling Tool** da Microsoft) para analisar os designs de segurança e propor mitigações para os problemas identificados via STRIDE.

---

## Fase 3 — Implementação

### 3.1 Codificação Segura

Os desenvolvedores implementam os requisitos de segurança e design no código, seguindo práticas de codificação segura:

| # | Prática | Descrição |
|---|---------|-----------|
| 1 | **Validação de entrada** | Sanitização de todos os inputs do usuário antes de persistir no Firestore |
| 2 | **Regras de segurança (Firestore)** | Regras granulares de leitura/escrita por coleção e perfil do usuário |
| 3 | **Autenticação via Firebase Auth** | Tokens JWT gerenciados pelo Firebase para autenticação stateless |
| 4 | **CORS** | Configuração de Cross-Origin Resource Sharing nas Cloud Functions |
| 5 | **Proteção de APIs** | Separação em camadas (Domain, Application, Infrastructure) |
| 6 | **Armazenamento seguro** | Uso de `flutter_secure_storage` para dados sensíveis no dispositivo |
| 7 | **Dependências atualizadas** | Verificação periódica de vulnerabilidades em pacotes do `pubspec.yaml` |

---

## Fase 4 — Verificação

### 4.1 Testes de Segurança

Testes para identificar e mitigar vulnerabilidades antes do lançamento:

| # | Tipo de teste | Descrição |
|---|--------------|-----------|
| 1 | **Testes unitários** | Validação de regras de negócio e lógica de segurança |
| 2 | **Testes de widget** | Verificação de comportamento correto dos componentes de UI |
| 3 | **Testes de integração** | Validação de fluxos completos (autenticação, CRUD, permissões) |
| 4 | **Teste de penetração (PenTest)** | Tentativas controladas de explorar vulnerabilidades do sistema |
| 5 | **Análise estática** | Verificação automatizada de código em busca de padrões inseguros |

### 4.2 Revisão de Segurança

Primeira revisão de segurança e privacidade para garantir que todos os requisitos sejam cumpridos:

1. Revisão baseada nos requisitos de segurança (seção 1.3) e requisitos de privacidade (seção 1.4).
2. Validação das mitigações STRIDE definidas na seção 2.2.1.
3. Verificação de conformidade com LGPD/GDPR.

---

## Fase 5 — Lançamento

### 5.1 Plano de Resposta a Incidentes

Antes do lançamento, é necessário ter um plano de resposta para incidentes de segurança:

1. **Detecção:** Monitoramento contínuo via Firebase Crashlytics e Analytics.
2. **Contenção:** Procedimentos para desabilitar funcionalidades comprometidas.
3. **Erradicação:** Correção da vulnerabilidade e deploy de hotfix.
4. **Recuperação:** Restauração dos dados e serviços afetados.
5. **Lições aprendidas:** Documentação do incidente e atualização do modelo de ameaças.

### 5.2 Revisão Final

Segunda revisão de segurança e privacidade antes do lançamento:

1. Revisão final com base nos requisitos de segurança (seção 1.3) e privacidade (seção 1.4).
2. Validação de que todas as ameaças STRIDE possuem mitigações implementadas e testadas.
3. Checklist de conformidade regulatória (LGPD).
4. Aprovação formal para publicação nas lojas (Google Play / App Store).
