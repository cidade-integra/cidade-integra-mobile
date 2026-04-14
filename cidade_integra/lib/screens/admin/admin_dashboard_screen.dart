import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../models/report.dart';
import '../../services/admin_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/denuncias/status_badge.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _service = AdminService();
  Map<String, int>? _stats;
  int _totalUsers = 0;
  List<Report> _recent = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        _service.getReportStats(),
        _service.getTotalUsers(),
        _service.getRecentReports(),
      ]);
      if (mounted) {
        setState(() {
          _stats = results[0] as Map<String, int>;
          _totalUsers = results[1] as int;
          _recent = results[2] as List<Report>;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        _buildStatCards(),
        if (_stats != null) _buildChart(),
        _buildNavCards(),
        if (_recent.isNotEmpty) _buildRecentList(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      color: AppColors.azul,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Painel Administrativo',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Visão geral do sistema',
            style: TextStyle(fontSize: 14, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCards() {
    final s = _stats ?? {};
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.5,
        children: [
          _StatCard(
            title: 'Total',
            value: '${s['total'] ?? 0}',
            icon: Icons.campaign,
            color: AppColors.azul,
          ),
          _StatCard(
            title: 'Pendentes',
            value: '${s['pending'] ?? 0}',
            icon: Icons.hourglass_empty,
            color: const Color(0xFFF39C12),
          ),
          _StatCard(
            title: 'Em Análise',
            value: '${s['review'] ?? 0}',
            icon: Icons.search,
            color: const Color(0xFF3498DB),
          ),
          _StatCard(
            title: 'Resolvidas',
            value: '${s['resolved'] ?? 0}',
            icon: Icons.check_circle,
            color: const Color(0xFF2ECC71),
          ),
          _StatCard(
            title: 'Rejeitadas',
            value: '${s['rejected'] ?? 0}',
            icon: Icons.cancel,
            color: const Color(0xFFE74C3C),
          ),
          _StatCard(
            title: 'Usuários',
            value: '$_totalUsers',
            icon: Icons.people,
            color: const Color(0xFF9B59B6),
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    final s = _stats!;
    final total = s['total'] ?? 0;
    if (total == 0) return const SizedBox.shrink();

    final bars = [
      ('Pendentes', s['pending'] ?? 0, const Color(0xFFF39C12)),
      ('Em Análise', s['review'] ?? 0, const Color(0xFF3498DB)),
      ('Resolvidas', s['resolved'] ?? 0, const Color(0xFF2ECC71)),
      ('Rejeitadas', s['rejected'] ?? 0, const Color(0xFFE74C3C)),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
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
              'Distribuição por Status',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.azul,
              ),
            ),
            const SizedBox(height: 16),
            ...bars.map((bar) {
              final (label, value, color) = bar;
              final pct = total > 0 ? value / total : 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(label, style: TextStyle(fontSize: 13, color: AppColors.azul)),
                        Text('$value (${(pct * 100).toStringAsFixed(0)}%)',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 8,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation(color),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildNavCards() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _NavCard(
              icon: Icons.list_alt,
              label: 'Gestão de\nDenúncias',
              onTap: () => context.go('/admin/denuncias'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _NavCard(
              icon: Icons.people_outline,
              label: 'Gestão de\nUsuários',
              onTap: () => context.go('/admin/usuarios'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentList() {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.branco,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.bordas),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Denúncias Recentes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.azul,
                ),
              ),
            ),
            const Divider(height: 1),
            ...List.generate(_recent.length, (i) {
              final r = _recent[i];
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
                  dateFormat.format(r.createdAt),
                  style: TextStyle(fontSize: 12, color: AppColors.textoSecundario),
                ),
                trailing: StatusBadge(status: r.status),
                onTap: () => context.go('/denuncias/${r.id}'),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 11, color: AppColors.textoSecundario),
          ),
        ],
      ),
    );
  }
}

class _NavCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _NavCard({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.branco,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.bordas),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: AppColors.verde),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.azul,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
