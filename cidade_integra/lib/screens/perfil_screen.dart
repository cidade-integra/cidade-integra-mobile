import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/app_user.dart';
import '../providers/auth_provider.dart';
import '../services/user_service.dart';
import '../utils/app_theme.dart';
import '../widgets/perfil/badges_display.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.isLoggedIn) {
      return const Center(child: Text('Faça login para ver seu perfil.'));
    }

    return FutureBuilder<AppUser?>(
      future: UserService().getUserById(auth.user!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = snapshot.data;
        if (user == null) {
          return const Center(child: Text('Usuário não encontrado.'));
        }

        return _ProfileContent(user: user);
      },
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final AppUser user;
  const _ProfileContent({required this.user});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();

    return Column(
      children: [
        // Header do perfil
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.azul,
                AppColors.azul.withValues(alpha: 0.85),
              ],
            ),
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: AppColors.verde,
                backgroundImage: user.photoURL.isNotEmpty
                    ? NetworkImage(user.photoURL)
                    : null,
                child: user.photoURL.isEmpty
                    ? Text(
                        user.displayName.isNotEmpty
                            ? user.displayName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 14),
              Text(
                user.displayName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user.email,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              if (user.bio.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  user.bio,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.8),
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (user.region.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: 14, color: Colors.white.withValues(alpha: 0.7)),
                    const SizedBox(width: 4),
                    Text(
                      user.region,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        // Estatísticas
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.campaign_outlined,
                  label: 'Denúncias',
                  value: '${user.reportCount}',
                  color: AppColors.verde,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.star_outline,
                  label: 'Score',
                  value: '${user.score}',
                  color: const Color(0xFFF39C12),
                ),
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: BadgesDisplay(user: user),
        ),
        const SizedBox(height: 16),

        // Ações
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OutlinedButton.icon(
                onPressed: () => context.go('/perfil/editar'),
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Editar Perfil'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  await auth.logout();
                  if (context.mounted) context.go('/');
                },
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('Sair'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.vermelho,
                  side: const BorderSide(color: AppColors.vermelho),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textoSecundario,
            ),
          ),
        ],
      ),
    );
  }
}
