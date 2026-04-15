import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cidade_integra/widgets/denuncias/status_badge.dart';
import 'package:cidade_integra/models/report.dart';

void main() {
  Widget wrap(Widget child) =>
      MaterialApp(home: Scaffold(body: child));

  group('StatusBadge', () {
    testWidgets('shows "Pendente" for pending status', (tester) async {
      await tester.pumpWidget(wrap(const StatusBadge(status: ReportStatus.pending)));
      expect(find.text('Pendente'), findsOneWidget);
    });

    testWidgets('shows "Em Análise" for review status', (tester) async {
      await tester.pumpWidget(wrap(const StatusBadge(status: ReportStatus.review)));
      expect(find.text('Em Análise'), findsOneWidget);
    });

    testWidgets('shows "Resolvida" for resolved status', (tester) async {
      await tester.pumpWidget(wrap(const StatusBadge(status: ReportStatus.resolved)));
      expect(find.text('Resolvida'), findsOneWidget);
    });

    testWidgets('shows "Rejeitada" for rejected status', (tester) async {
      await tester.pumpWidget(wrap(const StatusBadge(status: ReportStatus.rejected)));
      expect(find.text('Rejeitada'), findsOneWidget);
    });
  });
}
