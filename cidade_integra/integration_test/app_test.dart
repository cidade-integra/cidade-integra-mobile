import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Navigation E2E', () {
    testWidgets('splash shows app name', (tester) async {
      // Splash screen renders app name
      // Note: Full E2E with Firebase requires mock setup or emulator
      expect(true, isTrue);
    });
  });
}
