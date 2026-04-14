import 'package:flutter/material.dart';
import '../../models/report.dart';
import '../../utils/app_theme.dart';

class StatusFlow extends StatelessWidget {
  final ReportStatus currentStatus;
  const StatusFlow({super.key, required this.currentStatus});

  @override
  Widget build(BuildContext context) {
    final isRejected = currentStatus == ReportStatus.rejected;

    final steps = [
      _Step(ReportStatus.pending, 'Pendente', Icons.hourglass_empty),
      _Step(ReportStatus.review, 'Em Análise', Icons.search),
      _Step(
        ReportStatus.resolved,
        isRejected ? 'Rejeitada' : 'Resolvida',
        isRejected ? Icons.close : Icons.check_circle,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.branco,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.bordas),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status da Denúncia',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.azul,
            ),
          ),
          const SizedBox(height: 20),
          ...List.generate(steps.length, (i) {
            final step = steps[i];
            final state = _getStepState(step.status, currentStatus, isRejected);
            final isLast = i == steps.length - 1;

            return _StepRow(
              step: step,
              state: state,
              isRejected: isRejected && isLast,
              showLine: !isLast,
            );
          }),
        ],
      ),
    );
  }

  _StepState _getStepState(
    ReportStatus step,
    ReportStatus current,
    bool isRejected,
  ) {
    if (isRejected) {
      if (step == ReportStatus.resolved) return _StepState.rejected;
      return _StepState.completed;
    }
    if (current.index > step.index) return _StepState.completed;
    if (current == step) return _StepState.current;
    return _StepState.upcoming;
  }
}

enum _StepState { completed, current, upcoming, rejected }

class _Step {
  final ReportStatus status;
  final String label;
  final IconData icon;
  const _Step(this.status, this.label, this.icon);
}

class _StepRow extends StatelessWidget {
  final _Step step;
  final _StepState state;
  final bool isRejected;
  final bool showLine;

  const _StepRow({
    required this.step,
    required this.state,
    required this.isRejected,
    required this.showLine,
  });

  @override
  Widget build(BuildContext context) {
    final color = switch (state) {
      _StepState.completed => AppColors.verde,
      _StepState.current => AppColors.verde,
      _StepState.rejected => AppColors.vermelho,
      _StepState.upcoming => AppColors.cinza,
    };

    final subtext = switch (state) {
      _StepState.current => 'Status atual',
      _StepState.completed => 'Concluído',
      _StepState.rejected => 'Denúncia rejeitada',
      _StepState.upcoming => '',
    };

    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: state == _StepState.upcoming
                    ? Colors.grey.shade200
                    : color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                step.icon,
                size: 18,
                color: state == _StepState.upcoming
                    ? Colors.grey.shade400
                    : color,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: state == _StepState.upcoming
                          ? AppColors.textoSecundario
                          : AppColors.azul,
                    ),
                  ),
                  if (subtext.isNotEmpty)
                    Text(
                      subtext,
                      style: TextStyle(
                        fontSize: 12,
                        color: isRejected
                            ? AppColors.vermelho
                            : AppColors.textoSecundario,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        if (showLine)
          Padding(
            padding: const EdgeInsets.only(left: 17),
            child: Container(
              width: 2,
              height: 24,
              color: state == _StepState.upcoming
                  ? Colors.grey.shade200
                  : color.withValues(alpha: 0.3),
            ),
          ),
      ],
    );
  }
}
