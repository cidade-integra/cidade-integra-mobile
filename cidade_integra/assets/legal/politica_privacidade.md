# Política de Privacidade — Cidade Integra

**Última atualização:** Maio de 2026

## 1. Dados coletados
- **Identificação:** Nome de exibição, e-mail, foto de perfil (quando via Google Sign-In).
- **Denúncias:** Título, descrição, categoria, endereço, CEP, coordenadas geográficas aproximadas, fotos anexadas.
- **Comentários:** Conteúdo textual e identificação do autor.
- **Técnicos:** Token FCM (notificações push), timestamps de acesso, dispositivo e sistema operacional.

## 2. Finalidade do uso
Os dados são utilizados exclusivamente para:
- Permitir o registro e acompanhamento de denúncias de problemas urbanos.
- Identificar o autor de denúncias e comentários (exceto quando anônimo).
- Enviar notificações sobre atualizações de status.
- Gerar estatísticas agregadas (sem identificação individual) para o painel administrativo.

## 3. Armazenamento
- **Firebase Firestore** (Google Cloud): dados textuais e perfis.
- **Supabase Storage** (AWS): imagens de denúncias.
- Os dados são armazenados em servidores nos EUA, protegidos por criptografia em trânsito (TLS) e em repouso.

## 4. Compartilhamento
Não compartilhamos dados pessoais com terceiros, exceto:
- Quando exigido por lei ou ordem judicial.
- Com serviços de infraestrutura (Firebase, Supabase) para operação do sistema.

## 5. Seus direitos (LGPD Art. 18)
Você tem direito a:
- **Acesso:** Visualizar todos os seus dados no app.
- **Exportação:** Exportar seus dados em formato JSON.
- **Correção:** Editar seu perfil a qualquer momento.
- **Exclusão:** Solicitar a exclusão completa da sua conta e dados associados.
- **Anonimização:** Enviar denúncias de forma anônima.

## 6. Exclusão de dados
Ao solicitar exclusão da conta, removemos:
- Seu documento de perfil no Firestore.
- Seus comentários são anonimizados (autor substituído por "Usuário removido").
- Suas denúncias permanecem para fins de interesse público, mas sem vinculação ao seu perfil.

## 7. Contato
Para dúvidas sobre privacidade: suporte@cidadeintegra.com
