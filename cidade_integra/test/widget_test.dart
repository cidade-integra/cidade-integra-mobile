import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cidade_integra/main.dart';

void main() {
  testWidgets('App renders Cidade Integra text', (WidgetTester tester) async {
    await tester.pumpWidget(const CidadeIntegraApp());
    expect(find.text('Cidade Integra'), findsOneWidget);
  });
}
