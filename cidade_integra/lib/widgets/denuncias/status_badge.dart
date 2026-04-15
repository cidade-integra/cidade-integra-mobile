import 'package:flutter/material.dart';
import '../../models/report.dart';

class StatusBadge extends StatelessWidget {
  final ReportStatus status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Status: ${status.label}',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: status.backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          status.label,
          style: TextStyle(
            color: status.color,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
