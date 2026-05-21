import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

/// Mostra de forma transparente como o usuário ganha pontos no app.
///
/// As regras vivem em `lib/services/report_service.dart` e
/// `lib/widgets/denuncias/comment_section.dart`.
class ScoreExplainer extends StatelessWidget {
  const ScoreExplainer({super.key});

  @override
  Widget build(BuildContext context) {
    final earnRules = const [
      _Rule(
        icon: Icons.campaign_outlined,
        label: 'Criar uma denúncia',
        points: '+10',
        positive: true,
      ),
      _Rule(
        icon: Icons.chat_bubble_outline,
        label: 'Comentar em uma denúncia',
        points: '+2',
        positive: true,
      ),
      _Rule(
        icon: Icons.verified_outlined,
        label: 'Ter denúncia resolvida',
        points: '+20',
        positive: true,
      ),
    ];

    final loseRules = const [
      _Rule(
        icon: Icons.visibility_off_outlined,
        label: 'Sua denúncia ser ocultada pela moderação',
        points: '-10',
        positive: false,
      ),
      _Rule(
        icon: Icons.delete_outline,
        label: 'Apagar um comentário próprio',
        points: '-2',
        positive: false,
      ),
      _Rule(
        icon: Icons.cancel_outlined,
        label: 'Denúncia resolvida ser ocultada',
        points: '-20',
        positive: false,
      ),
    ];

    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      leading: Icon(Icons.help_outline, color: AppColors.azul),
      title: Text(
        'Como funciona o score?',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.azul,
        ),
      ),
      children: [
        Text(
          'Você acumula pontos contribuindo com a comunidade. Quanto mais '
          'engajamento, mais badges você desbloqueia.',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textoSecundario,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Você ganha pontos',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.verdeEscuro,
          ),
        ),
        const SizedBox(height: 4),
        ...earnRules.map((r) => _RuleTile(rule: r)),
        const SizedBox(height: 14),
        Text(
          'Você perde pontos',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.vermelho,
          ),
        ),
        const SizedBox(height: 4),
        ...loseRules.map((r) => _RuleTile(rule: r)),
        const SizedBox(height: 12),
        Text(
          'Faixas de badge: Iniciante (0-99) · Engajado (100-499) · '
          'Vigilante Urbano (500+).',
          style: TextStyle(
            fontSize: 12,
            fontStyle: FontStyle.italic,
            color: AppColors.textoSecundario,
          ),
        ),
      ],
    );
  }
}

class _Rule {
  final IconData icon;
  final String label;
  final String points;
  final bool positive;
  const _Rule({
    required this.icon,
    required this.label,
    required this.points,
    required this.positive,
  });
}

class _RuleTile extends StatelessWidget {
  final _Rule rule;
  const _RuleTile({required this.rule});

  @override
  Widget build(BuildContext context) {
    final accent =
        rule.positive ? AppColors.verdeEscuro : AppColors.vermelho;
    final bg = rule.positive
        ? AppColors.verde.withValues(alpha: 0.15)
        : AppColors.vermelho.withValues(alpha: 0.12);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(rule.icon, size: 18, color: accent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              rule.label,
              style: TextStyle(fontSize: 13, color: AppColors.preto),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              rule.points,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
