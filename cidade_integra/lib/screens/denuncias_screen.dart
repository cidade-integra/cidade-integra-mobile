import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/report.dart';
import '../services/report_service.dart';
import '../utils/app_theme.dart';
import '../widgets/denuncias/card_denuncia.dart';

class DenunciasScreen extends StatefulWidget {
  const DenunciasScreen({super.key});

  @override
  State<DenunciasScreen> createState() => _DenunciasScreenState();
}

class _DenunciasScreenState extends State<DenunciasScreen> {
  final _reportService = ReportService();
  final _searchController = TextEditingController();

  List<Report> _allReports = [];
  bool _loading = true;
  String? _error;

  String? _statusFilter;
  String? _categoryFilter;
  String _searchQuery = '';
  int _currentPage = 0;
  static const _pageSize = 6;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadReports() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final reports = await _reportService.getReports();
      if (mounted) {
        setState(() {
          _allReports = reports;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Erro ao carregar denúncias.';
          _loading = false;
        });
      }
    }
  }

  List<Report> get _filteredReports {
    var filtered = _allReports;

    if (_statusFilter != null) {
      filtered = filtered.where((r) => r.status.name == _statusFilter).toList();
    }
    if (_categoryFilter != null) {
      filtered =
          filtered.where((r) => r.category.name == _categoryFilter).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered.where((r) {
        return r.title.toLowerCase().contains(q) ||
            r.description.toLowerCase().contains(q) ||
            r.location.address.toLowerCase().contains(q);
      }).toList();
    }

    return filtered;
  }

  List<Report> get _pagedReports {
    final start = _currentPage * _pageSize;
    if (start >= _filteredReports.length) return [];
    return _filteredReports.skip(start).take(_pageSize).toList();
  }

  int get _totalPages => (_filteredReports.length / _pageSize).ceil();

  void _resetPage() => setState(() => _currentPage = 0);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildSearchBar(),
        _buildFilters(),
        Expanded(child: _buildContent()),
        if (!_loading && _filteredReports.isNotEmpty) _buildPagination(),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.grey.shade50, Colors.white],
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.verde.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.campaign_outlined, size: 32, color: AppColors.verde),
          ),
          const SizedBox(height: 12),
          Text(
            'Denúncias',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.azul,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Acompanhe os problemas reportados pela comunidade.',
            style: TextStyle(fontSize: 14, color: AppColors.textoSecundario),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchController,
        onChanged: (v) {
          setState(() => _searchQuery = v);
          _resetPage();
        },
        decoration: InputDecoration(
          hintText: 'Buscar denúncias...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                    _resetPage();
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(
              label: _statusFilter == null
                  ? 'Status'
                  : _statusLabel(_statusFilter!),
              active: _statusFilter != null,
              onTap: () => _showStatusFilter(),
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: _categoryFilter == null
                  ? 'Categoria'
                  : _categoryLabel(_categoryFilter!),
              active: _categoryFilter != null,
              onTap: () => _showCategoryFilter(),
            ),
            if (_statusFilter != null || _categoryFilter != null) ...[
              const SizedBox(width: 8),
              ActionChip(
                label: const Text('Limpar filtros'),
                avatar: const Icon(Icons.clear, size: 16),
                onPressed: () {
                  setState(() {
                    _statusFilter = null;
                    _categoryFilter = null;
                  });
                  _resetPage();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return FilterChip(
      label: Text(label),
      selected: active,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.verde.withValues(alpha: 0.15),
      checkmarkColor: AppColors.verde,
    );
  }

  void _showStatusFilter() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Todas'),
              leading: const Icon(Icons.list),
              selected: _statusFilter == null,
              onTap: () {
                setState(() => _statusFilter = null);
                _resetPage();
                Navigator.pop(context);
              },
            ),
            for (final s in ReportStatus.values)
              ListTile(
                title: Text(_statusLabel(s.name)),
                selected: _statusFilter == s.name,
                onTap: () {
                  setState(() => _statusFilter = s.name);
                  _resetPage();
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showCategoryFilter() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Todas'),
              leading: const Icon(Icons.list),
              selected: _categoryFilter == null,
              onTap: () {
                setState(() => _categoryFilter = null);
                _resetPage();
                Navigator.pop(context);
              },
            ),
            for (final c in ReportCategory.values)
              ListTile(
                title: Text(c.label),
                leading: Icon(c.icon),
                selected: _categoryFilter == c.name,
                onTap: () {
                  setState(() => _categoryFilter = c.name);
                  _resetPage();
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.vermelho),
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: AppColors.textoSecundario)),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _loadReports,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (_filteredReports.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 48, color: AppColors.textoSecundario),
            const SizedBox(height: 12),
            Text(
              'Nenhuma denúncia encontrada.',
              style: TextStyle(fontSize: 16, color: AppColors.textoSecundario),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadReports,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        itemCount: _pagedReports.length,
        itemBuilder: (context, index) {
          final report = _pagedReports[index];
          return CardDenuncia(
            report: report,
            onTap: () => context.go('/denuncias/${report.id}'),
          );
        },
      ),
    );
  }

  Widget _buildPagination() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.branco,
        border: Border(top: BorderSide(color: AppColors.bordas)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${_filteredReports.length} denúncia(s)',
            style: TextStyle(fontSize: 13, color: AppColors.textoSecundario),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed:
                    _currentPage > 0
                        ? () => setState(() => _currentPage--)
                        : null,
              ),
              Text(
                '${_currentPage + 1} / $_totalPages',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.azul,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed:
                    _currentPage < _totalPages - 1
                        ? () => setState(() => _currentPage++)
                        : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _statusLabel(String status) {
    final s = ReportStatus.values.firstWhere(
      (v) => v.name == status,
      orElse: () => ReportStatus.pending,
    );
    return s.label;
  }

  String _categoryLabel(String category) {
    final cat = ReportCategory.values.firstWhere(
      (c) => c.name == category,
      orElse: () => ReportCategory.outros,
    );
    return cat.label;
  }
}
