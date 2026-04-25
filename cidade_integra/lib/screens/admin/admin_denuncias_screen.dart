import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/report.dart';
import '../../providers/auth_provider.dart';
import '../../services/admin_service.dart';
import '../../services/report_service.dart';
import '../../utils/rate_limiter.dart';
import '../../utils/app_theme.dart';
import '../../services/export_service.dart';
import '../../widgets/denuncias/status_badge.dart';

class AdminDenunciasScreen extends StatefulWidget {
  const AdminDenunciasScreen({super.key});

  @override
  State<AdminDenunciasScreen> createState() => _AdminDenunciasScreenState();
}

class _AdminDenunciasScreenState extends State<AdminDenunciasScreen> {
  final _reportService = ReportService();
  final _adminService = AdminService();
  final _searchController = TextEditingController();
  final _debouncer = Debouncer();

  List<Report> _allReports = [];
  bool _loading = true;
  String _searchQuery = '';
  String? _statusFilter;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final reports = await _reportService.getReports();
      if (mounted) setState(() { _allReports = reports; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Report> get _filtered {
    var list = _allReports;
    if (_statusFilter != null) {
      list = list.where((r) => r.status.name == _statusFilter).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((r) => r.title.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  void _showChangeStatusDialog(Report report) {
    final commentController = TextEditingController();
    String? selectedStatus;
    String commentText = '';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Alterar Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                report.title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.azul,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Novo Status'),
                items: ReportStatus.values
                    .map((s) => DropdownMenuItem(
                          value: s.name,
                          child: Text(s.label),
                        ))
                    .toList(),
                onChanged: (v) => setDialogState(() => selectedStatus = v),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: commentController,
                maxLines: 3,
                onChanged: (v) => setDialogState(() => commentText = v),
                decoration: const InputDecoration(
                  labelText: 'Comentário *',
                  hintText: 'Motivo da alteração...',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: selectedStatus != null &&
                      commentText.trim().isNotEmpty
                  ? () async {
                      Navigator.pop(ctx);
                      final auth = context.read<AuthProvider>();
                      await _adminService.updateReportStatusWithAudit(
                        reportId: report.id,
                        newStatus: selectedStatus!,
                        comment: commentText.trim(),
                        userId: auth.user!.uid,
                        userName: auth.user!.displayName ?? 'Admin',
                      );
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Status atualizado.')),
                        );
                        _load();
                      }
                    }
                  : null,
              child: const Text('Confirmar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          color: AppColors.azul,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                tooltip: 'Voltar',
                onPressed: () => context.go('/admin'),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Gestão de Denúncias',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.file_download, color: Colors.white),
                tooltip: 'Exportar CSV',
                onPressed: _allReports.isEmpty
                    ? null
                    : () async {
                        await ExportService().exportReportsCSV(_allReports);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('CSV exportado.')),
                          );
                        }
                      },
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: _searchController,
            onChanged: (v) => _debouncer.call(() {
              if (mounted) setState(() => _searchQuery = v);
            }),
            decoration: InputDecoration(
              hintText: 'Buscar por título...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Todas'),
                  selected: _statusFilter == null,
                  onSelected: (_) => setState(() => _statusFilter = null),
                  selectedColor: AppColors.verde.withValues(alpha: 0.15),
                ),
                const SizedBox(width: 6),
                for (final s in ReportStatus.values) ...[
                  FilterChip(
                    label: Text(s.label),
                    selected: _statusFilter == s.name,
                    onSelected: (_) =>
                        setState(() => _statusFilter = s.name),
                    selectedColor: s.color.withValues(alpha: 0.15),
                  ),
                  const SizedBox(width: 6),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),

        if (_loading)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_filtered.isEmpty)
          Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Text(
                'Nenhuma denúncia encontrada.',
                style: TextStyle(color: AppColors.textoSecundario),
              ),
            ),
          )
        else
          ...List.generate(_filtered.length, (i) {
            final r = _filtered[i];
            return ListTile(
              title: Text(
                r.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.azul,
                ),
              ),
              subtitle: Text(
                '${r.category.label} · ${dateFormat.format(r.createdAt)}',
                style: TextStyle(fontSize: 12, color: AppColors.textoSecundario),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StatusBadge(status: r.status),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    tooltip: 'Alterar Status',
                    onPressed: () => _showChangeStatusDialog(r),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }
}
