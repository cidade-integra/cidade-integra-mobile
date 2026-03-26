import 'package:flutter/material.dart';
import '../data/equipe.dart';
import '../utils/app_theme.dart';
import '../widgets/sobre/student_card.dart';

class SobreScreen extends StatelessWidget {
  const SobreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _HeroSobre(),
        _TeamSection(),
        _MissionSection(),
        _CommitmentSection(),
      ],
    );
  }
}

class _HeroSobre extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.verde.withValues(alpha: 0.1),
            Colors.transparent,
          ],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        children: [
          Text(
            'Sobre o Projeto',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppColors.azul,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Container(
            height: 4,
            width: 60,
            decoration: BoxDecoration(
              color: AppColors.verde,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textoSecundario,
                height: 1.5,
              ),
              children: [
                const TextSpan(text: 'O '),
                TextSpan(
                  text: 'Cidade Integra',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.verde,
                  ),
                ),
                const TextSpan(
                  text:
                      ' é um projeto desenvolvido por estudantes de Desenvolvimento de Software '
                      'Multiplataforma pela Faculdade de Tecnologia de São Paulo - Matão (FATEC-SP), '
                      'com o objetivo de conectar cidadãos e autoridades para a solução de problemas urbanos.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        children: [
          Text(
            'Nossa Equipe',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.azul,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Conheça os profissionais dedicados ao desenvolvimento e manutenção da plataforma Cidade Integra.',
            style: TextStyle(fontSize: 14, color: AppColors.textoSecundario),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: AppColors.verde,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          ...students.map((member) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: StudentCard(member: member),
              )),
        ],
      ),
    );
  }
}

class _MissionSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final missions = [
      _MissionData(
        icon: Icons.link,
        title: 'Conectar',
        description: 'Criar uma ponte eficiente entre cidadãos e órgãos responsáveis.',
      ),
      _MissionData(
        icon: Icons.handshake,
        title: 'Facilitar',
        description: 'Simplificar o processo de denúncia e acompanhamento de problemas urbanos.',
      ),
      _MissionData(
        icon: Icons.bolt,
        title: 'Transformar',
        description: 'Impactar positivamente a qualidade de vida nas cidades através da tecnologia.',
      ),
    ];

    return Container(
      color: AppColors.azul,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        children: [
          const Text(
            'Nossa Missão',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: AppColors.verde,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 28),
          ...missions.map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.verde.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(m.icon, size: 28, color: AppColors.verde),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        m.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.verde,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        m.description,
                        style: TextStyle(fontSize: 14, color: AppColors.cinza, height: 1.4),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

class _CommitmentSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.verde.withValues(alpha: 0.15),
              AppColors.verde.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              'Nosso Compromisso',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.azul,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Estamos comprometidos com a transparência, acessibilidade e eficiência na resolução '
              'de problemas urbanos. O Cidade Integra é mais que um projeto acadêmico — é uma iniciativa '
              'que busca melhorar a qualidade de vida nas cidades através da tecnologia e participação cidadã.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textoSecundario,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _MissionData {
  final IconData icon;
  final String title;
  final String description;
  const _MissionData({required this.icon, required this.title, required this.description});
}
