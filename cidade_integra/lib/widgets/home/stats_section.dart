import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class StatsSection extends StatelessWidget {
  const StatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: substituir por dados reais do Firestore no Milestone 5
    final stats = [
      _StatData(icon: Icons.campaign, value: '150+', label: 'Denúncias Registradas'),
      _StatData(icon: Icons.check_circle, value: '50+', label: 'Problemas Resolvidos'),
      _StatData(icon: Icons.schedule, value: '5', label: 'Dias em Média para Solução'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        children: [
          Text(
            'Nossa Atuação em Números',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.azul,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ...stats.map((stat) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _StatCard(data: stat),
          )),
        ],
      ),
    );
  }
}

class _StatData {
  final IconData icon;
  final String value;
  final String label;
  const _StatData({required this.icon, required this.value, required this.label});
}

class _StatCard extends StatelessWidget {
  final _StatData data;
  const _StatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.verde.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(data.icon, size: 28, color: AppColors.verdeEscuro),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.value,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.azul,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    data.label,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textoSecundario,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
