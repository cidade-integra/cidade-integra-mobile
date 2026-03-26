class TeamMember {
  final String name;
  final String role;
  final String assetImage;
  final String description;
  final String github;
  final String linkedin;

  const TeamMember({
    required this.name,
    required this.role,
    required this.assetImage,
    required this.description,
    required this.github,
    required this.linkedin,
  });
}

const students = [
  TeamMember(
    name: 'Jeronimo Barbieri',
    role: 'Designer UI/UX',
    assetImage: 'assets/images/jeronimo-barbieri.jpg',
    description:
        'Fazer parte dessa equipe é uma grande satisfação. Trabalhar em um projeto '
        'onde há uma oportunidade de uma mudança real na sociedade através da tecnologia '
        'e da ação é gratificante.',
    github: 'https://github.com/jeronimobarbieri',
    linkedin: 'https://www.instagram.com/jeronimo.barbieri/',
  ),
  TeamMember(
    name: 'Rafael Romano Silva',
    role: 'Gestor de Projeto',
    assetImage: 'assets/images/rafael-romano.jpg',
    description:
        'Tem sido uma grande experiência fazer parte deste projeto. Trabalhar em equipe '
        'para criar uma solução real nos ajuda a crescer como profissionais e a usar a '
        'tecnologia para contribuir com cidades mais justas e organizadas!',
    github: 'https://github.com/rafaelromwno',
    linkedin: 'https://www.linkedin.com/in/rafael-romano-silva',
  ),
  TeamMember(
    name: 'Miguel Morandini',
    role: 'Desenvolvedor FullStack',
    assetImage: 'assets/images/miguel-morandini.jpg',
    description:
        'Ver as ideias ganhando forma com propósito e foco em impacto real é muito motivador. '
        'Participar deste projeto tem sido uma experiência muito valiosa!',
    github: 'https://github.com/miguelmorandini',
    linkedin: 'https://www.linkedin.com/in/miguel-morandini-19350128a',
  ),
  TeamMember(
    name: 'Pedro Ferreira Leite',
    role: 'Designer UI/UX',
    assetImage: 'assets/images/pedro-ferreira-leite.png',
    description:
        'O Cidade Integra tem como missão um objetivo grandioso e desafiador: tornar as cidades '
        'mais seguras e saudáveis. Assumimos esse compromisso com determinação e estamos empenhados '
        'em conduzir a Cidade Integra a patamares cada vez maiores.',
    github: 'https://github.com/PedroFerreiraLeite',
    linkedin: 'https://www.linkedin.com/in/pedro-ferreira-leite-6645b32b6/',
  ),
  TeamMember(
    name: 'Victor Hugo Testi',
    role: 'Desenvolvedor FullStack',
    assetImage: 'assets/images/victor-hugo.jpg',
    description:
        'É extremamente gratificante ver o fruto do nosso esforço funcionando e impactando '
        'positivamente a sociedade. Fazer parte do desenvolvimento desse projeto é algo de que '
        'me orgulho profundamente.',
    github: 'https://github.com/VictorHugoTesti',
    linkedin: 'https://www.linkedin.com/in/victor-hugo-malipense-testi-994297324/',
  ),
];
