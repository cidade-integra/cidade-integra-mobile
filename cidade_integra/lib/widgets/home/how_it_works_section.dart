import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/app_theme.dart';

class HowItWorksSection extends StatelessWidget {
  const HowItWorksSection({super.key});

  @override
  Widget build(BuildContext context) {
    final steps = [
      _StepData(
        number: '1',
        title: 'Registre o Problema',
        description:
            'Utilize nosso aplicativo para registrar o problema. '
            'Adicione fotos, descrição e localização precisa.',
        route: '/nova-denuncia',
      ),
      _StepData(
        number: '2',
        title: 'Acompanhe o Status',
        description:
            'Nossa equipe analisa e encaminha a denúncia para o órgão '
            'responsável. Você pode acompanhar todo o processo.',
        route: '/perfil',
      ),
      _StepData(
        number: '3',
        title: 'Problema Resolvido',
        description:
            'Após resolvido, você receberá uma notificação. Você também pode '
            'confirmar se o problema foi corretamente solucionado.',
        route: '/denuncias',
      ),
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        children: [
          Text(
            'Como Funciona?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.azul,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textoSecundario,
                height: 1.4,
              ),
              children: [
                const TextSpan(
                    text:
                        'Reportar problemas urbanos nunca foi tão fácil. Com apenas alguns passos, você pode contribuir para '),
                TextSpan(
                  text: 'melhorar sua cidade!',
                  style: TextStyle(
                      color: AppColors.azul, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          ...steps.map((step) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _StepCard(data: step),
              )),
        ],
      ),
    );
  }
}

class _StepData {
  final String number;
  final String title;
  final String description;
  final String route;
  const _StepData({
    required this.number,
    required this.title,
    required this.description,
    required this.route,
  });
}

class _StepCard extends StatelessWidget {
  final _StepData data;
  const _StepCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => context.go(data.route),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.bordas),
        ),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.verde,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  data.number,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              data.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.azul,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              data.description,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textoSecundario,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
