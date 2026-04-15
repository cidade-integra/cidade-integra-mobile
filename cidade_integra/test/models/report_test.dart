import 'package:flutter_test/flutter_test.dart';
import 'package:cidade_integra/models/report.dart';

void main() {
  group('ReportCategory', () {
    test('label returns correct Portuguese names', () {
      expect(ReportCategory.buracos.label, 'Buracos');
      expect(ReportCategory.iluminacao.label, 'Iluminação');
      expect(ReportCategory.lixo.label, 'Lixo');
      expect(ReportCategory.vazamentos.label, 'Vazamentos');
      expect(ReportCategory.areasVerdes.label, 'Áreas Verdes');
      expect(ReportCategory.outros.label, 'Outros');
    });
  });

  group('ReportStatus', () {
    test('label returns correct Portuguese names', () {
      expect(ReportStatus.pending.label, 'Pendente');
      expect(ReportStatus.review.label, 'Em Análise');
      expect(ReportStatus.resolved.label, 'Resolvida');
      expect(ReportStatus.rejected.label, 'Rejeitada');
    });

    test('color returns non-null values', () {
      for (final s in ReportStatus.values) {
        expect(s.color, isNotNull);
        expect(s.backgroundColor, isNotNull);
      }
    });
  });

  group('ReportLocation', () {
    test('fromMap creates location from map', () {
      final loc = ReportLocation.fromMap({
        'latitude': -22.35,
        'longitude': -48.55,
        'address': 'Rua Test',
        'postalCode': '14500-000',
      });
      expect(loc.latitude, -22.35);
      expect(loc.longitude, -48.55);
      expect(loc.address, 'Rua Test');
      expect(loc.postalCode, '14500-000');
    });

    test('fromMap handles missing fields', () {
      final loc = ReportLocation.fromMap({});
      expect(loc.latitude, isNull);
      expect(loc.address, '');
    });

    test('toMap serializes correctly', () {
      const loc = ReportLocation(
        latitude: -22.35,
        longitude: -48.55,
        address: 'Rua Test',
      );
      final map = loc.toMap();
      expect(map['latitude'], -22.35);
      expect(map['address'], 'Rua Test');
    });
  });

  group('Report', () {
    test('toFirestore serializes all fields', () {
      final report = Report(
        id: 'test-1',
        title: 'Test Report',
        description: 'A test description',
        category: ReportCategory.buracos,
        isAnonymous: false,
        userId: 'user-1',
        location: const ReportLocation(address: 'Rua 1'),
        status: ReportStatus.pending,
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );

      final map = report.toFirestore();
      expect(map['title'], 'Test Report');
      expect(map['category'], 'buracos');
      expect(map['status'], 'pending');
      expect(map['isAnonymous'], false);
      expect(map['userId'], 'user-1');
      expect(map['imagemUrls'], isEmpty);
    });
  });
}
