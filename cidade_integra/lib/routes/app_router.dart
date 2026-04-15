import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../widgets/layout/base_layout.dart';
import '../screens/home_screen.dart';
import '../screens/denuncias_screen.dart';
import '../screens/denuncia_detalhes_screen.dart';
import '../screens/nova_denuncia_screen.dart';
import '../screens/editar_perfil_screen.dart';
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

const _protectedRoutes = ['/nova-denuncia', '/perfil', '/perfil/editar'];
const _adminRoutes = ['/admin', '/admin/denuncias', '/admin/usuarios'];
const _authRoutes = ['/login', '/registro', '/recuperar-senha'];

GoRouter buildRouter(AuthProvider auth) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: auth,
    errorBuilder: (context, state) => const NotFoundScreen(),
    redirect: (context, state) {
      final path = state.uri.path;
      final loggedIn = auth.isLoggedIn;
      final loading = auth.isLoading;

      if (loading) return null;

      if (_protectedRoutes.contains(path) && !loggedIn) return '/login';

      if (_adminRoutes.any((r) => path.startsWith(r))) {
        if (!loggedIn) return '/login';
        if (!auth.isAdmin) return '/acesso-negado';
      }

      if (_authRoutes.contains(path) && loggedIn) return '/';

      return null;
    },
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => BaseLayout(child: child),
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) => const NoTransitionPage(child: HomeScreen()),
          ),
          GoRoute(
            path: '/denuncias',
            pageBuilder: (context, state) => const NoTransitionPage(child: DenunciasScreen()),
          ),
          GoRoute(
            path: '/denuncias/:id',
            pageBuilder: (context, state) {
              final id = state.pathParameters['id']!;
              return NoTransitionPage(child: DenunciaDetalhesScreen(reportId: id));
            },
          ),
          GoRoute(
            path: '/login',
            pageBuilder: (context, state) => const NoTransitionPage(child: LoginScreen()),
          ),
          GoRoute(
            path: '/registro',
            pageBuilder: (context, state) => const NoTransitionPage(child: RegisterScreen()),
          ),
          GoRoute(
            path: '/recuperar-senha',
            pageBuilder: (context, state) => const NoTransitionPage(child: RecuperarSenhaScreen()),
          ),
          GoRoute(
            path: '/sobre',
            pageBuilder: (context, state) => const NoTransitionPage(child: SobreScreen()),
          ),
          GoRoute(
            path: '/duvidas',
            pageBuilder: (context, state) => const NoTransitionPage(child: FaqScreen()),
          ),
          GoRoute(
            path: '/nova-denuncia',
            pageBuilder: (context, state) => const NoTransitionPage(child: NovaDenunciaScreen()),
          ),
          GoRoute(
            path: '/perfil',
            pageBuilder: (context, state) => const NoTransitionPage(child: PerfilScreen()),
          ),
          GoRoute(
            path: '/perfil/editar',
            pageBuilder: (context, state) => const NoTransitionPage(child: EditarPerfilScreen()),
          ),
          GoRoute(
            path: '/admin',
            pageBuilder: (context, state) => const NoTransitionPage(child: AdminDashboardScreen()),
          ),
          GoRoute(
            path: '/admin/denuncias',
            pageBuilder: (context, state) => const NoTransitionPage(child: AdminDenunciasScreen()),
          ),
          GoRoute(
            path: '/admin/usuarios',
            pageBuilder: (context, state) => const NoTransitionPage(child: AdminUsuariosScreen()),
          ),
        ],
      ),
      GoRoute(
        path: '/acesso-negado',
        pageBuilder: (context, state) => const NoTransitionPage(child: AccessDeniedScreen()),
      ),
    ],
  );
}
