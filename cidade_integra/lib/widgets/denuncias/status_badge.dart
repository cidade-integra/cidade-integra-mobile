import 'package:flutter/material.dart';
import '../../models/report.dart';

class StatusBadge extends StatelessWidget {
  final ReportStatus status;
  const StatusBadge({super.key, required this.status});

  static const _config = {
    ReportStatus.pending: ('Pendente', Color(0xFFF39C12), Color(0xFFFFF3CD)),
    ReportStatus.review: ('Em Análise', Color(0xFF3498DB), Color(0xFFD6EAF8)),
    ReportStatus.resolved: ('Resolvida', Color(0xFF2ECC71), Color(0xFFD5F5E3)),
    ReportStatus.rejected: ('Rejeitada', Color(0xFFE74C3C), Color(0xFFFADCD5)),
  };

  @override
  Widget build(BuildContext context) {
    final (label, textColor, bgColor) = _config[status]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
