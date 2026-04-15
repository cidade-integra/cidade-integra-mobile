import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cidade_integra/widgets/denuncias/card_denuncia.dart';
import 'package:cidade_integra/models/report.dart';

void main() {
  final mockReport = Report(
    id: 'test-1',
    title: 'Buraco na calçada',
    description: 'Um buraco grande na calçada da rua principal.',
    category: ReportCategory.buracos,
    isAnonymous: false,
    userId: 'user-1',
    location: const ReportLocation(address: 'Rua das Flores, 123'),
    status: ReportStatus.pending,
    createdAt: DateTime(2025, 1, 15),
    updatedAt: DateTime(2025, 1, 15),
  );

  Widget wrap(Widget child) =>
      MaterialApp(home: Scaffold(body: SingleChildScrollView(child: child)));

  group('CardDenuncia', () {
    testWidgets('shows report title', (tester) async {
      await tester.pumpWidget(wrap(CardDenuncia(
        report: mockReport,
        onTap: () {},
      )));
      expect(find.text('Buraco na calçada'), findsOneWidget);
    });

    testWidgets('shows category label', (tester) async {
      await tester.pumpWidget(wrap(CardDenuncia(
        report: mockReport,
        onTap: () {},
      )));
      expect(find.text('Buracos'), findsOneWidget);
    });

    testWidgets('shows status badge', (tester) async {
      await tester.pumpWidget(wrap(CardDenuncia(
        report: mockReport,
        onTap: () {},
      )));
      expect(find.text('Pendente'), findsOneWidget);
    });

    testWidgets('shows formatted date', (tester) async {
      await tester.pumpWidget(wrap(CardDenuncia(
        report: mockReport,
        onTap: () {},
      )));
      expect(find.text('15/01/2025'), findsOneWidget);
    });

    testWidgets('triggers onTap callback', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(wrap(CardDenuncia(
        report: mockReport,
        onTap: () => tapped = true,
      )));
      await tester.tap(find.text('Buraco na calçada'));
      expect(tapped, isTrue);
    });
  });
}
