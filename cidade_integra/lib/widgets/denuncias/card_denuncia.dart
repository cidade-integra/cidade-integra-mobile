import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/report.dart';
import '../../utils/app_theme.dart';
import '../../utils/input_sanitizer.dart';
import 'status_badge.dart';

class CardDenuncia extends StatelessWidget {
  final Report report;
  final VoidCallback onTap;

  const CardDenuncia({super.key, required this.report, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Semantics(
          label: '${report.title}, ${report.category.label}, ${report.status.label}',
          button: true,
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (report.imageUrls.isNotEmpty &&
                InputSanitizer.validateImageUrl(report.imageUrls.first) != null)
              SizedBox(
                height: 160,
                width: double.infinity,
                child: Image.network(
                  report.imageUrls.first,
                  fit: BoxFit.cover,
                  semanticLabel: 'Foto da denúncia: ${report.title}',
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
                    ),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          report.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.azul,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      StatusBadge(status: report.status),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (report.description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        report.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textoSecundario,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _InfoChip(
                        icon: Icon(report.category.icon, size: 14),
                        label: report.category.label,
                      ),
                      if (report.location.address.isNotEmpty)
                        _InfoChip(
                          icon: const Icon(Icons.location_on_outlined, size: 14),
                          label: report.location.address.length > 30
                              ? '${report.location.address.substring(0, 30)}...'
                              : report.location.address,
                        ),
                      _InfoChip(
                        icon: const Icon(Icons.calendar_today_outlined, size: 14),
                        label: DateFormat('dd/MM/yyyy').format(report.createdAt),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final Widget icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconTheme(
          data: IconThemeData(color: AppColors.textoSecundario, size: 14),
          child: icon,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: AppColors.textoSecundario),
        ),
      ],
    );
  }
}
