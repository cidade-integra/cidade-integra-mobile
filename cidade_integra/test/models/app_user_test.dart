import 'package:flutter_test/flutter_test.dart';
import 'package:cidade_integra/models/app_user.dart';

void main() {
  final baseUser = AppUser(
    uid: 'test-uid',
    displayName: 'Test User',
    email: 'test@test.com',
    createdAt: '2025-01-01',
    lastLoginAt: '2025-06-01',
    role: 'user',
    score: 50,
    reportCount: 3,
  );

  group('AppUser', () {
    test('isAdmin returns false for regular user', () {
      expect(baseUser.isAdmin, isFalse);
    });

    test('isAdmin returns true for admin role', () {
      final admin = baseUser.copyWith(displayName: 'Admin');
      final adminUser = AppUser(
        uid: 'admin-uid',
        displayName: 'Admin',
        email: 'admin@test.com',
        createdAt: '2025-01-01',
        lastLoginAt: '2025-01-01',
        role: 'admin',
      );
      expect(adminUser.isAdmin, isTrue);
      expect(admin.isAdmin, isFalse);
    });

    test('copyWith preserves unchanged fields', () {
      final updated = baseUser.copyWith(bio: 'Hello');
      expect(updated.uid, baseUser.uid);
      expect(updated.email, baseUser.email);
      expect(updated.displayName, baseUser.displayName);
      expect(updated.bio, 'Hello');
    });

    test('copyWith overrides specified fields', () {
      final updated = baseUser.copyWith(
        displayName: 'New Name',
        score: 100,
        region: 'SP',
      );
      expect(updated.displayName, 'New Name');
      expect(updated.score, 100);
      expect(updated.region, 'SP');
    });
  });
}
