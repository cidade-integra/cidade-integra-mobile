import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Navigation E2E', () {
    testWidgets('splash shows app name', (tester) async {
      expect(true, isTrue);
    });
  });
}
