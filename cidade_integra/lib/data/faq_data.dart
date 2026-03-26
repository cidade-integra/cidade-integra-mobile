class FaqItem {
  final String question;
  final String answer;
  const FaqItem({required this.question, required this.answer});
}

class FaqCategory {
  final String id;
  final String label;
  final List<FaqItem> items;
  const FaqCategory({required this.id, required this.label, required this.items});
}

const faqData = [
  FaqCategory(
    id: 'platform',
    label: 'Sobre a Plataforma',
    items: [
      FaqItem(
        question: 'O que é o Cidade Integra?',
        answer:
            'O Cidade Integra é uma plataforma que permite aos cidadãos reportar problemas '
            'ambientais e urbanos em sua cidade. Nossa missão é conectar a comunidade aos órgãos '
            'responsáveis para solucionar questões como poluição, descarte irregular de lixo, '
            'problemas de infraestrutura urbana e outros desafios ambientais.',
      ),
      FaqItem(
        question: 'Como a plataforma funciona?',
        answer:
            'O funcionamento é simples: você registra o problema encontrado através do aplicativo, '
            'adicionando fotos, descrição e localização precisa. Nossa equipe analisa e encaminha a '
            'denúncia para o órgão responsável. Você pode acompanhar todo o processo de solução e '
            'será notificado quando o problema for resolvido.',
      ),
      FaqItem(
        question: 'É necessário pagar para usar o Cidade Integra?',
        answer:
            'Não! O Cidade Integra é uma plataforma totalmente gratuita para todos os cidadãos. '
            'Nosso objetivo é facilitar a comunicação entre a população e os órgãos públicos '
            'responsáveis por solucionar os problemas reportados.',
      ),
      FaqItem(
        question: 'Como o Cidade Integra lida com as minhas informações?',
        answer:
            'No Cidade Integra, levamos a sua privacidade a sério. As informações que você '
            'compartilha como nome, e-mail, localização e fotos dos problemas reportados são '
            'utilizadas exclusivamente para encaminhar suas denúncias aos órgãos competentes, '
            'manter você informado sobre o andamento e melhorar continuamente a plataforma.',
      ),
    ],
  ),
  FaqCategory(
    id: 'reports',
    label: 'Denúncias',
    items: [
      FaqItem(
        question: 'Como faço uma denúncia?',
        answer:
            'Para fazer uma denúncia, acesse "Nova Denúncia" no menu. Preencha o formulário com os '
            'detalhes do problema, adicione fotos que mostrem claramente a situação e marque a '
            'localização exata. Quanto mais informações você fornecer, mais rapidamente o problema '
            'poderá ser resolvido.',
      ),
      FaqItem(
        question: 'Posso fazer denúncias anônimas?',
        answer:
            'Sim, você pode optar por fazer denúncias anônimas. Durante o preenchimento do formulário '
            'de denúncia, há uma opção para manter sua identidade privada. Mesmo em denúncias anônimas, '
            'você poderá acompanhar o progresso de solução através de um código único fornecido ao '
            'final do envio.',
      ),
      FaqItem(
        question: 'Como acompanho o status da minha denúncia?',
        answer:
            'Você pode acompanhar suas denúncias através da seção "Minhas Denúncias" no seu perfil. '
            'Lá você encontrará todas as suas denúncias e seus respectivos status atuais. Também '
            'enviamos notificações quando houver atualizações importantes sobre o andamento da solução.',
      ),
    ],
  ),
  FaqCategory(
    id: 'account',
    label: 'Conta e Perfil',
    items: [
      FaqItem(
        question: 'Como criar uma conta no Cidade Integra?',
        answer:
            'Para criar uma conta, acesse "Entrar" no menu e selecione a opção "Cadastrar". '
            'Você precisará fornecer seu nome, email e criar uma senha. Também é possível se '
            'cadastrar utilizando sua conta do Google para maior praticidade.',
      ),
      FaqItem(
        question: 'Como editar meus dados pessoais?',
        answer:
            'Para editar seus dados pessoais, acesse a página de "Perfil" e clique no botão '
            '"Editar Perfil". Lá você poderá atualizar seu nome, email, telefone e senha. '
            'Após fazer as alterações desejadas, clique em "Salvar" para confirmar as mudanças.',
      ),
      FaqItem(
        question: 'Esqueci minha senha. Como recuperá-la?',
        answer:
            'Se você esqueceu sua senha, acesse "Entrar" e clique na opção "Esqueceu a senha?". '
            'Você será redirecionado para a página de recuperação, onde deverá informar o email '
            'cadastrado. Enviaremos um link para você criar uma nova senha de acesso.',
      ),
    ],
  ),
];
