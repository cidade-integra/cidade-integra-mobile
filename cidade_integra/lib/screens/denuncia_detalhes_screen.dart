import 'package:flutter/material.dart';

class DenunciaDetalhesScreen extends StatelessWidget {
  final String reportId;
  const DenunciaDetalhesScreen({super.key, required this.reportId});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Detalhes da Denúncia: $reportId', style: const TextStyle(fontSize: 24)),
    );
  }
}
