import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../utils/app_theme.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final currentYear = DateTime.now().year;

    return Container(
      color: AppColors.azul,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Navegação ---
          Text(
            'Navegue',
            style: TextStyle(
              color: AppColors.verde,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 24,
            runSpacing: 8,
            children: [
              _FooterLink(label: 'Início', route: '/'),
              _FooterLink(label: 'Denúncias', route: '/denuncias'),
              _FooterLink(label: 'Reportar Problema', route: '/nova-denuncia'),
              _FooterLink(label: 'Sobre nós', route: '/sobre'),
              _FooterLink(label: 'Dúvidas', route: '/duvidas'),
            ],
          ),

          const SizedBox(height: 24),

          // --- Descrição ---
          SvgPicture.asset(
            'assets/images/logotipo-sem-borda.svg',
            height: 40,
          ),
          const SizedBox(height: 8),
          Text(
            'Uma plataforma para cidadãos reportarem problemas urbanos e contribuírem para uma cidade melhor.',
            style: TextStyle(color: AppColors.cinza, fontSize: 13, height: 1.5),
          ),

          const SizedBox(height: 24),

          // --- Contato ---
          Text(
            'Contato',
            style: TextStyle(
              color: AppColors.verde,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Para suporte ou informações adicionais:\nsuporte@cidadeintegra.com',
            style: TextStyle(color: AppColors.cinza, fontSize: 13, height: 1.5),
          ),

          // --- Divisor + Copyright ---
          const SizedBox(height: 24),
          Divider(color: AppColors.cinza.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Center(
            child: Text(
              '© $currentYear Cidade Integra. Todos os direitos reservados.',
              style: TextStyle(color: AppColors.cinza, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String label;
  final String route;

  const _FooterLink({required this.label, required this.route});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go(route),
      child: Text(
        label,
        style: TextStyle(color: AppColors.cinza, fontSize: 14),
      ),
    );
  }
}
