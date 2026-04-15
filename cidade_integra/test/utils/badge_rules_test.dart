import 'package:flutter_test/flutter_test.dart';
import 'package:cidade_integra/models/app_user.dart';
import 'package:cidade_integra/utils/badge_rules.dart';

void main() {
  AppUser _makeUser({int score = 0, int reportCount = 0, bool verified = false}) {
    return AppUser(
      uid: 'test',
      displayName: 'Test',
      email: 'test@test.com',
      createdAt: '2025-01-01',
      lastLoginAt: '2025-01-01',
      score: score,
      reportCount: reportCount,
      verified: verified,
    );
  }

  group('Badge Rules', () {
    test('new user gets Iniciante badge', () {
      final badges = getUserBadges(_makeUser(score: 0));
      expect(badges.any((b) => b.id == 'iniciante'), isTrue);
    });

    test('user with score 150 gets Engajado badge', () {
      final badges = getUserBadges(_makeUser(score: 150));
      expect(badges.any((b) => b.id == 'engajado'), isTrue);
      expect(badges.any((b) => b.id == 'iniciante'), isFalse);
    });

    test('user with score 500+ gets Vigilante badge', () {
      final badges = getUserBadges(_makeUser(score: 600));
      expect(badges.any((b) => b.id == 'vigilante'), isTrue);
    });

    test('user with 20+ reports gets Reportador badge', () {
      final badges = getUserBadges(_makeUser(reportCount: 25));
      expect(badges.any((b) => b.id == 'reportador_frequente'), isTrue);
    });

    test('verified user gets Verificado badge', () {
      final badges = getUserBadges(_makeUser(verified: true));
      expect(badges.any((b) => b.id == 'verificado'), isTrue);
    });

    test('user with 19 reports does NOT get Reportador', () {
      final badges = getUserBadges(_makeUser(reportCount: 19));
      expect(badges.any((b) => b.id == 'reportador_frequente'), isFalse);
    });
  });
}
