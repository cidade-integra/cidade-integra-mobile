import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/report.dart';
import '../services/report_service.dart';
import '../utils/app_theme.dart';
import '../widgets/denuncias/status_badge.dart';

class DenunciaDetalhesScreen extends StatelessWidget {
  final String reportId;
  const DenunciaDetalhesScreen({super.key, required this.reportId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Report?>(
      future: ReportService().getReportById(reportId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _ErrorState(onRetry: () => context.go('/denuncias/$reportId'));
        }

        final report = snapshot.data;
        if (report == null) {
          return _NotFoundState();
        }

        return _DetailContent(report: report);
      },
    );
  }
}

class _DetailContent extends StatelessWidget {
  final Report report;
  const _DetailContent({required this.report});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat("dd 'de' MMMM 'de' yyyy", 'pt_BR');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header azul
        Container(
          width: double.infinity,
          color: AppColors.azul,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => context.go('/denuncias'),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_back, size: 16, color: Colors.white.withValues(alpha: 0.8)),
                    const SizedBox(width: 6),
                    Text(
                      'Voltar para denúncias',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                report.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              StatusBadge(status: report.status),
            ],
          ),
        ),

        // Galeria de imagens
        if (report.imageUrls.isNotEmpty) _ImageGallery(urls: report.imageUrls),

        // Descrição
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle(title: 'Descrição'),
              const SizedBox(height: 8),
              Text(
                report.description,
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.preto,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),

        const Divider(height: 1),

        // Informações
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle(title: 'Informações'),
              const SizedBox(height: 12),
              _InfoRow(
                icon: Icons.category_outlined,
                label: 'Categoria',
                value: report.category.label,
              ),
              _InfoRow(
                icon: Icons.location_on_outlined,
                label: 'Localização',
                value: report.location.address.isNotEmpty
                    ? report.location.address
                    : '—',
              ),
              _InfoRow(
                icon: Icons.calendar_today_outlined,
                label: 'Data de Registro',
                value: dateFormat.format(report.createdAt),
              ),
              _InfoRow(
                icon: Icons.person_outline,
                label: 'Reportado por',
                value: report.isAnonymous ? 'Anônimo' : 'Cidadão',
              ),
              if (report.resolvedAt != null)
                _InfoRow(
                  icon: Icons.check_circle_outline,
                  label: 'Resolvida em',
                  value: dateFormat.format(report.resolvedAt!),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ImageGallery extends StatefulWidget {
  final List<String> urls;
  const _ImageGallery({required this.urls});

  @override
  State<_ImageGallery> createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<_ImageGallery> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 240,
          child: PageView.builder(
            itemCount: widget.urls.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (_, i) => Image.network(
              widget.urls[i],
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey.shade200,
                child: const Center(
                  child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
                ),
              ),
            ),
          ),
        ),
        if (widget.urls.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.urls.length,
                (i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _current == i ? 10 : 7,
                  height: _current == i ? 10 : 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _current == i ? AppColors.verde : AppColors.cinza,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.azul,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.textoSecundario),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textoSecundario,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.azul,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotFoundState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 64, color: AppColors.textoSecundario),
            const SizedBox(height: 16),
            Text(
              'Denúncia não encontrada',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.azul,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'A denúncia que você procura não existe ou foi removida.',
              style: TextStyle(color: AppColors.textoSecundario),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => context.go('/denuncias'),
              icon: const Icon(Icons.arrow_back, size: 18),
              label: const Text('Voltar para Denúncias'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48, color: AppColors.vermelho),
          const SizedBox(height: 12),
          Text('Erro ao carregar denúncia.',
              style: TextStyle(color: AppColors.textoSecundario)),
          const SizedBox(height: 16),
          OutlinedButton(onPressed: onRetry, child: const Text('Tentar novamente')),
        ],
      ),
    );
  }
}
