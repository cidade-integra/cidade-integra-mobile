import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/report.dart';
import '../providers/auth_provider.dart';
import '../services/report_service.dart';
import '../services/analytics_service.dart';
import '../services/saved_reports_service.dart';
import '../utils/app_theme.dart';
import '../widgets/denuncias/comment_section.dart';
import '../widgets/denuncias/mapa_denuncia.dart';
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
        if (report == null) return _NotFoundState();

        return _DetailContent(report: report);
      },
    );
  }
}

class _DetailContent extends StatefulWidget {
  final Report report;
  const _DetailContent({required this.report});

  @override
  State<_DetailContent> createState() => _DetailContentState();
}

class _DetailContentState extends State<_DetailContent> {
  final _savedService = SavedReportsService();
  bool _isSaved = false;
  bool _checkingSaved = true;

  @override
  void initState() {
    super.initState();
    _checkSaved();
  }

  Future<void> _checkSaved() async {
    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn) {
      if (mounted) setState(() => _checkingSaved = false);
      return;
    }
    try {
      final saved = await _savedService.isSaved(auth.user!.uid, widget.report.id);
      if (mounted) setState(() { _isSaved = saved; _checkingSaved = false; });
    } catch (_) {
      if (mounted) setState(() => _checkingSaved = false);
    }
  }

  Future<void> _toggleSave() async {
    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Faça login para salvar denúncias.')),
      );
      return;
    }

    final uid = auth.user!.uid;
    if (_isSaved) {
      await _savedService.removeReport(uid, widget.report.id);
      if (mounted) {
        setState(() => _isSaved = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Denúncia removida dos salvos.')),
        );
      }
    } else {
      await _savedService.saveReport(uid, widget.report.id);
      await AnalyticsService.logSaveReport(widget.report.id);
      if (mounted) {
        setState(() => _isSaved = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Denúncia salva!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final report = widget.report;
    final dateFormat = DateFormat("dd/MM/yyyy 'às' HH:mm", 'pt_BR');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          width: double.infinity,
          color: AppColors.azul,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => context.go('/denuncias'),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_back, size: 16,
                            color: Colors.white.withValues(alpha: 0.8)),
                        const SizedBox(width: 6),
                        Text('Voltar',
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 13)),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (!_checkingSaved)
                    IconButton(
                      icon: Icon(
                        _isSaved ? Icons.bookmark : Icons.bookmark_border,
                        color: _isSaved ? AppColors.verde : Colors.white,
                      ),
                      tooltip: _isSaved ? 'Remover dos salvos' : 'Salvar',
                      onPressed: _toggleSave,
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                report.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  StatusBadge(status: report.status),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(report.category.icon,
                            size: 14, color: Colors.white70),
                        const SizedBox(width: 4),
                        Text(report.category.label,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.white70)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Imagens
        if (report.imageUrls.isNotEmpty) _ImageGallery(urls: report.imageUrls),

        // Descrição
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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

        // Info cards
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.branco,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.bordas),
            ),
            child: Column(
              children: [
                _InfoItem(
                  icon: Icons.location_on_outlined,
                  label: report.location.address.isNotEmpty
                      ? report.location.address
                      : 'Localização não informada',
                ),
                _InfoItem(
                  icon: Icons.calendar_today_outlined,
                  label: dateFormat.format(report.createdAt),
                ),
                _InfoItem(
                  icon: Icons.person_outline,
                  label: report.isAnonymous
                      ? 'Denúncia anônima'
                      : 'Reportado por cidadão',
                ),
                if (report.resolvedAt != null)
                  _InfoItem(
                    icon: Icons.check_circle_outline,
                    label: 'Resolvida em ${dateFormat.format(report.resolvedAt!)}',
                    color: AppColors.verde,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Mapa
        if (report.location.latitude != null &&
            report.location.longitude != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: MapaDenuncia(
              latitude: report.location.latitude!,
              longitude: report.location.longitude!,
              address: report.location.address,
            ),
          ),

        const SizedBox(height: 8),

        CommentSection(reportId: report.id),
      ],
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _InfoItem({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textoSecundario;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: c),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label,
                style: TextStyle(fontSize: 13, color: c, height: 1.3)),
          ),
        ],
      ),
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
                  child:
                      Icon(Icons.broken_image, size: 48, color: Colors.grey),
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
            Text('Denúncia não encontrada',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.azul)),
            const SizedBox(height: 8),
            Text('A denúncia que você procura não existe ou foi removida.',
                style: TextStyle(color: AppColors.textoSecundario),
                textAlign: TextAlign.center),
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
          OutlinedButton(
              onPressed: onRetry,
              child: const Text('Tentar novamente')),
        ],
      ),
    );
  }
}
