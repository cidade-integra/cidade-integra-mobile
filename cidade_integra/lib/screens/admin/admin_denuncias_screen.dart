import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/report.dart';
import '../../providers/auth_provider.dart';
import '../../services/admin_service.dart';
import '../../services/report_service.dart';
import '../../utils/rate_limiter.dart';
import '../../utils/refresh_scope.dart';
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
  bool _showHidden = false;

  @override
  void initState() {
    super.initState();
    RefreshScope.register(_load);
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
      final reports = await _reportService.getReports(includeHidden: true);
      if (mounted)
        setState(() {
          _allReports = reports;
          _loading = false;
        });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Report> get _filtered {
    var list = _allReports.where((r) => r.isHidden == _showHidden).toList();
    if (_statusFilter != null) {
      list = list.where((r) => r.status.name == _statusFilter).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((r) => r.title.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  int get _hiddenCount => _allReports.where((r) => r.isHidden).length;

  Future<void> _confirmHide(Report report) async {
    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ocultar denúncia'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A denúncia "${report.title}" deixará de ser exibida para '
              'usuários, mas continua salva no banco para auditoria e '
              'poderá ser restaurada.',
              style: TextStyle(fontSize: 13, color: AppColors.textoSecundario),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 2,
              maxLength: 200,
              decoration: const InputDecoration(
                labelText: 'Motivo (opcional)',
                hintText: 'Ex.: conteúdo ofensivo, duplicada, spam...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.vermelho,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ocultar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      final auth = context.read<AuthProvider>();
      await _adminService.hideReportWithAudit(
        reportId: report.id,
        adminUid: auth.user!.uid,
        adminName: auth.user!.displayName ?? 'Admin',
        reason: reasonController.text.trim().isEmpty
            ? null
            : reasonController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Denúncia ocultada.')),
        );
        _load();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao ocultar: $e')),
        );
      }
    }
  }

  Future<void> _confirmUnhide(Report report) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restaurar denúncia'),
        content: Text(
          'A denúncia "${report.title}" voltará a aparecer publicamente. '
          'Deseja continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.verde),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      final auth = context.read<AuthProvider>();
      await _adminService.unhideReportWithAudit(
        reportId: report.id,
        adminUid: auth.user!.uid,
        adminName: auth.user!.displayName ?? 'Admin',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Denúncia restaurada.')),
        );
        _load();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao restaurar: $e')),
        );
      }
    }
  }

  void _showChangeStatusDialog(Report report) {
    final commentController = TextEditingController();
    String? selectedStatus;
    String commentText = '';

    showDialog(
      context: context,
      builder:
          (ctx) => StatefulBuilder(
            builder:
                (ctx, setDialogState) => AlertDialog(
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
                        decoration: const InputDecoration(
                          labelText: 'Novo Status',
                        ),
                        items:
                            ReportStatus.values
                                .map(
                                  (s) => DropdownMenuItem(
                                    value: s.name,
                                    child: Text(s.label),
                                  ),
                                )
                                .toList(),
                        onChanged:
                            (v) => setDialogState(() => selectedStatus = v),
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
                      onPressed:
                          selectedStatus != null &&
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
                                    const SnackBar(
                                      content: Text('Status atualizado.'),
                                    ),
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
                onPressed:
                    _allReports.isEmpty
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
            onChanged:
                (v) => _debouncer.call(() {
                  if (mounted) setState(() => _searchQuery = v);
                }),
            decoration: InputDecoration(
              hintText: 'Buscar por título...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon:
                  _searchQuery.isNotEmpty
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
                    onSelected: (_) => setState(() => _statusFilter = s.name),
                    selectedColor: s.color.withValues(alpha: 0.15),
                  ),
                  const SizedBox(width: 6),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              FilterChip(
                avatar: Icon(
                  _showHidden ? Icons.visibility_off : Icons.visibility,
                  size: 16,
                  color: _showHidden ? AppColors.vermelho : AppColors.azul,
                ),
                label: Text(
                  _showHidden
                      ? 'Vendo ocultas ($_hiddenCount)'
                      : 'Ver ocultas ($_hiddenCount)',
                ),
                selected: _showHidden,
                onSelected: (v) => setState(() => _showHidden = v),
                selectedColor: AppColors.vermelho.withValues(alpha: 0.15),
              ),
            ],
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
            return Opacity(
              opacity: r.isHidden ? 0.55 : 1.0,
              child: ListTile(
                title: Row(
                  children: [
                    Flexible(
                      child: Text(
                        r.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.azul,
                          decoration: r.isHidden
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                    if (r.isHidden) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.vermelho.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Oculta',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.vermelho,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                subtitle: Text(
                  '${r.category.label} · ${dateFormat.format(r.createdAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textoSecundario,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    StatusBadge(status: r.status),
                    const SizedBox(width: 4),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, size: 20),
                      tooltip: 'Ações',
                      onSelected: (action) {
                        switch (action) {
                          case 'status':
                            _showChangeStatusDialog(r);
                            break;
                          case 'hide':
                            _confirmHide(r);
                            break;
                          case 'unhide':
                            _confirmUnhide(r);
                            break;
                        }
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                          value: 'status',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 18),
                              SizedBox(width: 8),
                              Text('Alterar Status'),
                            ],
                          ),
                        ),
                        if (r.isHidden)
                          const PopupMenuItem(
                            value: 'unhide',
                            child: Row(
                              children: [
                                Icon(Icons.visibility, size: 18),
                                SizedBox(width: 8),
                                Text('Restaurar'),
                              ],
                            ),
                          )
                        else
                          const PopupMenuItem(
                            value: 'hide',
                            child: Row(
                              children: [
                                Icon(Icons.visibility_off, size: 18),
                                SizedBox(width: 8),
                                Text('Ocultar'),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}
