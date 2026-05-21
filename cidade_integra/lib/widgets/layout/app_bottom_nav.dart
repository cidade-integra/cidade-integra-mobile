import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/scroll_to_top.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key});

  static const _items = [
    _NavItem(label: 'Início', icon: Icons.home_outlined, route: '/'),
    _NavItem(
      label: 'Denúncias',
      icon: Icons.list_alt_outlined,
      route: '/denuncias',
    ),
    _NavItem(
      label: 'Reportar',
      icon: Icons.add_box_outlined,
      route: '/nova-denuncia',
    ),
    _NavItem(label: 'Perfil', icon: Icons.person_outline, route: '/perfil'),
  ];

  int _indexFromPath(String path) {
    for (var i = _items.length - 1; i >= 0; i--) {
      final r = _items[i].route;
      if (r == '/') {
        if (path == '/') return i;
      } else if (path.startsWith(r)) {
        return i;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    final auth = context.watch<AuthProvider>();
    final selected = _indexFromPath(path);

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: selected,
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.verde,
      unselectedItemColor: AppColors.textoSecundario,
      showUnselectedLabels: true,
      onTap: (i) {
        final item = _items[i];
        // Rotas que exigem login: se não autenticado, manda para /login.
        if (!auth.isLoggedIn &&
            (item.route == '/nova-denuncia' || item.route == '/perfil')) {
          context.go('/login');
          ScrollToTop.trigger();
          return;
        }
        if (path != item.route) {
          context.go(item.route);
          ScrollToTop.trigger();
        }
      },
      items: _items
          .map(
            (it) => BottomNavigationBarItem(
              icon: Icon(it.icon),
              label: it.label,
            ),
          )
          .toList(),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final String route;
  const _NavItem({
    required this.label,
    required this.icon,
    required this.route,
  });
}
