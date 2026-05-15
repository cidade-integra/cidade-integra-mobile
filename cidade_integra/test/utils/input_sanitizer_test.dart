import 'package:flutter_test/flutter_test.dart';
import 'package:cidade_integra/utils/input_sanitizer.dart';

void main() {
  group('InputSanitizer.sanitize', () {
    test('removes HTML tags', () {
      expect(InputSanitizer.sanitize('<b>bold</b>'), 'bold');
      expect(InputSanitizer.sanitize('<script>alert(1)</script>'), 'alert(1)');
    });

    test('removes script patterns', () {
      expect(InputSanitizer.sanitize('onclick=steal()'), 'steal()');
      expect(InputSanitizer.sanitize('javascript:alert(1)'), 'alert(1)');
    });

    test('normalizes whitespace', () {
      expect(InputSanitizer.sanitize('  hello   world  '), 'hello world');
    });

    test('removes control characters', () {
      expect(InputSanitizer.sanitize('hello\x00world'), 'helloworld');
    });
  });

  group('InputSanitizer.isValidEmail', () {
    test('accepts valid emails', () {
      expect(InputSanitizer.isValidEmail('user@example.com'), isTrue);
      expect(InputSanitizer.isValidEmail('a.b+c@test.co.uk'), isTrue);
    });

    test('rejects invalid emails', () {
      expect(InputSanitizer.isValidEmail(''), isFalse);
      expect(InputSanitizer.isValidEmail('user@'), isFalse);
      expect(InputSanitizer.isValidEmail('@domain.com'), isFalse);
      expect(InputSanitizer.isValidEmail('no-at-sign'), isFalse);
    });
  });

  group('InputSanitizer.isValidCep', () {
    test('accepts valid CEPs', () {
      expect(InputSanitizer.isValidCep('14500-000'), isTrue);
      expect(InputSanitizer.isValidCep('14500000'), isTrue);
    });

    test('rejects invalid CEPs', () {
      expect(InputSanitizer.isValidCep('123'), isFalse);
      expect(InputSanitizer.isValidCep('abcde-fgh'), isFalse);
    });
  });

  group('InputSanitizer.containsBlockedWords', () {
    test('detects blocked words', () {
      expect(InputSanitizer.containsBlockedWords('seu idiota'), isTrue);
    });

    test('passes clean text', () {
      expect(InputSanitizer.containsBlockedWords('boa tarde'), isFalse);
    });
  });

  group('InputSanitizer.validateImageUrl', () {
    test('allows Supabase URLs', () {
      const url =
          'https://fyjefwpyesgedvfuewiw.supabase.co/storage/v1/object/public/reports/img.jpg';
      expect(InputSanitizer.validateImageUrl(url), url);
    });

    test('rejects unknown hosts', () {
      expect(
        InputSanitizer.validateImageUrl('https://evil.com/img.jpg'),
        isNull,
      );
    });

    test('rejects malformed URLs', () {
      expect(InputSanitizer.validateImageUrl('not-a-url'), isNull);
    });
  });

  group('InputSanitizer.validateEmail', () {
    test('returns error for empty', () {
      expect(InputSanitizer.validateEmail(''), isNotNull);
      expect(InputSanitizer.validateEmail(null), isNotNull);
    });

    test('returns null for valid', () {
      expect(InputSanitizer.validateEmail('user@test.com'), isNull);
    });
  });

  group('InputSanitizer.validateName', () {
    test('rejects short names', () {
      expect(InputSanitizer.validateName('AB'), isNotNull);
    });

    test('rejects names with numbers', () {
      expect(InputSanitizer.validateName('User123'), isNotNull);
    });

    test('accepts valid names', () {
      expect(InputSanitizer.validateName('Rafael Romano'), isNull);
      expect(InputSanitizer.validateName('José María'), isNull);
    });
  });

  group('InputSanitizer.validateText', () {
    test('enforces min length', () {
      expect(
        InputSanitizer.validateText('ab', fieldName: 'campo', min: 3),
        isNotNull,
      );
    });

    test('detects blocked words when enabled', () {
      expect(
        InputSanitizer.validateText(
          'seu idiota',
          fieldName: 'campo',
          checkBlocked: true,
        ),
        contains('inadequadas'),
      );
    });

    test('passes clean text', () {
      expect(
        InputSanitizer.validateText('texto válido', fieldName: 'campo', min: 3),
        isNull,
      );
    });
  });
}
