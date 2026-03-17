import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/app_theme.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.toString();

    // TODO: substituir por context.watch<AuthProvider>() no Milestone 4
    final isLoggedIn = _checkIsLoggedIn();
    final isAdmin = _checkIsAdmin();

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppColors.azul),
            margin: EdgeInsets.zero,
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.verde,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.location_city,
                        color: Colors.white, size: 32),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Cidade Integra',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sua cidade, sua voz',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _DrawerItem(
                  icon: Icons.home_outlined,
                  label: 'Início',
                  route: '/',
                  currentPath: currentPath,
                ),
                _DrawerItem(
                  icon: Icons.campaign_outlined,
                  label: 'Denúncias',
                  route: '/denuncias',
                  currentPath: currentPath,
                ),
                _DrawerItem(
                  icon: Icons.info_outline,
                  label: 'Sobre',
                  route: '/sobre',
                  currentPath: currentPath,
                ),
                _DrawerItem(
                  icon: Icons.help_outline,
                  label: 'Dúvidas',
                  route: '/duvidas',
                  currentPath: currentPath,
                ),

                const Divider(),

                if (!isLoggedIn) ...[
                  _DrawerItem(
                    icon: Icons.login,
                    label: 'Entrar',
                    route: '/login',
                    currentPath: currentPath,
                  ),
                ],

                if (isLoggedIn) ...[
                  _DrawerItem(
                    icon: Icons.person_outline,
                    label: 'Perfil',
                    route: '/perfil',
                    currentPath: currentPath,
                  ),
                  if (isAdmin)
                    _DrawerItem(
                      icon: Icons.admin_panel_settings_outlined,
                      label: 'Admin',
                      route: '/admin',
                      currentPath: currentPath,
                    ),
                ],

                const Divider(),

                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      context.go('/nova-denuncia');
                    },
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Nova Denúncia'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.verde,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),

                if (isLoggedIn)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // TODO: chamar authProvider.logout() no Milestone 4
                        context.go('/login');
                      },
                      icon: const Icon(Icons.logout, size: 20),
                      label: const Text('Sair'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.vermelho,
                        side: const BorderSide(color: AppColors.vermelho),
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// TODO: remover quando AuthProvider estiver pronto (Milestone 4)
bool _checkIsLoggedIn() => false;
bool _checkIsAdmin() => false;

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final String currentPath;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.currentPath,
  });

  bool get _isActive {
    if (route == '/') return currentPath == '/';
    return currentPath.startsWith(route);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: _isActive ? AppColors.verde : null,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: _isActive ? FontWeight.w600 : FontWeight.normal,
          color: _isActive ? AppColors.verde : null,
        ),
      ),
      selected: _isActive,
      selectedTileColor: AppColors.verde.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onTap: () {
        Navigator.pop(context);
        context.go(route);
      },
    );
  }
}
