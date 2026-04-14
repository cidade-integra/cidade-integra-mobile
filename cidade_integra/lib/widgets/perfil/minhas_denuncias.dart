import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/report.dart';
import '../../services/report_service.dart';
import '../../services/saved_reports_service.dart';
import '../../utils/app_theme.dart';
import '../denuncias/card_denuncia.dart';

class MinhasDenuncias extends StatefulWidget {
  final String userId;
  const MinhasDenuncias({super.key, required this.userId});

  @override
  State<MinhasDenuncias> createState() => _MinhasDenunciasState();
}

class _MinhasDenunciasState extends State<MinhasDenuncias>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.branco,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.bordas),
            ),
            child: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  labelColor: AppColors.verde,
                  unselectedLabelColor: AppColors.textoSecundario,
                  indicatorColor: AppColors.verde,
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  tabs: const [
                    Tab(text: 'Minhas Denúncias'),
                    Tab(text: 'Salvas'),
                  ],
                ),
                const SizedBox(height: 8),
                _tabController.index == 0
                    ? _MyReportsList(userId: widget.userId)
                    : _SavedReportsList(userId: widget.userId),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MyReportsList extends StatelessWidget {
  final String userId;
  const _MyReportsList({required this.userId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Report>>(
      future: ReportService().getReportsByUser(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final reports = snapshot.data ?? [];
        if (reports.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.campaign_outlined,
                      size: 40, color: AppColors.textoSecundario),
                  const SizedBox(height: 8),
                  Text(
                    'Você ainda não fez nenhuma denúncia.',
                    style: TextStyle(color: AppColors.textoSecundario),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: reports
              .map((r) => CardDenuncia(
                    report: r,
                    onTap: () => context.go('/denuncias/${r.id}'),
                  ))
              .toList(),
        );
      },
    );
  }
}

class _SavedReportsList extends StatelessWidget {
  final String userId;
  const _SavedReportsList({required this.userId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Report>>(
      future: SavedReportsService().getSavedReports(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final reports = snapshot.data ?? [];
        if (reports.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.bookmark_outline,
                      size: 40, color: AppColors.textoSecundario),
                  const SizedBox(height: 8),
                  Text(
                    'Nenhuma denúncia salva.',
                    style: TextStyle(color: AppColors.textoSecundario),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: reports
              .map((r) => CardDenuncia(
                    report: r,
                    onTap: () => context.go('/denuncias/${r.id}'),
                  ))
              .toList(),
        );
      },
    );
  }
}
