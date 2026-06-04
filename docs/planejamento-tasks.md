# Cidade Integra — Planejamento de Reescrita React → Flutter

> Plano de ação completo para reconstruir o projeto **Cidade Integra** (originalmente em React + Firebase) usando **Flutter**.
> Cada task segue o template padronizado e foi pensada com uma curva de aprendizado progressiva.

---

## Índice de Milestones

| #  | Milestone                                | Tasks | Pontos |
|----|------------------------------------------|-------|--------|
| 1  | [Configuração Inicial e Estrutura](#milestone-1-configuração-inicial-e-estrutura-do-projeto) | 3 | 8 |
| 2  | [Navegação e Layout Base](#milestone-2-navegação-e-layout-base) | 3 | 11 |
| 3  | [Telas Estáticas — UI Pura](#milestone-3-telas-estáticas--ui-pura) | 5 | 18 |
| 4  | [Autenticação com Firebase](#milestone-4-autenticação-com-firebase) | 5 | 26 |
| 5  | [Listagem de Denúncias](#milestone-5-listagem-de-denúncias) | 4 | 21 |
| 6  | [Detalhes da Denúncia](#milestone-6-detalhes-da-denúncia) | 4 | 21 |
| 7  | [Criação de Denúncia](#milestone-7-criação-de-denúncia) | 4 | 26 |
| 8  | [Perfil do Usuário](#milestone-8-perfil-do-usuário) | 5 | 23 |
| 9  | [Painel Administrativo](#milestone-9-painel-administrativo) | 4 | 26 |
| 10 | [Polimento e Funcionalidades Avançadas](#milestone-10-polimento-e-funcionalidades-avançadas) | 3 | 18 |
|    | **Total**                                | **40** | **198** |

---

## Milestone 1: Configuração Inicial e Estrutura do Projeto

> **Objetivo:** Preparar o projeto Flutter com a estrutura de pastas, dependências e identidade visual antes de escrever qualquer tela.

---

### 🟢 [Config | 2 pontos] Organizar Estrutura de Pastas do Projeto

#### 🧩 Descrição
Criar a estrutura de diretórios dentro de `lib/` que será usada durante todo o projeto. A organização facilita a manutenção e separa responsabilidades (telas, widgets, serviços, modelos, etc.).

#### 🎯 Objetivo e Critérios de Aceite
- [ ] A pasta `lib/` contém os seguintes diretórios: `screens/`, `widgets/`, `services/`, `models/`, `utils/`, `routes/`, `providers/`, `data/`.
- [ ] O arquivo `main.dart` está limpo, sem o código do counter app padrão.
- [ ] O app compila e exibe uma tela em branco (Scaffold vazio) sem erros.

#### 🔍 Referência no projeto antigo (React)
Estrutura equivalente no React:
- `src/pages/` → `lib/screens/`
- `src/components/` → `lib/widgets/`
- `src/hooks/` e `src/services/` → `lib/services/`
- `src/data/` → `lib/data/`
- `src/context/` → `lib/providers/`
- `src/routes/` → `lib/routes/`
- `src/schema/` e `src/lib/` → `lib/models/` e `lib/utils/`

#### 📝 O que aprender para realizar essa task? (Foco em Flutter)
- Convenção de pastas em projetos Flutter
- O papel do `main.dart` como ponto de entrada
- `MaterialApp`, `Scaffold`
- https://docs.flutter.dev/get-started/fundamentals

#### 🌱 Sugestão de Branch
`config/estrutura-pastas`

### 🤓 Dica: por onde começar

```dart
// lib/main.dart
import 'package:flutter/material.dart';

void main() {
  runApp(const CidadeIntegraApp());
}

class CidadeIntegraApp extends StatelessWidget {
  const CidadeIntegraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cidade Integra',
      debugShowCheckedModeBanner: false,
      home: const Scaffold(
        body: Center(child: Text('Cidade Integra')),
      ),
    );
  }
}
```

---

### 🟢 [Config | 3 pontos] Adicionar Dependências Essenciais no pubspec.yaml

#### 🧩 Descrição
Instalar e configurar os pacotes que serão usados ao longo do projeto: roteamento, gerenciamento de estado, Firebase, HTTP, ícones etc. Isso evita problemas de compatibilidade no futuro.

#### 🎯 Objetivo e Critérios de Aceite
- [ ] `pubspec.yaml` inclui: `go_router`, `provider`, `firebase_core`, `firebase_auth`, `cloud_firestore`, `google_sign_in`, `supabase_flutter`, `flutter_map` (ou `google_maps_flutter`), `http`, `image_picker`, `intl`, `flutter_svg`.
- [ ] `flutter pub get` executa sem erros.
- [ ] O app compila normalmente após adicionar as dependências.

#### 🔍 Referência no projeto antigo (React)
Equivalências de pacotes:
- `react-router-dom` → `go_router`
- `React Context` → `provider`
- `firebase` (JS SDK) → `firebase_core`, `firebase_auth`, `cloud_firestore`
- `@supabase/supabase-js` → `supabase_flutter`
- `react-leaflet` → `flutter_map`
- `lucide-react` → `flutter_svg` + ícones do Material
- `zod` / `react-hook-form` → validação nativa com `Form` + `TextFormField`
- `axios` → `http`
- Pacotes em `frontend/package.json`

#### 📝 O que aprender para realizar essa task? (Foco em Flutter)
- Como funciona o `pubspec.yaml` (dependências, assets, fontes)
- Diferença entre `dependencies` e `dev_dependencies`
- Comando `flutter pub get` e `flutter pub upgrade`
- https://docs.flutter.dev/packages-and-plugins/using-packages

#### 🌱 Sugestão de Branch
`config/dependencias`

### 🤓 Dica: por onde começar

Adicione os pacotes um por um no terminal:
```bash
flutter pub add go_router provider firebase_core firebase_auth cloud_firestore google_sign_in supabase_flutter http image_picker intl
```

---

### 🟢 [Config | 3 pontos] Definir Tema e Identidade Visual da Aplicação

#### 🧩 Descrição
Criar um `ThemeData` customizado que reflita a identidade visual do Cidade Integra: cores (verde, azul, vermelho, cinza), tipografia e estilos de botões, cards e inputs. Centralizar tudo em um arquivo de tema.

#### 🎯 Objetivo e Critérios de Aceite
- [ ] Arquivo `lib/utils/app_theme.dart` criado com `ThemeData` customizado.
- [ ] As cores da marca estão definidas (`verde`, `verde-escuro`, `azul`, `vermelho`, `cinza`).
- [ ] `MaterialApp` usa o tema customizado.
- [ ] Suporte a tema claro implementado (tema escuro é opcional/futuro).

#### 🔍 Referência no projeto antigo (React)
- Cores definidas em `frontend/tailwind.config.js` (seção `extend.colors`)
- Variáveis CSS em `frontend/src/index.css`
- Cores: `verde: #2ECC71`, `verde-escuro: #27AE60`, `azul: #3498DB`, `vermelho: #E74C3C`, `cinza: #95A5A6`

#### 📝 O que aprender para realizar essa task? (Foco em Flutter)
- `ThemeData`, `ColorScheme`, `TextTheme`
- `Color` e `MaterialColor` no Flutter
- Como aplicar o tema globalmente via `MaterialApp(theme: ...)`
- https://docs.flutter.dev/cookbook/design/themes

#### 🌱 Sugestão de Branch
`config/tema-visual`

### 🤓 Dica: por onde começar

```dart
// lib/utils/app_theme.dart
import 'package:flutter/material.dart';

class AppColors {
  static const verde = Color(0xFF2ECC71);
  static const verdeEscuro = Color(0xFF27AE60);
  static const azul = Color(0xFF3498DB);
  static const vermelho = Color(0xFFE74C3C);
  static const cinza = Color(0xFF95A5A6);
  static const branco = Color(0xFFFFFFFF);
  static const fundo = Color(0xFFF8F9FA);
}

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.verde,
        primary: AppColors.verde,
        secondary: AppColors.azul,
        error: AppColors.vermelho,
      ),
      scaffoldBackgroundColor: AppColors.fundo,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.branco,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
    );
  }
}
```

---

## Milestone 2: Navegação e Layout Base

> **Objetivo:** Configurar o sistema de rotas e criar os componentes de layout (AppBar, Drawer, Footer) que serão reutilizados em todas as telas.

---

### 🟣 [UI | 3 pontos] Configurar Roteamento com GoRouter

#### 🧩 Descrição
Definir todas as rotas da aplicação usando o pacote `go_router`. Incluir rotas públicas, protegidas (requer login) e administrativas (requer role admin). Criar placeholders (telas vazias) para cada rota.

#### 🎯 Objetivo e Critérios de Aceite
- [ ] Arquivo `lib/routes/app_router.dart` criado com todas as rotas.
- [ ] Rotas públicas: `/`, `/denuncias`, `/denuncias/:id`, `/login`, `/recuperar-senha`, `/sobre`, `/duvidas`, `/acesso-negado`.
- [ ] Rotas protegidas: `/nova-denuncia`, `/perfil`.
- [ ] Rotas admin: `/admin`, `/admin/denuncias`, `/admin/usuarios`.
- [ ] Rota fallback `404` para paths não encontrados.
- [ ] Navegar entre telas placeholder funciona sem erros.

#### 🔍 Referência no projeto antigo (React)
- `frontend/src/routes/AppRoutes.jsx` — definição de todas as rotas
- `frontend/src/routes/ProtectedRoute.jsx` — guard de autenticação
- `frontend/src/routes/AdminRoute.jsx` — guard de admin

#### 📝 O que aprender para realizar essa task? (Foco em Flutter)
- `GoRouter`, `GoRoute`, `ShellRoute`
- Navegação declarativa vs imperativa
- `context.go()`, `context.push()`, `context.pop()`
- Redirect e guards de rota
- https://pub.dev/packages/go_router
- https://docs.flutter.dev/ui/navigation

#### 🌱 Sugestão de Branch
`feature/roteamento`

### 🤓 Dica: por onde começar

```dart
// lib/routes/app_router.dart
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  errorBuilder: (context, state) => const NotFoundScreen(),
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/denuncias',
      builder: (context, state) => const DenunciasScreen(),
    ),
    GoRoute(
      path: '/denuncias/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return DenunciaDetalhesScreen(reportId: id);
      },
    ),
    // ... demais rotas
  ],
);
```

---

### 🟣 [UI | 5 pontos] Criar AppBar Reutilizável com Drawer

#### 🧩 Descrição
Criar uma AppBar customizada com o logo do Cidade Integra e um Drawer (menu lateral) para navegação mobile. O Drawer deve listar todos os links do menu, incluindo itens condicionais para usuários logados e admins.

#### 🎯 Objetivo e Critérios de Aceite
- [ ] Widget `lib/widgets/layout/app_navbar.dart` criado.
- [ ] Widget `lib/widgets/layout/app_drawer.dart` criado.
- [ ] A AppBar exibe o logo/nome do app e um ícone de menu (hamburger).
- [ ] O Drawer lista os links: Início, Denúncias, Nova Denúncia, Sobre, Dúvidas, Perfil, Admin, Login/Logout.
- [ ] Ao clicar em um item do Drawer, o app navega para a rota correspondente.
- [ ] Itens condicionais (Nova Denúncia, Perfil, Admin) exibidos apenas quando fizer sentido (placeholder por agora).

#### 🔍 Referência no projeto antigo (React)
- `frontend/src/components/layout/Navbar.jsx`
- `frontend/src/components/layout/DesktopMenu.jsx`
- `frontend/src/components/layout/MobileMenu.jsx`

#### 📝 O que aprender para realizar essa task? (Foco em Flutter)
- `AppBar`, `Drawer`, `DrawerHeader`
- `ListTile` para itens de menu
- `Navigator` e `GoRouter` para navegação a partir do Drawer
- `Scaffold(appBar: ..., drawer: ...)`
- https://docs.flutter.dev/cookbook/design/drawer

#### 🌱 Sugestão de Branch
`feature/navbar-drawer`

### 🤓 Dica: por onde começar

```dart
// lib/widgets/layout/app_drawer.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF2ECC71)),
            child: Text(
              'Cidade Integra',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Início'),
            onTap: () {
              Navigator.pop(context);
              context.go('/');
            },
          ),
          ListTile(
            leading: const Icon(Icons.list_alt),
            title: const Text('Denúncias'),
            onTap: () {
              Navigator.pop(context);
              context.go('/denuncias');
            },
          ),
          // ... demais itens
        ],
      ),
    );
  }
}
```

---

### 🟣 [UI | 3 pontos] Criar Footer e Layout Base (ShellRoute)

#### 🧩 Descrição
Criar um widget de Footer e um layout base (shell) que envolve todas as telas com AppBar + Body + Footer. Usar `ShellRoute` do GoRouter para aplicar esse layout automaticamente.

#### 🎯 Objetivo e Critérios de Aceite
- [ ] Widget `lib/widgets/layout/app_footer.dart` criado com informações do projeto.
- [ ] Widget `lib/widgets/layout/base_layout.dart` criado com `Scaffold(appBar, drawer, body, bottomNavigationBar ou footer)`.
- [ ] Todas as rotas são envolvidas pelo layout base via `ShellRoute`.
- [ ] O footer exibe: nome do projeto, ano e links de contato.

#### 🔍 Referência no projeto antigo (React)
- `frontend/src/components/layout/Footer.jsx`
- Cada página no React importa `<Navbar />` e `<Footer />` individualmente; no Flutter, o `ShellRoute` centraliza isso.

#### 📝 O que aprender para realizar essa task? (Foco em Flutter)
- `ShellRoute` no GoRouter
- Composição de layout com `Scaffold`
- `Column`, `Expanded`, `SingleChildScrollView` para layout scrollável com footer fixo
- https://pub.dev/documentation/go_router/latest/topics/Shell%20routes-topic.html

#### 🌱 Sugestão de Branch
`feature/layout-base`

### 🤓 Dica: por onde começar

```dart
// lib/widgets/layout/base_layout.dart
import 'package:flutter/material.dart';
import 'app_navbar.dart';
import 'app_drawer.dart';
import 'app_footer.dart';

class BaseLayout extends StatelessWidget {
  final Widget child;
  const BaseLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppNavbar(),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          Expanded(child: child),
          const AppFooter(),
        ],
      ),
    );
  }
}
```

---

## Milestone 3: Telas Estáticas — UI Pura

> **Objetivo:** Praticar a construção de interfaces com widgets do Flutter, sem lógica de negócio ou integração com backend. Foco total em aprender a compor layouts.

---

### 🟣 [UI | 5 pontos] Tela Home — Hero, Stats, Categorias e Como Funciona

#### 🧩 Descrição
Construir a tela inicial do app com 4 seções visuais: Hero (banner principal com CTA), Estatísticas (números do projeto), Categorias (cards das 6 categorias de denúncia) e Como Funciona (passo a passo). Por enquanto, usar dados mockados/estáticos.

#### 🎯 Objetivo e Critérios de Aceite
- [ ] Tela `lib/screens/home_screen.dart` criada.
- [ ] Seção Hero com título, subtítulo e botão "Fazer Denúncia".
- [ ] Seção Stats com 3-4 números em cards (ex: "150+ Denúncias", "50+ Resolvidas").
- [ ] Seção Categorias com 6 cards (Vazamentos, Iluminação, Buracos, Lixo, Áreas Verdes, Outros) com ícone e descrição.
- [ ] Seção Como Funciona com 3-4 passos ilustrados.
- [ ] Ao clicar em uma categoria, navega para `/denuncias?categoria=xxx`.
- [ ] Layout responsivo e visualmente agradável.

#### 🔍 Referência no projeto antigo (React)
- `frontend/src/pages/Index.jsx` — composição das seções
- `frontend/src/components/home/HeroSection.jsx`
- `frontend/src/components/home/StatsSection.jsx`
- `frontend/src/components/home/CategoriesSection.jsx` + `frontend/src/data/categories.jsx`
- `frontend/src/components/home/HowItWorksSection.jsx`

#### 📝 O que aprender para realizar essa task? (Foco em Flutter)
- `SingleChildScrollView` para tela scrollável
- `Column`, `Row`, `Wrap` para layout
- `Card`, `Container`, `Padding`, `SizedBox`
- `Icon` (Material Icons) para ícones de categorias
- `InkWell` ou `GestureDetector` para tornar cards clicáveis
- `GridView.count` ou `Wrap` para grid de categorias
- https://docs.flutter.dev/ui/layout
- https://docs.flutter.dev/ui/widgets/layout

#### 🌱 Sugestão de Branch
`feature/tela-home`

### 🤓 Dica: por onde começar

```dart
// lib/data/categories.dart
import 'package:flutter/material.dart';

class CategoryItem {
  final IconData icon;
  final String title;
  final String description;
  final String value;

  const CategoryItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.value,
  });
}

const categories = [
  CategoryItem(icon: Icons.water_drop, title: 'Vazamentos', description: 'Problemas com água e esgoto', value: 'vazamentos'),
  CategoryItem(icon: Icons.lightbulb, title: 'Iluminação', description: 'Postes com problemas', value: 'iluminacao'),
  CategoryItem(icon: Icons.circle, title: 'Buracos', description: 'Buracos em ruas e calçadas', value: 'buracos'),
  CategoryItem(icon: Icons.delete, title: 'Lixo', description: 'Acúmulo ou descarte irregular', value: 'lixo'),
  CategoryItem(icon: Icons.park, title: 'Áreas Verdes', description: 'Manutenção de praças e parques', value: 'areas-verdes'),
  CategoryItem(icon: Icons.warning, title: 'Outros', description: 'Demais problemas urbanos', value: 'outros'),
];
```

---

### 🟣 [UI | 3 pontos] Tela Sobre — Página da Equipe

#### 🧩 Descrição
Criar a tela "Sobre" que apresenta o projeto e a equipe de desenvolvimento. Cada membro é exibido em um card com foto, nome, papel e links. Dados estáticos.

#### 🎯 Objetivo e Critérios de Aceite
- [ ] Tela `lib/screens/sobre_screen.dart` criada.
- [ ] Seção de apresentação do projeto (texto descritivo).
- [ ] Grid/lista de cards com os membros da equipe.
- [ ] Cada card exibe: avatar (placeholder ou `CircleAvatar`), nome, papel e link (GitHub/LinkedIn).
- [ ] Layout responsivo e esteticamente coerente com o tema.

#### 🔍 Referência no projeto antigo (React)
- `frontend/src/pages/SobrePage.jsx`
- `frontend/src/components/sobre/StudentCard.jsx`
- `frontend/src/data/equipe.jsx` — dados dos membros

#### 📝 O que aprender para realizar essa task? (Foco em Flutter)
- `CircleAvatar` para avatares
- `Card` com layout customizado
- `GridView` ou `Wrap` para grid de cards
- `url_launcher` para abrir links externos (opcional neste momento)
- https://api.flutter.dev/flutter/material/Card-class.html

#### 🌱 Sugestão de Branch
`feature/tela-sobre`

### 🤓 Dica: por onde começar

```dart
// lib/widgets/sobre/student_card.dart
import 'package:flutter/material.dart';

class StudentCard extends StatelessWidget {
  final String name;
  final String role;
  final String avatarUrl;

  const StudentCard({
    super.key,
    required this.name,
    required this.role,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(radius: 40, backgroundImage: NetworkImage(avatarUrl)),
            const SizedBox(height: 12),
            Text(name, style: Theme.of(context).textTheme.titleMedium),
            Text(role, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
```

---

### 🟣 [UI | 5 pontos] Tela FAQ — Perguntas Frequentes com Accordion

#### 🧩 Descrição
Criar a tela de Perguntas Frequentes com navegação por categorias de FAQ e cada pergunta exibida em formato de accordion (expansível). Os dados são estáticos e vêm de uma lista Dart.

#### 🎯 Objetivo e Critérios de Aceite
- [ ] Tela `lib/screens/faq_screen.dart` criada.
- [ ] Dados do FAQ definidos em `lib/data/faq_data.dart` com categorias e perguntas.
- [ ] Navegação lateral ou por tabs para filtrar por categoria.
- [ ] Cada pergunta é expansível (`ExpansionTile` ou `ExpansionPanel`).
- [ ] Seção de contato no final da página.

#### 🔍 Referência no projeto antigo (React)
- `frontend/src/pages/FAQPage.jsx`
- `frontend/src/components/faq/FAQSection.jsx`
- `frontend/src/components/faq/FAQHeader.jsx`
- `frontend/src/components/faq/FAQNavigation.jsx`
- `frontend/src/components/faq/FAQCategory.jsx`
- `frontend/src/components/faq/ContactSection.jsx`
- `frontend/src/data/faqData.jsx` — dados das perguntas

#### 📝 O que aprender para realizar essa task? (Foco em Flutter)
- `ExpansionTile` para accordion
- `ListView.builder` para listas dinâmicas
- `DefaultTabController` + `TabBar` + `TabBarView` para navegação por categoria
- https://api.flutter.dev/flutter/material/ExpansionTile-class.html
- https://docs.flutter.dev/cookbook/design/tabs

#### 🌱 Sugestão de Branch
`feature/tela-faq`

### 🤓 Dica: por onde começar

```dart
// lib/data/faq_data.dart
class FaqItem {
  final String question;
  final String answer;
  const FaqItem({required this.question, required this.answer});
}

class FaqCategory {
  final String name;
  final List<FaqItem> items;
  const FaqCategory({required this.name, required this.items});
}

const faqData = [
  FaqCategory(name: 'Geral', items: [
    FaqItem(question: 'O que é o Cidade Integra?', answer: 'É uma plataforma...'),
    FaqItem(question: 'Como faço uma denúncia?', answer: 'Basta acessar...'),
  ]),
  FaqCategory(name: 'Conta', items: [
    FaqItem(question: 'Preciso criar conta?', answer: 'Sim, para fazer denúncias...'),
  ]),
];
```

---

### 🟣 [UI | 2 pontos] Tela NotFound (404)

#### 🧩 Descrição
Criar uma tela simples de "Página Não Encontrada" que é exibida quando o usuário acessa uma rota inexistente. Incluir uma mensagem amigável e um botão para voltar à Home.

#### 🎯 Objetivo e Critérios de Aceite
- [ ] Tela `lib/screens/not_found_screen.dart` criada.
- [ ] Exibe ícone ou ilustração de erro 404.
- [ ] Exibe mensagem: "Página não encontrada".
- [ ] Botão "Voltar para o Início" que navega para `/`.
- [ ] Configurada como `errorBuilder` do GoRouter.

#### 🔍 Referência no projeto antigo (React)
- `frontend/src/pages/NotFound.jsx`

#### 📝 O que aprender para realizar essa task? (Foco em Flutter)
- `Center`, `Column` para layout centralizado
- `ElevatedButton` para botões
- `Icon` com ícones grandes
- `context.go('/')` para navegação
- https://api.flutter.dev/flutter/material/ElevatedButton-class.html

#### 🌱 Sugestão de Branch
`feature/tela-404`

### 🤓 Dica: por onde começar

```dart
// lib/screens/not_found_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            Text('Página não encontrada', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Voltar para o Início'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### 🟣 [UI | 3 pontos] Tela de Acesso Negado

#### 🧩 Descrição
Criar a tela exibida quando um usuário sem permissão tenta acessar uma rota protegida (ex: admin). Mostrar mensagem clara de que o acesso é restrito e oferecer navegação para voltar.

#### 🎯 Objetivo e Critérios de Aceite
- [ ] Tela `lib/screens/access_denied_screen.dart` criada.
- [ ] Exibe ícone de bloqueio (ex: `Icons.lock`).
- [ ] Exibe mensagem: "Acesso Negado — Você não tem permissão para acessar esta página."
- [ ] Botão "Voltar para o Início".
- [ ] Rota `/acesso-negado` aponta para esta tela.

#### 🔍 Referência no projeto antigo (React)
- `frontend/src/pages/AccessDeniedPage.jsx`
- `frontend/src/routes/AdminRoute.jsx` — redireciona para `/acesso-negado`

#### 📝 O que aprender para realizar essa task? (Foco em Flutter)
- Reutilização de padrão de layout (similar ao NotFound)
- `Icon`, `Text`, `ElevatedButton`
- Conceito de guards de rota (será implementado no Milestone 4)
- https://api.flutter.dev/flutter/material/Icon-class.html

#### 🌱 Sugestão de Branch
`feature/tela-acesso-negado`

### 🤓 Dica: por onde começar

```dart
// lib/screens/access_denied_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AccessDeniedScreen extends StatelessWidget {
  const AccessDeniedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock, size: 80, color: Colors.red),
            const SizedBox(height: 16),
            Text('Acesso Negado', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            const Text('Você não tem permissão para acessar esta página.'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Voltar para o Início'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## Milestone 4: Autenticação com Firebase

> **Objetivo:** Integrar o Firebase Auth ao projeto Flutter, criar telas de login/registro e implementar o gerenciamento de estado do usuário autenticado.

---

### 🟢 [Config | 5 pontos] Configurar Firebase no Projeto Flutter

#### 🧩 Descrição
Conectar o projeto Flutter ao Firebase usando o `flutterfire_cli`. Inicializar `Firebase.initializeApp()` no `main.dart` e garantir que o app se conecta ao projeto `cidadeintegra` do Firebase.

#### 🎯 Objetivo e Critérios de Aceite
- [ ] FlutterFire CLI instalado e configurado.
- [ ] Arquivo `firebase_options.dart` gerado automaticamente.
- [ ] `Firebase.initializeApp()` chamado antes do `runApp()` no `main.dart`.
- [ ] App compila e se conecta ao Firebase sem erros (verificar no console do Firebase).
- [ ] Arquivo `lib/services/firebase_service.dart` criado com exports centralizados.

#### 🔍 Referência no projeto antigo (React)
- `frontend/src/firebase/config.jsx` — inicialização do Firebase com `initializeApp(firebaseConfig)`
- Projeto Firebase: `cidadeintegra` (projectId)

#### 📝 O que aprender para realizar essa task? (Foco em Flutter)
- `flutterfire configure` — ferramenta CLI do Firebase para Flutter
- `Firebase.initializeApp()` e `DefaultFirebaseOptions`
- `WidgetsFlutterBinding.ensureInitialized()` — necessário antes do Firebase
- https://firebase.google.com/docs/flutter/setup
- https://firebase.flutter.dev/docs/overview

#### 🌱 Sugestão de Branch
`config/firebase-setup`

### 🤓 Dica: por onde começar

```bash
# No terminal, instalar o FlutterFire CLI
dart pub global activate flutterfire_cli

# Configurar o Firebase (selecionar o projeto cidadeintegra)
flutterfire configure
```

```dart
// lib/main.dart (atualizado)
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const CidadeIntegraApp());
}
```

---

### 🟣 [UI | 5 pontos] Tela de Login (Email/Senha + Google)

#### 🧩 Descrição
Criar a tela de login com dois métodos: email/senha e Google. Incluir validação dos campos, feedback de erro e navegação para registro e recuperação de senha.

#### 🎯 Objetivo e Critérios de Aceite
- [ ] Tela `lib/screens/login_screen.dart` criada.
- [ ] Formulário com campos de email e senha com validação.
- [ ] Botão "Entrar" que chama `signInWithEmailAndPassword`.
- [ ] Botão "Entrar com Google" que chama `signInWithPopup` (ou `signInWithCredential` no mobile).
- [ ] Link "Esqueci minha senha" que navega para `/recuperar-senha`.
- [ ] Link "Criar conta" que navega para a tela de registro.
- [ ] Exibe mensagens de erro traduzidas para o português.
- [ ] Ao fazer login com sucesso, navega para `/`.

#### 🔍 Referência no projeto antigo (React)
- `frontend/src/pages/LoginPage.jsx`
- `frontend/src/components/authentication/LoginForm.jsx`
- `frontend/src/components/authentication/GoogleLoginButton.jsx`
- `frontend/src/hooks/UseAuthentication.jsx` — funções `loginWithEmail`, `loginWithGoogle`, `mapAuthError`

#### 📝 O que aprender para realizar essa task? (Foco em Flutter)
- `Form`, `TextFormField`, `GlobalKey<FormState>` para formulários
- `firebase_auth`: `signInWithEmailAndPassword`, `GoogleSignIn`
- `google_sign_in` package para login Google no mobile
- `ScaffoldMessenger.showSnackBar` para feedback de erro
- https://firebase.flutter.dev/docs/auth/start
- https://docs.flutter.dev/cookbook/forms/validation

#### 🌱 Sugestão de Branch
`feature/tela-login`

### 🤓 Dica: por onde começar

```dart
// lib/screens/login_screen.dart (esqueleto)
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _loading = false;

  Future<void> _loginComEmail() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _senhaController.text,
      );
      if (mounted) context.go('/');
    } on FirebaseAuthException catch (e) {
      // Tratar erro e exibir SnackBar
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) => v!.isEmpty ? 'Informe o email' : null,
              ),
              TextFormField(
                controller: _senhaController,
                decoration: const InputDecoration(labelText: 'Senha'),
                obscureText: true,
                validator: (v) => v!.length < 6 ? 'Mínimo 6 caracteres' : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loading ? null : _loginComEmail,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('Entrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

### 🟣 [UI | 5 pontos] Tela de Registro (Criar Conta)

#### 🧩 Descrição
Criar a tela de registro com formulário para nome, email, senha e confirmação de senha. Ao registrar, criar o usuário no Firebase Auth E salvar o documento do perfil no Firestore.

#### 🎯 Objetivo e Critérios de Aceite
- [ ] Tela `lib/screens/register_screen.dart` criada.
- [ ] Campos: nome de exibição, email, senha, confirmar senha.
- [ ] Validação: email válido, senha mín. 6 caracteres, senhas coincidem.
- [ ] Ao registrar: cria usuário no Auth, atualiza `displayName`, salva documento em `users/{uid}` no Firestore.
- [ ] Exibe mensagens de erro traduzidas.
- [ ] Ao registrar com sucesso, navega para `/`.
- [ ] Link "Já tenho conta" que navega para `/login`.

#### 🔍 Referência no projeto antigo (React)
- `frontend/src/components/authentication/RegisterForm.jsx`
- `frontend/src/hooks/UseAuthentication.jsx` — função `registerWithEmail` (linhas 63-98) que cria o documento no Firestore com campos: `displayName`, `email`, `photoURL`, `role`, `createdAt`, `score`, `reportCount`, `lastLoginAt`, `region`, `verified`, `bio`, `status`.

#### 📝 O que aprender para realizar essa task? (Foco em Flutter)
- `createUserWithEmailAndPassword` do Firebase Auth
- `FirebaseFirestore.instance.collection('users').doc(uid).set(...)` para salvar perfil
- `updateProfile` para definir displayName
- `TextFormField` com validação customizada
- https://firebase.flutter.dev/docs/auth/usage#registration

#### 🌱 Sugestão de Branch
`feature/tela-registro`

### 🤓 Dica: por onde começar

```dart
Future<void> _registrar() async {
  if (!_formKey.currentState!.validate()) return;

  final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
    email: _emailController.text.trim(),
    password: _senhaController.text,
  );

  await cred.user!.updateDisplayName(_nomeController.text.trim());

  await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set({
    'displayName': _nomeController.text.trim(),
    'email': cred.user!.email,
    'photoURL': '',
    'role': 'user',
    'createdAt': DateTime.now().toIso8601String(),
    'score': 0,
    'reportCount': 0,
    'lastLoginAt': DateTime.now().toIso8601String(),
    'region': '',
    'verified': false,
    'bio': '',
    'status': 'active',
  });
}
```

---

### 🟣 [UI | 3 pontos] Tela de Recuperar Senha

#### 🧩 Descrição
Criar a tela de recuperação de senha onde o usuário informa o email e recebe um link para redefinir a senha via Firebase Auth.

#### 🎯 Objetivo e Critérios de Aceite
- [ ] Tela `lib/screens/recuperar_senha_screen.dart` criada.
- [ ] Campo de email com validação.
- [ ] Botão "Enviar link de recuperação".
- [ ] Ao enviar: chama `sendPasswordResetEmail` do Firebase Auth.
- [ ] Exibe mensagem de sucesso: "Email enviado! Verifique sua caixa de entrada."
- [ ] Exibe mensagem de erro se o email não existir.
- [ ] Link para voltar ao login.

#### 🔍 Referência no projeto antigo (React)
- `frontend/src/pages/RecuperarSenhaPage.jsx`
- `frontend/src/hooks/UseAuthentication.jsx` — função `resetPassword` (linhas 151-162)

#### 📝 O que aprender para realizar essa task? (Foco em Flutter)
- `FirebaseAuth.instance.sendPasswordResetEmail(email: ...)`
- `SnackBar` para feedback visual
- `TextFormField` com validação de email
- https://firebase.flutter.dev/docs/auth/usage#send-a-password-reset-email

#### 🌱 Sugestão de Branch
`feature/recuperar-senha`

### 🤓 Dica: por onde começar

```dart
Future<void> _enviarReset() async {
  try {
    await FirebaseAuth.instance.sendPasswordResetEmail(
      email: _emailController.text.trim(),
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email enviado! Verifique sua caixa de entrada.')),
      );
    }
  } on FirebaseAuthException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro: ${e.message}')),
    );
  }
}
```

---

### 🔵 [Integração | 8 pontos] Gerenciamento de Estado de Autenticação + Rotas Protegidas

#### 🧩 Descrição
Criar um `AuthProvider` usando o pacote `provider` que escuta o estado de autenticação do Firebase (`authStateChanges`) e expõe o `User?` para toda a árvore de widgets. Implementar guards de rota no GoRouter para proteger rotas que exigem login e rotas que exigem role admin.

#### 🎯 Objetivo e Critérios de Aceite
- [ ] `lib/providers/auth_provider.dart` criado com `ChangeNotifier`.
- [ ] Escuta `FirebaseAuth.instance.authStateChanges()`.
- [ ] Expõe: `user`, `isLoggedIn`, `isAdmin`, `isLoading`.
- [ ] Carrega dados do perfil do Firestore (`users/{uid}`) para verificar `role`.
- [ ] `ChangeNotifierProvider<AuthProvider>` envolvendo o `MaterialApp`.
- [ ] GoRouter usa `redirect` para proteger rotas: redireciona para `/login` se não logado, e para `/acesso-negado` se não admin.
- [ ] Tela de loading exibida enquanto verifica o estado de autenticação.

#### 🔍 Referência no projeto antigo (React)
- `frontend/src/context/AuthContext.jsx` — `AuthProvider` com `onAuthStateChanged`
- `frontend/src/routes/ProtectedRoute.jsx` — redireciona para `/login`
- `frontend/src/routes/AdminRoute.jsx` — verifica `role === 'admin'` e redireciona
- `frontend/src/hooks/useFetchUser.jsx` — busca dados do Firestore

#### 📝 O que aprender para realizar essa task? (Foco em Flutter)
- `ChangeNotifier` e `ChangeNotifierProvider` do pacote `provider`
- `context.watch<AuthProvider>()` e `context.read<AuthProvider>()`
- `StreamSubscription` e `authStateChanges()`
- `GoRouter.redirect` para guards de rota
- https://pub.dev/packages/provider
- https://docs.flutter.dev/data-and-backend/state-mgmt/simple

#### 🌱 Sugestão de Branch
`feature/auth-provider`

### 🤓 Dica: por onde começar

```dart
// lib/providers/auth_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  String _role = 'user';
  bool _isLoading = true;
  late final StreamSubscription _authSub;

  AuthProvider() {
    _authSub = FirebaseAuth.instance.authStateChanges().listen(_onAuthChanged);
  }

  User? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isAdmin => _role == 'admin';
  bool get isLoading => _isLoading;

  Future<void> _onAuthChanged(User? user) async {
    _user = user;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      _role = doc.data()?['role'] ?? 'user';
    } else {
      _role = 'user';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  void dispose() {
    _authSub.cancel();
    super.dispose();
  }
}
```

---

## Milestone 5: Listagem de Denúncias

> **Objetivo:** Conectar ao Firestore para buscar denúncias, criar os modelos de dados e exibir a lista com filtros e paginação.

---

### 🔵 [Integração | 3 pontos] Criar Modelo de Dados Report

#### 🧩 Descrição
Criar a classe Dart `Report` que representa uma denúncia no Firestore. Incluir métodos `fromFirestore` e `toFirestore` para serialização/deserialização, e um enum `ReportStatus` e `ReportCategory`.

#### 🎯 Objetivo e Critérios de Aceite
- [ ] Arquivo `lib/models/report.dart` criado.
- [ ] Classe `Report` com todos os campos: `id`, `title`, `description`, `category`, `isAnonymous`, `userId`, `location` (latitude, longitude, address, postalCode), `imageUrls`, `status`, `createdAt`, `updatedAt`, `resolvedAt`.
- [ ] Enum `ReportStatus` com valores: `pending`, `review`, `resolved`, `rejected`.
- [ ] Enum `ReportCategory` com valores: `buracos`, `iluminacao`, `lixo`, `vazamentos`, `areasVerdes`, `outros`.
- [ ] Método `factory Report.fromFirestore(DocumentSnapshot doc)` funcional.
- [ ] Método `Map<String, dynamic> toFirestore()` funcional.

#### 🔍 Referência no projeto antigo (React)
- Estrutura do documento `reports` no Firestore (campos listados nos hooks)
- `frontend/src/hooks/useReport.jsx` — como os dados são lidos
- `frontend/src/schema/DenunciaFormSchema.jsx` — categorias e validação
- `frontend/src/data/categories.jsx` — lista de categorias

#### 📝 O que aprender para realizar essa task? (Foco em Flutter)
- Classes Dart e construtores nomeados
- `factory` constructors
- Enums no Dart
- Serialização de `DocumentSnapshot` do Cloud Firestore
- `Timestamp` do Firestore para `DateTime` do Dart
- https://dart.dev/language/classes
- https://firebase.flutter.dev/docs/firestore/usage#reading-data

#### 🌱 Sugestão de Branch
`feature/model-report`

### 🤓 Dica: por onde começar

```dart
// lib/models/report.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum ReportStatus { pending, review, resolved, rejected }

enum ReportCategory { buracos, iluminacao, lixo, vazamentos, areasVerdes, outros }

class Report {
  final String id;
  final String title;
  final String description;
  final ReportCategory category;
  final bool isAnonymous;
  final String? userId;
  final Map<String, dynamic> location;
  final List<String>? imageUrls;
  final ReportStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? resolvedAt;

  Report({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.isAnonymous,
    this.userId,
    required this.location,
    this.imageUrls,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.resolvedAt,
  });

  factory Report.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Report(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: ReportCategory.values.firstWhere(
        (c) => c.name == data['category'],
        orElse: () => ReportCategory.outros,
      ),
      isAnonymous: data['isAnonymous'] ?? false,
      userId: data['userId'],
      location: data['location'] ?? {},
      imageUrls: List<String>.from(data['imagemUrls'] ?? []),
      status: ReportStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => ReportStatus.pending,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      resolvedAt: data['resolvedAt'] != null
          ? (data['resolvedAt'] as Timestamp).toDate()
          : null,
    );
  }
}
```

---

### 🔵 [Integração | 5 pontos] Serviço Firestore para Denúncias (CRUD)

#### 🧩 Descrição
Criar um serviço que encapsula todas as operações de leitura e escrita na coleção `reports` do Firestore: listar, buscar por ID, filtrar por categoria/status, criar e atualizar.

#### 🎯 Objetivo e Critérios de Aceite
- [ ] Arquivo `lib/services/report_service.dart` criado.
- [ ] Método `getReports({String? category, String? status})` que retorna `Future<List<Report>>`.
- [ ] Método `getReportById(String id)` que retorna `Future<Report?>`.
- [ ] Método `createReport(Report report)` que salva no Firestore.
- [ ] Método `updateReportStatus(String id, ReportStatus status)` para admin.
- [ ] Todos os métodos convertem Firestore Documents para o modelo `Report`.
- [ ] Tratamento de erros com try/catch.

#### 🔍 Referência no projeto antigo (React)
- `frontend/src/hooks/useReport.jsx` — busca de denúncia por ID
- `frontend/src/hooks/useFilteredPaginatedReports.jsx` — listagem com filtros
- `frontend/src/hooks/useReportStatus.jsx` — atualização de status
- `frontend/src/utils/saveReport.jsx` — salvar denúncia

#### 📝 O que aprender para realizar essa task? (Foco em Flutter)
- `FirebaseFirestore.instance.collection('reports')`
- `.get()`, `.doc(id).get()`, `.add()`, `.doc(id).update()`
- `.where()` para queries filtradas
- `.orderBy()` para ordenação
- `async/await` no Dart
- https://firebase.flutter.dev/docs/firestore/usage

#### 🌱 Sugestão de Branch
`feature/service-reports`

### 🤓 Dica: por onde começar

```dart
// lib/services/report_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/report.dart';

class ReportService {
  final _collection = FirebaseFirestore.instance.collection('reports');

  Future<List<Report>> getReports({String? category, String? status}) async {
    Query query = _collection.orderBy('createdAt', descending: true);

    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }
    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => Report.fromFirestore(doc)).toList();
  }

  Future<Report?> getReportById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;
    return Report.fromFirestore(doc);
  }
}
```

---

### 🟣 [UI | 8 pontos] Tela de Listagem de Denúncias com Filtros e Paginação

#### 🧩 Descrição
Criar a tela que lista todas as denúncias vindas do Firestore. Incluir filtros por categoria e status, busca por texto e paginação. Cada denúncia é exibida como um card com título, categoria, status e data.

#### 🎯 Objetivo e Critérios de Aceite
- [ ] Tela `lib/screens/denuncias_screen.dart` criada.
- [ ] Widget `lib/widgets/denuncias/card_denuncia.dart` criado.
- [ ] Lista exibe denúncias usando `FutureBuilder` ou `StreamBuilder`.
- [ ] Filtro por categoria funcional (dropdown ou chips).
- [ ] Filtro por status funcional.
- [ ] Cada card exibe: título, categoria (com ícone), status (com badge colorido), data formatada, endereço resumido.
- [ ] Ao clicar em um card, navega para `/denuncias/:id`.
- [ ] Estado de loading (indicador de progresso) enquanto carrega.
- [ ] Estado vazio ("Nenhuma denúncia encontrada") quando não há resultados.

#### 🔍 Referência no projeto antigo (React)
- `frontend/src/pages/DenunciasPage.jsx`
- `frontend/src/components/denuncias/DenunciasList.jsx`
- `frontend/src/components/denuncias/CardDenuncia.jsx`
- `frontend/src/hooks/useFilteredPaginatedReports.jsx`

#### 📝 O que aprender para realizar essa task? (Foco em Flutter)
- `FutureBuilder` e `StreamBuilder` para dados assíncronos
- `ListView.builder` para listas performáticas
- `FilterChip` ou `DropdownButton` para filtros
- `Card`, `ListTile` para cards de listagem
- `CircularProgressIndicator` para loading
- `intl` para formatação de datas
- https://docs.flutter.dev/cookbook/networking/fetch-data
- https://api.flutter.dev/flutter/widgets/FutureBuilder-class.html

#### 🌱 Sugestão de Branch
`feature/lista-denuncias`

### 🤓 Dica: por onde começar

```dart
// lib/widgets/denuncias/card_denuncia.dart
import 'package:flutter/material.dart';
import '../../models/report.dart';

class CardDenuncia extends StatelessWidget {
  final Report report;
  final VoidCallback onTap;

  const CardDenuncia({super.key, required this.report, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(report.title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Row(
                children: [
                  Chip(label: Text(report.category.name)),
                  const SizedBox(width: 8),
                  Chip(label: Text(report.status.name)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

### 🟣 [UI | 5 pontos] Widget Reutilizável de Badge de Status

#### 🧩 Descrição
Criar um widget reutilizável que exibe o status de uma denúncia como um badge colorido. Cada status deve ter cor e rótulo distintos. Esse widget será usado na listagem, nos detalhes e no painel admin.

#### 🎯 Objetivo e Critérios de Aceite
- [ ] Widget `lib/widgets/denuncias/status_badge.dart` criado.
- [ ] Mapeamento de status para cor: `pending` → amarelo, `review` → azul, `resolved` → verde, `rejected` → vermelho.
- [ ] Mapeamento de status para rótulo em português: `pending` → "Pendente", `review` → "Em Análise", `resolved` → "Resolvida", `rejected` → "Rejeitada".
- [ ] O widget é um `Container` estilizado ou `Chip` com cor de fundo e texto.
- [ ] Usado e testado visualmente na `CardDenuncia`.

#### 🔍 Referência no projeto antigo (React)
- `frontend/src/components/denuncias/DenunciaStatusBadge.jsx`

#### 📝 O que aprender para realizar essa task? (Foco em Flutter)
- `Container` com `BoxDecoration` para estilização customizada
- `Chip` como alternativa rápida
- Mapas/dicionários em Dart (`Map<ReportStatus, Color>`)
- https://api.flutter.dev/flutter/material/Chip-class.html

#### 🌱 Sugestão de Branch
`feature/status-badge`

### 🤓 Dica: por onde começar

```dart
// lib/widgets/denuncias/status_badge.dart
import 'package:flutter/material.dart';
import '../../models/report.dart';

class StatusBadge extends StatelessWidget {
  final ReportStatus status;
  const StatusBadge({super.key, required this.status});

  static const _config = {
    ReportStatus.pending: ('Pendente', Color(0xFFF39C12), Color(0xFFFFF3CD)),
    ReportStatus.review: ('Em Análise', Color(0xFF3498DB), Color(0xFFD6EAF8)),
    ReportStatus.resolved: ('Resolvida', Color(0xFF2ECC71), Color(0xFFD5F5E3)),
    ReportStatus.rejected: ('Rejeitada', Color(0xFFE74C3C), Color(0xFFFADCD5)),
  };

  @override
  Widget build(BuildContext context) {
    final (label, textColor, bgColor) = _config[status]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }
}
```

---

## Milestone 6: Detalhes da Denúncia

> **Objetivo:** Exibir todos os detalhes de uma denúncia, incluindo galeria de imagens, fluxo visual de status, mapa e sistema de comentários.

---

### 🟣 [UI | 5 pontos] Tela de Detalhes da Denúncia

#### 🧩 Descrição
Criar a tela que exibe todas as informações de uma denúncia específica: título, descrição, categoria, status, imagens, localização e data. Buscar os dados pelo ID recebido via parâmetro da rota.

#### 🎯 Objetivo e Critérios de Aceite
- [ ] Tela `lib/screens/denuncia_detalhes_screen.dart` criada.
- [ ] Recebe o `reportId` como parâmetro da rota.
- [ ] Busca dados via `ReportService.getReportById(id)`.
- [ ] Exibe: título, descrição completa, badge de status, chip de categoria, data formatada, endereço.
- [ ] Se houver imagens, exibe galeria (carrossel ou grid).
- [ ] Estado de loading enquanto carrega.
- [ ] Tratamento de caso "denúncia não encontrada".

#### 🔍 Referência no projeto antigo (React)
- `frontend/src/pages/DenunciaDetalhes.jsx`
- `frontend/src/hooks/useReport.jsx` — busca por ID
- `frontend/src/components/denuncias/DenunciaStatusBadge.jsx`

#### 📝 O que aprender para realizar essa task? (Foco em Flutter)
- `FutureBuilder` para carregar dados assíncronos
- `PageView` para carrossel de imagens
- `Image.network` para exibir imagens de URL
- `SingleChildScrollView` para conteúdo scrollável
- https://api.flutter.dev/flutter/widgets/FutureBuilder-class.html
- https://api.flutter.dev/flutter/widgets/PageView-class.html

#### 🌱 Sugestão de Branch
`feature/detalhes-denuncia`

### 🤓 Dica: por onde começar

```dart
// lib/screens/denuncia_detalhes_screen.dart (esqueleto)
class DenunciaDetalhesScreen extends StatelessWidget {
  final String reportId;
  const DenunciaDetalhesScreen({super.key, required this.reportId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Report?>(
      future: ReportService().getReportById(reportId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final report = snapshot.data;
        if (report == null) {
          return const Center(child: Text('Denúncia não encontrada'));
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(report.title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              StatusBadge(status: report.status),
              const SizedBox(height: 16),
              Text(report.description),
              // ... imagens, mapa, comentários
            ],
          ),
        );
      },
    );
  }
}
```

---

### 🟣 [UI | 3 pontos] Widget StatusFlow — Fluxo Visual de Status

#### 🧩 Descrição
Criar um widget que exibe o fluxo de status de uma denúncia como um stepper visual horizontal ou vertical. Os passos são: Pendente → Em Análise → Resolvida (ou Rejeitada). O passo atual é destacado.

#### 🎯 Objetivo e Critérios de Aceite
- [ ] Widget `lib/widgets/denuncias/status_flow.dart` criado.
- [ ] Exibe os 3 passos de status com ícones e rótulos.
- [ ] O passo atual e os anteriores ficam com cor preenchida (verde).
- [ ] Passos futuros ficam desabilitados (cinza).
- [ ] Se o status for `rejected`, o último passo exibe "Rejeitada" com cor vermelha.
- [ ] Usado na tela de detalhes da denúncia.

#### 🔍 Referência no projeto antigo (React)
- `frontend/src/components/denuncias/StatusFlow.jsx`

#### 📝 O que aprender para realizar essa task? (Foco em Flutter)
- `Stepper` widget do Flutter (ou implementação customizada com `Row` + `Container`)
- `CustomPaint` para linhas entre passos (opcional)
- https://api.flutter.dev/flutter/material/Stepper-class.html

#### 🌱 Sugestão de Branch
`feature/status-flow`

### 🤓 Dica: por onde começar

```dart
// lib/widgets/denuncias/status_flow.dart
import 'package:flutter/material.dart';
import '../../models/report.dart';

class StatusFlow extends StatelessWidget {
  final ReportStatus currentStatus;
  const StatusFlow({super.key, required this.currentStatus});

  @override
  Widget build(BuildContext context) {
    final steps = [
      (ReportStatus.pending, 'Pendente', Icons.hourglass_empty),
      (ReportStatus.review, 'Em Análise', Icons.search),
      (ReportStatus.resolved, 'Resolvida', Icons.check_circle),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: steps.map((step) {
        final (status, label, icon) = step;
        final isActive = currentStatus.index >= status.index;
        final isRejected = currentStatus == ReportStatus.rejected;

        return Column(
          children: [
            CircleAvatar(
              backgroundColor: isRejected && status == ReportStatus.resolved
                  ? Colors.red
                  : isActive ? Colors.green : Colors.grey.shade300,
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(height: 4),
            Text(
              isRejected && status == ReportStatus.resolved ? 'Rejeitada' : label,
              style: TextStyle(fontSize: 12, color: isActive ? Colors.green : Colors.grey),
            ),
          ],
        );
      }).toList(),
    );
  }
}
```

---

### 🔵 [Integração | 8 pontos] Sistema de Comentários

#### 🧩 Descrição
Implementar o sistema de comentários na tela de detalhes da denúncia. Listar comentários existentes (subcoleção `reports/{id}/comments`) e permitir que usuários logados adicionem novos comentários.

#### 🎯 Objetivo e Critérios de Aceite
- [ ] Modelo `lib/models/comment.dart` criado com campos: `author`, `authorId`, `message`, `createdAt`, `avatarColor`, `role`.
- [ ] Serviço `lib/services/comment_service.dart` com métodos: `getComments(reportId)`, `addComment(reportId, comment)`.
- [ ] Widget `lib/widgets/denuncias/comment_card.dart` para exibir cada comentário.
- [ ] Lista de comentários exibida na tela de detalhes via `StreamBuilder`.
- [ ] Campo de texto + botão "Enviar" para adicionar comentário (visível apenas se logado).
- [ ] Comentários ordenados por data (mais recente primeiro).
- [ ] Avatar com cor e indicação de role (admin vs user).

#### 🔍 Referência no projeto antigo (React)
- `frontend/src/hooks/useReportComments.jsx` — leitura e adição de comentários
- `frontend/src/components/denuncias/ComentarioCard.jsx` — exibição
- Subcoleção Firestore: `reports/{reportId}/comments`

#### 📝 O que aprender para realizar essa task? (Foco em Flutter)
- Subcoleções no Firestore: `.collection('reports').doc(id).collection('comments')`
- `StreamBuilder` com `snapshots()` para dados em tempo real
- `TextEditingController` para campo de input
- `ListView.builder` para lista de comentários
- https://firebase.flutter.dev/docs/firestore/usage#subcollections

#### 🌱 Sugestão de Branch
`feature/comentarios`

### 🤓 Dica: por onde começar

```dart
// lib/services/comment_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class CommentService {
  Stream<QuerySnapshot> getComments(String reportId) {
    return FirebaseFirestore.instance
        .collection('reports')
        .doc(reportId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> addComment(String reportId, Map<String, dynamic> data) async {
    await FirebaseFirestore.instance
        .collection('reports')
        .doc(reportId)
        .collection('comments')
        .add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
```

---

### 🔵 [Integração | 5 pontos] Mapa Estático com Localização

#### 🧩 Descrição
Exibir um mapa na tela de detalhes da denúncia mostrando a localização do problema. Usar `flutter_map` (baseado em OpenStreetMap) ou `google_maps_flutter` para renderizar o mapa com um marcador no ponto indicado.

#### 🎯 Objetivo e Critérios de Aceite
- [ ] Widget `lib/widgets/denuncias/mapa_denuncia.dart` criado.
- [ ] Exibe mapa centralizado nas coordenadas da denúncia (`location.latitude`, `location.longitude`).
- [ ] Marcador visível no ponto exato.
- [ ] Mapa tem zoom fixo e não é interativo (apenas visual).
- [ ] Fallback: se não houver coordenadas, exibe o endereço em texto.
- [ ] Integrado na tela de detalhes.

#### 🔍 Referência no projeto antigo (React)
- `frontend/src/components/denuncias/MapaEstatico.jsx` — usa `react-leaflet` com tiles OpenStreetMap

#### 📝 O que aprender para realizar essa task? (Foco em Flutter)
- `flutter_map` package e `TileLayer` do OpenStreetMap
- `LatLng` para coordenadas
- `Marker` para marcar pontos no mapa
- https://pub.dev/packages/flutter_map
- https://docs.fleaflet.dev/

#### 🌱 Sugestão de Branch
`feature/mapa-denuncia`

### 🤓 Dica: por onde começar

```dart
// lib/widgets/denuncias/mapa_denuncia.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapaDenuncia extends StatelessWidget {
  final double latitude;
  final double longitude;
  const MapaDenuncia({super.key, required this.latitude, required this.longitude});

  @override
  Widget build(BuildContext context) {
    final point = LatLng(latitude, longitude);
    return SizedBox(
      height: 200,
      child: FlutterMap(
        options: MapOptions(initialCenter: point, initialZoom: 15),
        children: [
          TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
          MarkerLayer(markers: [
            Marker(
              point: point,
              child: const Icon(Icons.location_on, color: Colors.red, size: 40),
            ),
          ]),
        ],
      ),
    );
  }
}
```

---

## Milestone 7: Criação de Denúncia

> **Objetivo:** Implementar o formulário completo de criação de denúncia com validação, upload de imagens e geocodificação de endereço.

---

### 🟣 [UI | 5 pontos] Formulário de Nova Denúncia com Validação

#### 🧩 Descrição
Criar a tela de nova denúncia com formulário completo: título, descrição, categoria (dropdown), CEP (opcional, com autopreenchimento de endereço via ViaCEP), endereço e checkbox de denúncia anônima. Incluir validação em todos os campos obrigatórios.

#### 🎯 Objetivo e Critérios de Aceite
- [ ] Tela `lib/screens/nova_denuncia_screen.dart` criada.
- [ ] Campos: título (mín. 3 chars), descrição (mín. 10 chars), categoria (dropdown com 6 opções), CEP (opcional, formato 00000-000), endereço (mín. 5 chars), checkbox anônima.
- [ ] Validação em todos os campos obrigatórios exibindo mensagem de erro.
- [ ] Ao preencher o CEP e sair do campo (onEditingComplete), buscar endereço via API ViaCEP (`https://viacep.com.br/ws/{cep}/json/`) e preencher o campo endereço.
- [ ] Botão "Enviar" desabilitado enquanto o formulário é inválido.
- [ ] Rota protegida (apenas usuários logados).

#### 🔍 Referência no projeto antigo (React)
- `frontend/src/pages/NovaDenunciaPage.jsx`
- `frontend/src/components/denunciaForm/DenunciaForm.jsx`
- `frontend/src/components/denunciaForm/DenunciaFormFields.jsx` — campos e autopreenchimento via ViaCEP
- `frontend/src/schema/DenunciaFormSchema.jsx` — regras de validação (Zod)

#### 📝 O que aprender para realizar essa task? (Foco em Flutter)
- `Form`, `TextFormField`, `DropdownButtonFormField`
- `GlobalKey<FormState>` e `.validate()`
- `validator:` callback para validação
- `http` package para chamada à API ViaCEP
- `FocusNode` e `onEditingComplete` para trigger de CEP
- https://docs.flutter.dev/cookbook/forms/validation
- https://docs.flutter.dev/cookbook/forms/text-field-changes

#### 🌱 Sugestão de Branch
`feature/formulario-denuncia`

### 🤓 Dica: por onde começar

```dart
// Exemplo de campo com validação + autopreenchimento de CEP
TextFormField(
  controller: _cepController,
  decoration: const InputDecoration(labelText: 'CEP (opcional)', hintText: '00000-000'),
  keyboardType: TextInputType.number,
  onEditingComplete: () async {
    final cep = _cepController.text.replaceAll('-', '');
    if (cep.length == 8) {
      final response = await http.get(Uri.parse('https://viacep.com.br/ws/$cep/json/'));
      final data = jsonDecode(response.body);
      if (data['erro'] != true) {
        _enderecoController.text = '${data['logradouro']}, ${data['bairro']} - ${data['localidade']}/${data['uf']}';
      }
    }
  },
),

DropdownButtonFormField<String>(
  decoration: const InputDecoration(labelText: 'Categoria'),
  items: const [
    DropdownMenuItem(value: 'buracos', child: Text('Buracos')),
    DropdownMenuItem(value: 'iluminacao', child: Text('Iluminação')),
    DropdownMenuItem(value: 'lixo', child: Text('Lixo')),
    DropdownMenuItem(value: 'vazamentos', child: Text('Vazamentos')),
    DropdownMenuItem(value: 'areas-verdes', child: Text('Áreas Verdes')),
    DropdownMenuItem(value: 'outros', child: Text('Outros')),
  ],
  validator: (v) => v == null ? 'Selecione uma categoria' : null,
  onChanged: (v) => _categoriaSelecionada = v,
),
```

---

### 🔵 [Integração | 8 pontos] Upload de Imagens (Supabase Storage)

#### 🧩 Descrição
Implementar o upload de imagens no formulário de denúncia. O usuário pode selecionar até 2 imagens da galeria ou câmera. As imagens são enviadas para o bucket `reports` do Supabase Storage e as URLs são armazenadas junto com a denúncia no Firestore.

#### 🎯 Objetivo e Critérios de Aceite
- [ ] Widget `lib/widgets/denunciaForm/image_upload.dart` criado.
- [ ] Serviço `lib/services/supabase_service.dart` criado com método de upload.
- [ ] Supabase inicializado em `main.dart` com `Supabase.initialize(url, anonKey)`.
- [ ] Usuário pode selecionar até 2 imagens da galeria ou câmera (`image_picker`).
- [ ] Preview das imagens selecionadas antes do envio.
- [ ] Botão de remover imagem individual.
- [ ] Upload para o bucket `reports` do Supabase Storage com nome único (UUID).
- [ ] Retorna lista de URLs públicas das imagens.
- [ ] Indicador de progresso durante o upload.

#### 🔍 Referência no projeto antigo (React)
- `frontend/src/components/denunciaForm/ImageUpload.jsx`
- `frontend/src/hooks/useUploadImageReport.jsx` — upload para Supabase
- `frontend/src/supabase/config.jsx` — configuração do Supabase

#### 📝 O que aprender para realizar essa task? (Foco em Flutter)
- `image_picker` package para selecionar imagens
- `supabase_flutter` para upload de arquivos
- `File` e manipulação de paths no Dart
- `Stack` e `Positioned` para botão de remover sobre a imagem
- https://pub.dev/packages/image_picker
- https://supabase.com/docs/reference/dart/storage-from-upload

#### 🌱 Sugestão de Branch
`feature/upload-imagens`

### 🤓 Dica: por onde começar

```dart
// lib/services/supabase_service.dart
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class SupabaseService {
  final _storage = Supabase.instance.client.storage;

  Future<String> uploadImage(File file) async {
    final ext = file.path.split('.').last;
    final fileName = '${const Uuid().v4()}.$ext';
    final path = 'reports/$fileName';

    await _storage.from('reports').upload(path, file);

    final url = _storage.from('reports').getPublicUrl(path);
    return url;
  }
}
```

---

### 🔵 [Integração | 5 pontos] Geocodificação de Endereço (Nominatim)

#### 🧩 Descrição
Implementar a geocodificação do endereço informado pelo usuário para obter latitude e longitude. Usar a API gratuita do Nominatim (OpenStreetMap) para converter o endereço em coordenadas, que serão salvas no campo `location` da denúncia.

#### 🎯 Objetivo e Critérios de Aceite
- [ ] Serviço `lib/services/geocoding_service.dart` criado.
- [ ] Método `getCoordinates(String address)` que retorna `Future<{double lat, double lng}?>`.
- [ ] Chamada à API: `https://nominatim.openstreetmap.org/search?q={address}&format=json&limit=1`.
- [ ] Header `User-Agent` incluído na requisição (obrigatório pela API).
- [ ] Retorna `null` se não encontrar resultados.
- [ ] Integrado ao formulário: ao submeter, geocodifica o endereço antes de salvar.

#### 🔍 Referência no projeto antigo (React)
- Chamada ao Nominatim encontrada nos hooks/utils do projeto React para converter endereço em coordenadas.

#### 📝 O que aprender para realizar essa task? (Foco em Flutter)
- `http` package para requisições GET
- `jsonDecode` para parsear resposta JSON
- Conceito de geocodificação (endereço → coordenadas)
- Headers customizados em requisições HTTP
- https://pub.dev/packages/http
- https://nominatim.org/release-docs/latest/api/Search/

#### 🌱 Sugestão de Branch
`feature/geocodificacao`

### 🤓 Dica: por onde começar

```dart
// lib/services/geocoding_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class GeocodingService {
  Future<({double lat, double lng})?> getCoordinates(String address) async {
    final uri = Uri.parse(
      'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(address)}&format=json&limit=1',
    );

    final response = await http.get(uri, headers: {
      'User-Agent': 'CidadeIntegraApp/1.0',
    });

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        return (
          lat: double.parse(data[0]['lat']),
          lng: double.parse(data[0]['lon']),
        );
      }
    }
    return null;
  }
}
```

---

### 🔵 [Integração | 8 pontos] Integração Completa — Salvar Denúncia no Firestore

#### 🧩 Descrição
Conectar todas as peças: ao submeter o formulário, validar os campos, fazer upload das imagens (Supabase), geocodificar o endereço (Nominatim) e salvar a denúncia completa no Firestore. Após o sucesso, navegar para a lista de denúncias.

#### 🎯 Objetivo e Critérios de Aceite
- [ ] Ao clicar "Enviar", o formulário valida todos os campos.
- [ ] Se houver imagens, faz upload para o Supabase e obtém URLs.
- [ ] Geocodifica o endereço para obter latitude e longitude.
- [ ] Salva documento na coleção `reports` do Firestore com todos os campos do modelo `Report`.
- [ ] `userId` é preenchido com o UID do usuário logado (ou `null` se anônimo).
- [ ] `status` inicial é `pending`.
- [ ] `createdAt` e `updatedAt` usam `FieldValue.serverTimestamp()`.
- [ ] Exibe indicador de loading durante o processo.
- [ ] Exibe SnackBar de sucesso e navega para `/denuncias`.
- [ ] Exibe SnackBar de erro se algo falhar.
- [ ] Incrementa `reportCount` do usuário no Firestore e adiciona score.

#### 🔍 Referência no projeto antigo (React)
- `frontend/src/components/denunciaForm/DenunciaForm.jsx` — fluxo de submissão
- `frontend/src/utils/saveReport.jsx` — criação do documento no Firestore
- `frontend/src/hooks/useUploadImageReport.jsx` — upload de imagens
- `frontend/src/hooks/UseAuthentication.jsx` — obtenção do userId

#### 📝 O que aprender para realizar essa task? (Foco em Flutter)
- Orquestração de múltiplas operações assíncronas (`await` sequencial)
- `FieldValue.serverTimestamp()` para timestamps do servidor
- `FieldValue.increment(1)` para incrementar counters
- Transações no Firestore (opcional, para atomicidade)
- `try/catch/finally` para tratamento robusto de erros
- https://firebase.flutter.dev/docs/firestore/usage#adding-documents

#### 🌱 Sugestão de Branch
`feature/salvar-denuncia`

### 🤓 Dica: por onde começar

```dart
Future<void> _submitDenuncia() async {
  if (!_formKey.currentState!.validate()) return;
  setState(() => _loading = true);

  try {
    // 1. Upload de imagens
    List<String> imageUrls = [];
    for (final file in _selectedImages) {
      final url = await SupabaseService().uploadImage(file);
      imageUrls.add(url);
    }

    // 2. Geocodificação
    final coords = await GeocodingService().getCoordinates(_enderecoController.text);

    // 3. Salvar no Firestore
    final user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance.collection('reports').add({
      'title': _tituloController.text,
      'description': _descricaoController.text,
      'category': _categoriaSelecionada,
      'isAnonymous': _isAnonima,
      'userId': _isAnonima ? null : user?.uid,
      'location': {
        'address': _enderecoController.text,
        'postalCode': _cepController.text,
        'latitude': coords?.lat,
        'longitude': coords?.lng,
      },
      'imagemUrls': imageUrls,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'resolvedAt': null,
    });

    // 4. Incrementar score do usuário
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'reportCount': FieldValue.increment(1),
        'score': FieldValue.increment(10),
      });
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Denúncia enviada com sucesso!')),
      );
      context.go('/denuncias');
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro ao enviar: $e')),
    );
  } finally {
    if (mounted) setState(() => _loading = false);
  }
}
```

---

## Milestone 8: Perfil do Usuário

> **Objetivo:** Implementar o perfil completo do usuário: visualização, edição, sistema de badges, listagem de denúncias próprias e salvas.

---

### 🔵 [Integração | 3 pontos] Modelo de Dados User e Serviço Firestore

#### 🧩 Descrição
Criar a classe Dart `AppUser` que representa o documento de usuário no Firestore (coleção `users`). Criar também o serviço que encapsula as operações de leitura e atualização do perfil.

#### 🎯 Objetivo e Critérios de Aceite
- [ ] Arquivo `lib/models/app_user.dart` criado.
- [ ] Classe `AppUser` com campos: `uid`, `displayName`, `email`, `photoURL`, `role`, `createdAt`, `score`, `reportCount`, `lastLoginAt`, `region`, `verified`, `bio`, `status`.
- [ ] Método `factory AppUser.fromFirestore(DocumentSnapshot doc)`.
- [ ] Arquivo `lib/services/user_service.dart` criado.
- [ ] Métodos: `getUserById(uid)`, `updateUser(uid, data)`, `deleteAccount(uid)`.

#### 🔍 Referência no projeto antigo (React)
- `frontend/src/hooks/useFetchUser.jsx` — busca do perfil
- `frontend/src/hooks/useUpdateUser.jsx` — atualização do perfil
- `frontend/src/hooks/useDeleteAccount.jsx` — desativação de conta
- `frontend/src/hooks/useUserProfile.jsx` — dados do perfil
- Campos do documento em `frontend/src/hooks/UseAuthentication.jsx` (linhas 74-87)

#### 📝 O que aprender para realizar essa task? (Foco em Flutter)
- Modelagem de dados com classes Dart
- `copyWith` pattern para atualização imutável
- Operações CRUD no Firestore
- https://dart.dev/language/constructors#factory-constructors

#### 🌱 Sugestão de Branch
`feature/model-user`

### 🤓 Dica: por onde começar

```dart
// lib/models/app_user.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String displayName;
  final String email;
  final String photoURL;
  final String role;
  final String createdAt;
  final int score;
  final int reportCount;
  final String lastLoginAt;
  final String region;
  final bool verified;
  final String bio;
  final String status;

  AppUser({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoURL = '',
    this.role = 'user',
    required this.createdAt,
    this.score = 0,
    this.reportCount = 0,
    required this.lastLoginAt,
    this.region = '',
    this.verified = false,
    this.bio = '',
    this.status = 'active',
  });

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUser(
      uid: doc.id,
      displayName: data['displayName'] ?? '',
      email: data['email'] ?? '',
      photoURL: data['photoURL'] ?? '',
      role: data['role'] ?? 'user',
      createdAt: data['createdAt'] ?? '',
      score: data['score'] ?? 0,
      reportCount: data['reportCount'] ?? 0,
      lastLoginAt: data['lastLoginAt'] ?? '',
      region: data['region'] ?? '',
      verified: data['verified'] ?? false,
      bio: data['bio'] ?? '',
      status: data['status'] ?? 'active',
    );
  }
}
```

---

### 🟣 [UI | 5 pontos] Tela de Perfil do Usuário

#### 🧩 Descrição
Criar a tela de perfil que exibe as informações do usuário logado: foto, nome, email, bio, região, data de cadastro, estatísticas (total de denúncias, score) e badges conquistadas.

#### 🎯 Objetivo e Critérios de Aceite
- [ ] Tela `lib/screens/perfil_screen.dart` criada.
- [ ] Header do perfil com avatar (`CircleAvatar`), nome e email.
- [ ] Card de estatísticas: total de denúncias e score.
- [ ] Seção de badges (implementada na task seguinte, placeholder por agora).
- [ ] Seção "Minhas Denúncias" (placeholder por agora).
- [ ] Botão "Editar Perfil" que abre formulário de edição.
- [ ] Botão "Sair" que chama logout.
- [ ] Dados carregados do Firestore via `UserService`.

#### 🔍 Referência no projeto antigo (React)
- `frontend/src/pages/PerfilUsuarioPage.jsx`
- `frontend/src/components/perfil/PerfilHeader.jsx`
- `frontend/src/components/perfil/PerfilUsuarioCard.jsx`
- `frontend/src/components/perfil/EstatisticasCard.jsx`

#### 📝 O que aprender para realizar essa task? (Foco em Flutter)
- `CircleAvatar` com `NetworkImage` para foto do perfil
- `Card` e composição de layout
- `context.read<AuthProvider>()` para acessar dados do usuário
- `FutureBuilder` para carregar dados do Firestore
- https://api.flutter.dev/flutter/material/CircleAvatar-class.html

#### 🌱 Sugestão de Branch
`feature/tela-perfil`

### 🤓 Dica: por onde começar

```dart
// lib/screens/perfil_screen.dart (esqueleto)
class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final uid = authProvider.user!.uid;

    return FutureBuilder<AppUser?>(
      future: UserService().getUserById(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final user = snapshot.data;
        if (user == null) return const Center(child: Text('Usuário não encontrado'));

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              CircleAvatar(radius: 50, backgroundImage: NetworkImage(user.photoURL)),
              const SizedBox(height: 12),
              Text(user.displayName, style: Theme.of(context).textTheme.headlineSmall),
              Text(user.email, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 24),
              // Cards de estatísticas, badges, etc.
            ],
          ),
        );
      },
    );
  }
}
```

---

### 🟣 [UI | 5 pontos] Formulário de Edição de Perfil

#### 🧩 Descrição
Criar um formulário (em tela separada ou modal) para o usuário editar suas informações: nome de exibição, bio e região. Ao salvar, atualizar o documento no Firestore.

#### 🎯 Objetivo e Critérios de Aceite
- [ ] Tela ou modal `lib/screens/editar_perfil_screen.dart` criado.
- [ ] Campos editáveis: nome de exibição, bio, região.
- [ ] Campos preenchidos com os valores atuais do perfil.
- [ ] Validação: nome não pode ser vazio.
- [ ] Ao salvar: atualiza `displayName`, `bio`, `region` no Firestore e no Firebase Auth (`updateProfile`).
- [ ] Feedback de sucesso (SnackBar) e navegação de volta ao perfil.
- [ ] Botão "Desativar Conta" com diálogo de confirmação.

#### 🔍 Referência no projeto antigo (React)
- `frontend/src/components/perfil/EditarPerfilForm.jsx`
- `frontend/src/hooks/useUpdateUser.jsx`
- `frontend/src/components/perfil/ConfirmDeactivateDialog.jsx`
- `frontend/src/hooks/useDeleteAccount.jsx`

#### 📝 O que aprender para realizar essa task? (Foco em Flutter)
- `TextFormField` com `initialValue` ou `TextEditingController(text: ...)`
- `showDialog` para diálogos de confirmação
- `AlertDialog` do Material Design
- `FirebaseAuth.instance.currentUser!.updateDisplayName()`
- https://api.flutter.dev/flutter/material/AlertDialog-class.html

#### 🌱 Sugestão de Branch
`feature/editar-perfil`

### 🤓 Dica: por onde começar

```dart
Future<void> _salvarPerfil() async {
  if (!_formKey.currentState!.validate()) return;

  final uid = FirebaseAuth.instance.currentUser!.uid;

  await FirebaseFirestore.instance.collection('users').doc(uid).update({
    'displayName': _nomeController.text.trim(),
    'bio': _bioController.text.trim(),
    'region': _regiaoController.text.trim(),
  });

  await FirebaseAuth.instance.currentUser!.updateDisplayName(_nomeController.text.trim());

  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil atualizado com sucesso!')),
    );
    context.pop();
  }
}
```

---

### 🟠 [UX | 5 pontos] Sistema de Badges

#### 🧩 Descrição
Implementar o sistema de badges (conquistas) do usuário. As badges são atribuídas com base no `score` e `reportCount` do usuário. Criar a lógica de regras e o widget de exibição.

#### 🎯 Objetivo e Critérios de Aceite
- [ ] Arquivo `lib/utils/badge_rules.dart` criado com as regras de badges.
- [ ] Widget `lib/widgets/perfil/badges_display.dart` criado.
- [ ] Regras implementadas: Iniciante (score 0-99), Engajado (100-499), Vigilante Urbano (500+), Reportador Frequente (20+ denúncias), Usuário Verificado (verified === true).
- [ ] Cada badge exibe: ícone, rótulo e indicação de "conquistada" ou "bloqueada".
- [ ] Integrado na tela de perfil.

#### 🔍 Referência no projeto antigo (React)
- `frontend/src/lib/badges/badgeRules.js` — regras de badges
- `frontend/src/lib/badges/getUserBadges.js` — função que calcula badges ativas
- `frontend/src/components/perfil/BadgesDisplay.jsx` — componente de exibição

#### 📝 O que aprender para realizar essa task? (Foco em Flutter)
- Lógica condicional em Dart
- `Chip`, `FilterChip` ou widgets customizados para badges
- `Opacity` ou `ColorFiltered` para badges bloqueadas
- `Wrap` para exibir múltiplas badges
- https://api.flutter.dev/flutter/material/FilterChip-class.html

#### 🌱 Sugestão de Branch
`feature/badges`

### 🤓 Dica: por onde começar

```dart
// lib/utils/badge_rules.dart
import '../models/app_user.dart';

class Badge {
  final String id;
  final String label;
  final String icon;
  final bool Function(AppUser user) condition;

  const Badge({required this.id, required this.label, required this.icon, required this.condition});
}

final badgeRules = [
  Badge(id: 'iniciante', label: 'Iniciante', icon: '🌱', condition: (u) => u.score >= 0 && u.score < 100),
  Badge(id: 'engajado', label: 'Engajado', icon: '🔥', condition: (u) => u.score >= 100 && u.score < 500),
  Badge(id: 'vigilante', label: 'Vigilante Urbano', icon: '🛡️', condition: (u) => u.score >= 500),
  Badge(id: 'reportador', label: 'Reportador Frequente', icon: '📢', condition: (u) => u.reportCount >= 20),
  Badge(id: 'verificado', label: 'Usuário Verificado', icon: '✅', condition: (u) => u.verified),
];

List<Badge> getUserBadges(AppUser user) {
  return badgeRules.where((b) => b.condition(user)).toList();
}
```

---

### 🔵 [Integração | 5 pontos] Minhas Denúncias e Denúncias Salvas

#### 🧩 Descrição
Implementar duas seções na tela de perfil: "Minhas Denúncias" (denúncias criadas pelo usuário) e "Denúncias Salvas" (denúncias que o usuário salvou/favoritou). Permitir salvar/remover denúncias dos favoritos.

#### 🎯 Objetivo e Critérios de Aceite
- [ ] Seção "Minhas Denúncias" exibe lista de denúncias onde `userId == currentUser.uid`.
- [ ] Cada item usa o widget `CardDenuncia` já criado.
- [ ] Seção "Denúncias Salvas" lê documentos da subcoleção `users/{uid}/savedReports`.
- [ ] Método `saveReport(uid, reportId)` salva referência na subcoleção.
- [ ] Método `removeReport(uid, reportId)` remove da subcoleção.
- [ ] Ícone de favorito (coração) na `CardDenuncia` para salvar/remover.
- [ ] Tabs ou toggle para alternar entre "Minhas" e "Salvas".

#### 🔍 Referência no projeto antigo (React)
- `frontend/src/components/perfil/MinhasDenuncias.jsx`
- `frontend/src/hooks/useUserReports.jsx` — denúncias do usuário
- `frontend/src/components/denuncias/CardDenuncia.jsx` — botão de salvar/remover
- Subcoleção Firestore: `users/{uid}/savedReports`

#### 📝 O que aprender para realizar essa task? (Foco em Flutter)
- `DefaultTabController`, `TabBar`, `TabBarView`
- Subcoleções no Firestore
- `IconButton` com estado (preenchido/vazio) para favoritar
- `StreamBuilder` para lista reativa
- https://docs.flutter.dev/cookbook/design/tabs

#### 🌱 Sugestão de Branch
`feature/minhas-denuncias`

### 🤓 Dica: por onde começar

```dart
// Buscar denúncias do usuário
Future<List<Report>> getUserReports(String uid) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('reports')
      .where('userId', isEqualTo: uid)
      .orderBy('createdAt', descending: true)
      .get();
  return snapshot.docs.map((doc) => Report.fromFirestore(doc)).toList();
}

// Salvar denúncia nos favoritos
Future<void> saveReport(String uid, String reportId) async {
  await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('savedReports')
      .doc(reportId)
      .set({'savedAt': FieldValue.serverTimestamp()});
}
```

---

## Milestone 9: Painel Administrativo

> **Objetivo:** Criar o painel de administração com dashboards, gestão de denúncias, gestão de usuários e exportação de dados.

---

### 🟣 [UI | 8 pontos] Dashboard Administrativo

#### 🧩 Descrição
Criar a tela de dashboard do admin que exibe estatísticas gerais do sistema: total de denúncias por status, total de usuários, denúncias recentes e gráficos de evolução. Protegida por role admin.

#### 🎯 Objetivo e Critérios de Aceite
- [ ] Tela `lib/screens/admin/admin_dashboard_screen.dart` criada.
- [ ] Cards de estatísticas: total de denúncias, pendentes, em análise, resolvidas, rejeitadas.
- [ ] Total de usuários cadastrados.
- [ ] Gráfico de barras ou pizza com distribuição por status (usando `fl_chart` ou `charts_flutter`).
- [ ] Lista das 5 denúncias mais recentes.
- [ ] Navegação para "Gestão de Denúncias" e "Gestão de Usuários".
- [ ] Dados carregados do Firestore em tempo real.

#### 🔍 Referência no projeto antigo (React)
- `frontend/src/pages/AdminDashboardPage.jsx`
- `frontend/src/components/admin/denuncias/DenunciasStats.jsx`
- `frontend/src/components/admin/denuncias/DenunciasDashboard.jsx`
- `frontend/src/components/admin/users/UsersStats.jsx`
- `frontend/src/components/admin/users/UsersCharts.jsx` — gráficos com Recharts

#### 📝 O que aprender para realizar essa task? (Foco em Flutter)
- `AggregateQuery` ou contagem manual no Firestore
- `fl_chart` package para gráficos
- `GridView` para layout de cards de estatísticas
- `FutureBuilder` para carregar dados
- https://pub.dev/packages/fl_chart

#### 🌱 Sugestão de Branch
`feature/admin-dashboard`

### 🤓 Dica: por onde começar

```dart
// Exemplo de card de estatística
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const StatCard({super.key, required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            Text(title, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
```

---

### 🔵 [Integração | 8 pontos] Gestão de Denúncias (Admin)

#### 🧩 Descrição
Criar a tela de gestão de denúncias para administradores. Permite visualizar todas as denúncias em formato de tabela/lista, buscar por título, filtrar por status/categoria e alterar o status de qualquer denúncia.

#### 🎯 Objetivo e Critérios de Aceite
- [ ] Tela `lib/screens/admin/admin_denuncias_screen.dart` criada.
- [ ] Lista de denúncias em formato de tabela (`DataTable`) ou lista detalhada.
- [ ] Campo de busca por título.
- [ ] Filtros por status e categoria.
- [ ] Cada item tem botão/dropdown para alterar o status (pending → review → resolved/rejected).
- [ ] Ao alterar status: atualiza no Firestore e registra entrada em `auditlogs`.
- [ ] Diálogo de confirmação antes de alterar status.
- [ ] Campo de comentário obrigatório ao alterar status.

#### 🔍 Referência no projeto antigo (React)
- `frontend/src/pages/AdminPage.jsx`
- `frontend/src/components/admin/denuncias/DenunciasTable.jsx`
- `frontend/src/components/admin/denuncias/DenunciasSearch.jsx`
- `frontend/src/hooks/useReportStatus.jsx` — atualização de status
- `frontend/src/utils/logAudit.jsx` — registro de audit log

#### 📝 O que aprender para realizar essa task? (Foco em Flutter)
- `DataTable`, `DataColumn`, `DataRow`, `DataCell` para tabelas
- `SearchBar` ou `TextField` com `onChanged` para busca
- `PopupMenuButton` para menu de ações
- `showDialog` com `AlertDialog` para confirmação
- Batch writes no Firestore para atomicidade
- https://api.flutter.dev/flutter/material/DataTable-class.html

#### 🌱 Sugestão de Branch
`feature/admin-denuncias`

### 🤓 Dica: por onde começar

```dart
// Alterar status com audit log
Future<void> updateStatus(String reportId, String newStatus, String comment, String userId, String userName) async {
  final batch = FirebaseFirestore.instance.batch();

  final reportRef = FirebaseFirestore.instance.collection('reports').doc(reportId);
  batch.update(reportRef, {
    'status': newStatus,
    'updatedAt': FieldValue.serverTimestamp(),
    if (newStatus == 'resolved') 'resolvedAt': FieldValue.serverTimestamp(),
  });

  final auditRef = FirebaseFirestore.instance.collection('auditlogs').doc();
  batch.set(auditRef, {
    'timestamp': FieldValue.serverTimestamp(),
    'userId': userId,
    'userDisplayName': userName,
    'reportId': reportId,
    'action': 'status_change',
    'newStatus': newStatus,
    'comment': comment,
  });

  await batch.commit();
}
```

---

### 🔵 [Integração | 5 pontos] Gestão de Usuários (Admin)

#### 🧩 Descrição
Criar a tela de gestão de usuários para administradores. Permite visualizar todos os usuários cadastrados, buscar por nome/email e alterar o role (user/admin) e status (active/inactive) de cada usuário.

#### 🎯 Objetivo e Critérios de Aceite
- [ ] Tela `lib/screens/admin/admin_usuarios_screen.dart` criada.
- [ ] Lista de usuários com: nome, email, role, status, data de cadastro, score.
- [ ] Campo de busca por nome ou email.
- [ ] Botão para alterar role (user ↔ admin) com confirmação.
- [ ] Botão para alterar status (ativar/desativar) com confirmação.
- [ ] Indicadores visuais para role e status.

#### 🔍 Referência no projeto antigo (React)
- `frontend/src/pages/UsersAdminPage.jsx`
- `frontend/src/components/admin/users/UsersTable.jsx`
- `frontend/src/components/admin/users/UsersSearch.jsx`
- `frontend/src/components/admin/users/UsersAdminHeader.jsx`
- `frontend/src/hooks/useAllUsers.jsx` — listar todos os usuários
- `frontend/src/hooks/useUpdateUserRole.jsx` — alterar role
- `frontend/src/hooks/useUpdateUserStatus.jsx` — alterar status

#### 📝 O que aprender para realizar essa task? (Foco em Flutter)
- `DataTable` para tabela de usuários
- `Switch` para toggle de status
- `DropdownButton` para seleção de role
- `showDialog` para confirmação de ações
- https://api.flutter.dev/flutter/material/Switch-class.html

#### 🌱 Sugestão de Branch
`feature/admin-usuarios`

### 🤓 Dica: por onde começar

```dart
// lib/services/admin_service.dart
class AdminService {
  final _usersCollection = FirebaseFirestore.instance.collection('users');

  Future<List<AppUser>> getAllUsers() async {
    final snapshot = await _usersCollection.orderBy('createdAt', descending: true).get();
    return snapshot.docs.map((doc) => AppUser.fromFirestore(doc)).toList();
  }

  Future<void> updateUserRole(String uid, String newRole) async {
    await _usersCollection.doc(uid).update({'role': newRole});
  }

  Future<void> updateUserStatus(String uid, String newStatus) async {
    await _usersCollection.doc(uid).update({'status': newStatus});
  }
}
```

---

### 🔵 [Integração | 5 pontos] Exportação CSV

#### 🧩 Descrição
Implementar a funcionalidade de exportação de dados em formato CSV. O admin pode exportar a lista de denúncias e/ou usuários para um arquivo CSV que é baixado ou compartilhado.

#### 🎯 Objetivo e Critérios de Aceite
- [ ] Botão "Exportar CSV" na tela de gestão de denúncias e de usuários.
- [ ] Gera arquivo CSV com cabeçalhos e dados formatados.
- [ ] Para denúncias: ID, título, categoria, status, data, endereço, userId.
- [ ] Para usuários: nome, email, role, status, score, reportCount, createdAt.
- [ ] Arquivo é compartilhado via `share_plus` ou salvo no dispositivo via `path_provider`.
- [ ] Feedback visual: loading durante geração e SnackBar de sucesso.

#### 🔍 Referência no projeto antigo (React)
- `frontend/src/components/admin/denuncias/ExportCSV.jsx`

#### 📝 O que aprender para realizar essa task? (Foco em Flutter)
- Manipulação de strings CSV em Dart
- `path_provider` para obter diretório temporário
- `share_plus` para compartilhar arquivos
- `dart:io` → `File` para escrever arquivos
- https://pub.dev/packages/share_plus
- https://pub.dev/packages/path_provider

#### 🌱 Sugestão de Branch
`feature/export-csv`

### 🤓 Dica: por onde começar

```dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<void> exportReportsCSV(List<Report> reports) async {
  final buffer = StringBuffer();
  buffer.writeln('ID,Título,Categoria,Status,Data,Endereço');

  for (final r in reports) {
    buffer.writeln(
      '"${r.id}","${r.title}","${r.category.name}","${r.status.name}","${r.createdAt.toIso8601String()}","${r.location['address'] ?? ''}"',
    );
  }

  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/denuncias.csv');
  await file.writeAsString(buffer.toString());

  await Share.shareXFiles([XFile(file.path)], text: 'Relatório de Denúncias');
}
```

---

## Milestone 10: Polimento e Funcionalidades Avançadas

> **Objetivo:** Adicionar funcionalidades de polimento como notificações push, acessibilidade e testes automatizados.

---

### 🔵 [Integração | 8 pontos] Notificações Push (FCM)

#### 🧩 Descrição
Integrar o Firebase Cloud Messaging (FCM) para enviar e receber notificações push. Configurar o FCM no Flutter, solicitar permissão do usuário e lidar com notificações em foreground e background.

#### 🎯 Objetivo e Critérios de Aceite
- [ ] Pacote `firebase_messaging` adicionado e configurado.
- [ ] Permissão de notificações solicitada ao usuário na primeira vez.
- [ ] Token FCM do dispositivo obtido e salvo no Firestore (campo `fcmToken` no documento do usuário).
- [ ] Notificações em foreground exibidas como dialog/snackbar.
- [ ] Notificações em background recebidas e exibidas na bandeja do sistema.
- [ ] Ao clicar na notificação, navega para a tela relevante.
- [ ] Serviço `lib/services/notification_service.dart` criado.

#### 🔍 Referência no projeto antigo (React)
- `frontend/src/firebase/notifications_fcm.jsx` — configuração do FCM
- `frontend/src/hooks/use-Notification.jsx` — gerenciamento de notificações
- `frontend/src/services/notificationService.js`
- `frontend/public/firebase-messaging-sw.js` — service worker

#### 📝 O que aprender para realizar essa task? (Foco em Flutter)
- `firebase_messaging` package
- `FirebaseMessaging.instance.requestPermission()`
- `FirebaseMessaging.onMessage`, `onMessageOpenedApp`, `onBackgroundMessage`
- `flutter_local_notifications` para exibir notificações em foreground
- https://firebase.flutter.dev/docs/messaging/overview
- https://pub.dev/packages/firebase_messaging

#### 🌱 Sugestão de Branch
`feature/notificacoes-fcm`

### 🤓 Dica: por onde começar

```dart
// lib/services/notification_service.dart
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      final token = await _messaging.getToken();
      // Salvar token no Firestore para o usuário logado

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        // Exibir notificação em foreground
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        // Navegar para tela relevante ao clicar na notificação
      });
    }
  }
}
```

---

### 🟠 [UX | 5 pontos] Acessibilidade e Responsividade

#### 🧩 Descrição
Revisar todo o app para garantir boas práticas de acessibilidade (leitores de tela, contraste, navegação por teclado) e responsividade (diferentes tamanhos de tela).

#### 🎯 Objetivo e Critérios de Aceite
- [ ] Todos os widgets interativos possuem `Semantics` ou `Tooltip` para leitores de tela.
- [ ] Imagens possuem `semanticLabel` descritivo.
- [ ] Contraste de cores atende WCAG AA (verificar com ferramenta).
- [ ] Fontes respeitam a escala de acessibilidade do sistema (`MediaQuery.textScaleFactor`).
- [ ] Layout se adapta a telas pequenas (celulares) e grandes (tablets).
- [ ] Teste manual com TalkBack (Android) ou VoiceOver (iOS).
- [ ] `LayoutBuilder` ou `MediaQuery` usados para adaptar layouts quando necessário.

#### 🔍 Referência no projeto antigo (React)
- `frontend/src/hooks/useAccessibility.jsx`
- `frontend/src/hooks/useKeyboardNavigation.jsx`
- `frontend/src/accessibility.css`

#### 📝 O que aprender para realizar essa task? (Foco em Flutter)
- `Semantics` widget para leitores de tela
- `MediaQuery` para responsividade
- `LayoutBuilder` para layouts adaptativos
- `Tooltip` para botões de ícone
- Boas práticas de acessibilidade no Flutter
- https://docs.flutter.dev/ui/accessibility-and-internationalization/accessibility

#### 🌱 Sugestão de Branch
`enhancement/acessibilidade`

### 🤓 Dica: por onde começar

```dart
// Exemplo de widget com acessibilidade
Semantics(
  label: 'Botão para criar nova denúncia',
  button: true,
  child: FloatingActionButton(
    tooltip: 'Nova Denúncia',
    onPressed: () => context.go('/nova-denuncia'),
    child: const Icon(Icons.add),
  ),
),

// Layout responsivo com LayoutBuilder
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth > 600) {
      return GridView.count(crossAxisCount: 3, children: cards);
    }
    return ListView(children: cards);
  },
),
```

---

### 🔴 [Refatoração | 5 pontos] Testes de Widget e Integração

#### 🧩 Descrição
Escrever testes automatizados para os principais widgets e fluxos da aplicação. Cobrir pelo menos os widgets reutilizáveis, o fluxo de autenticação e o formulário de denúncia.

#### 🎯 Objetivo e Critérios de Aceite
- [ ] Testes de widget para: `StatusBadge`, `CardDenuncia`, `StudentCard`, `StatusFlow`.
- [ ] Teste de widget para o formulário de login (validação de campos).
- [ ] Teste de widget para o formulário de denúncia (validação).
- [ ] Pelo menos 1 teste de integração para o fluxo: abrir app → navegar para denúncias → clicar em card → ver detalhes.
- [ ] Todos os testes passam com `flutter test`.
- [ ] Cobertura mínima: 30% dos widgets principais.

#### 🔍 Referência no projeto antigo (React)
- O projeto React não possui testes significativos, mas os componentes criados são a base.

#### 📝 O que aprender para realizar essa task? (Foco em Flutter)
- `testWidgets` para testes de widget
- `WidgetTester`: `pumpWidget`, `tap`, `enterText`, `expect`
- `find.byType`, `find.text`, `find.byKey`
- `Mockito` ou `fake_cloud_firestore` para mock de serviços
- `integration_test` package para testes E2E
- https://docs.flutter.dev/testing/overview
- https://docs.flutter.dev/cookbook/testing/widget/introduction

#### 🌱 Sugestão de Branch
`test/widgets-integracao`

### 🤓 Dica: por onde começar

```dart
// test/widgets/status_badge_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cidade_integra/widgets/denuncias/status_badge.dart';
import 'package:cidade_integra/models/report.dart';

void main() {
  testWidgets('StatusBadge exibe texto correto para status pending', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: StatusBadge(status: ReportStatus.pending)),
      ),
    );
    expect(find.text('Pendente'), findsOneWidget);
  });

  testWidgets('StatusBadge exibe texto correto para status resolved', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: StatusBadge(status: ReportStatus.resolved)),
      ),
    );
    expect(find.text('Resolvida'), findsOneWidget);
  });
}
```

---

## Resumo Geral

| Milestone | Tasks | Foco Principal |
|-----------|-------|----------------|
| 1. Config Inicial | 3 | Estrutura, deps, tema |
| 2. Navegação | 3 | Rotas, AppBar, Footer |
| 3. Telas Estáticas | 5 | UI pura, sem backend |
| 4. Autenticação | 5 | Firebase Auth, Provider |
| 5. Listagem | 4 | Firestore, modelos, lista |
| 6. Detalhes | 4 | Detalhes, mapa, comentários |
| 7. Criação | 4 | Form, upload, geocoding |
| 8. Perfil | 5 | Perfil, badges, favoritos |
| 9. Admin | 4 | Dashboard, gestão, CSV |
| 10. Polimento | 3 | FCM, a11y, testes |

**Ordem recomendada:** Siga os milestones sequencialmente (1 → 10). Dentro de cada milestone, as tasks podem ser feitas na ordem listada, pois estão organizadas de forma que cada uma depende das anteriores.

**Dica de ouro:** Antes de cada task, leia a seção "O que aprender" e explore os links da documentação. Em seguida, olhe o código de referência do projeto React para entender a regra de negócio. Só então comece a codificar no Flutter.
