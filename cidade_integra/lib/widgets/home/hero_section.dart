import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/app_theme.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.azul, Color(0xFF1A3D52)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.2,
                ),
                children: [
                  const TextSpan(text: 'Ajude a '),
                  TextSpan(
                    text: 'melhorar',
                    style: TextStyle(color: AppColors.verde),
                  ),
                  const TextSpan(text: ' sua cidade!'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Reporte problemas urbanos como buracos nas ruas, iluminação, lixo e mais. '
              'Sua participação é essencial para uma cidade melhor.',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.cinza,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            // Imagem hero
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/hero-foto.webp',
                width: double.infinity,
                fit: BoxFit.contain,
                semanticLabel: 'Cidadãos reportando problemas urbanos na cidade',
                errorBuilder: (_, __, ___) => Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.verdeEscuro.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(Icons.location_city, size: 64, color: Colors.white54),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Botões CTA
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => context.go('/nova-denuncia'),
                icon: const Icon(Icons.location_on, size: 20),
                label: const Text('Reportar Problema'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.verde,
                  foregroundColor: AppColors.azul,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.go('/denuncias'),
                icon: const Text('Ver Denúncias'),
                label: const Icon(Icons.arrow_forward, size: 20),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.verde,
                  side: BorderSide(color: AppColors.verde),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
