import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/layout/base_layout.dart';
import '../screens/home_screen.dart';
import '../screens/denuncias_screen.dart';
import '../screens/denuncia_detalhes_screen.dart';
import '../screens/nova_denuncia_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/recuperar_senha_screen.dart';
import '../screens/perfil_screen.dart';
import '../screens/sobre_screen.dart';
import '../screens/faq_screen.dart';
import '../screens/access_denied_screen.dart';
import '../screens/not_found_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/admin_denuncias_screen.dart';
import '../screens/admin/admin_usuarios_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  errorBuilder: (context, state) => const NotFoundScreen(),
  routes: [
    // Layout base (AppBar + Drawer) compartilhado por todas as telas internas
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => BaseLayout(child: child),
      routes: [
        // --- Rotas públicas ---
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
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
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/registro',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/recuperar-senha',
          builder: (context, state) => const RecuperarSenhaScreen(),
        ),
        GoRoute(
          path: '/sobre',
          builder: (context, state) => const SobreScreen(),
        ),
        GoRoute(
          path: '/duvidas',
          builder: (context, state) => const FaqScreen(),
        ),

        // --- Rotas protegidas (guard será adicionado no Milestone 4) ---
        GoRoute(
          path: '/nova-denuncia',
          builder: (context, state) => const NovaDenunciaScreen(),
        ),
        GoRoute(
          path: '/perfil',
          builder: (context, state) => const PerfilScreen(),
        ),

        // --- Rotas admin (guard será adicionado no Milestone 4) ---
        GoRoute(
          path: '/admin',
          builder: (context, state) => const AdminDashboardScreen(),
        ),
        GoRoute(
          path: '/admin/denuncias',
          builder: (context, state) => const AdminDenunciasScreen(),
        ),
        GoRoute(
          path: '/admin/usuarios',
          builder: (context, state) => const AdminUsuariosScreen(),
        ),
      ],
    ),

    // Telas fora do shell (possuem Scaffold próprio, sem AppBar/Drawer)
    GoRoute(
      path: '/acesso-negado',
      builder: (context, state) => const AccessDeniedScreen(),
    ),
  ],
);
