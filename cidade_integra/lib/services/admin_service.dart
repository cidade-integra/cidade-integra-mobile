import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';
import '../models/report.dart';

class AdminService {
  final _reports = FirebaseFirestore.instance.collection('reports');
  final _users = FirebaseFirestore.instance.collection('users');

  Future<Map<String, int>> getReportStats() async {
    final snapshot = await _reports.get();
    final stats = {
      'total': 0,
      'pending': 0,
      'review': 0,
      'resolved': 0,
      'rejected': 0,
      'hidden': 0,
    };

    for (final doc in snapshot.docs) {
      final data = doc.data();
      if (data['isHidden'] == true) {
        stats['hidden'] = (stats['hidden'] ?? 0) + 1;
        continue;
      }
      stats['total'] = (stats['total'] ?? 0) + 1;
      final status = data['status'] as String? ?? 'pending';
      stats[status] = (stats[status] ?? 0) + 1;
    }
    return stats;
  }

  Future<int> getTotalUsers() async {
    final snapshot = await _users.count().get();
    return snapshot.count ?? 0;
  }

  Future<List<Report>> getRecentReports({int limit = 5}) async {
    final snapshot =
        await _reports
            .orderBy('createdAt', descending: true)
            .limit(limit)
            .get();
    return snapshot.docs.map((doc) => Report.fromFirestore(doc)).toList();
  }

  Future<List<AppUser>> getAllUsers() async {
    final snapshot = await _users.orderBy('createdAt', descending: true).get();
    return snapshot.docs.map((doc) => AppUser.fromFirestore(doc)).toList();
  }

  Future<void> updateUserRole(String uid, String newRole) async {
    await _users.doc(uid).update({'role': newRole});
  }

  /// Admin bane um usuário: status = banned, bloqueia login.
  Future<void> banUser({
    required String uid,
    required String adminUid,
    required String adminName,
    String? reason,
  }) async {
    final batch = FirebaseFirestore.instance.batch();
    batch.update(_users.doc(uid), {
      'status': 'banned',
      'bannedAt': FieldValue.serverTimestamp(),
      'bannedBy': adminUid,
      'bannedReason': reason,
    });
    final auditRef = FirebaseFirestore.instance.collection('auditLogs').doc();
    batch.set(auditRef, {
      'timestamp': FieldValue.serverTimestamp(),
      'userId': adminUid,
      'userDisplayName': adminName,
      'targetUserId': uid,
      'action': 'ban_user',
      'reason': reason,
    });
    await batch.commit();
  }

  /// Admin desbloqueia um usuário banido (status volta a active).
  Future<void> unbanUser({
    required String uid,
    required String adminUid,
    required String adminName,
  }) async {
    final batch = FirebaseFirestore.instance.batch();
    batch.update(_users.doc(uid), {
      'status': 'active',
      'bannedAt': null,
      'bannedBy': null,
      'bannedReason': null,
    });
    final auditRef = FirebaseFirestore.instance.collection('auditLogs').doc();
    batch.set(auditRef, {
      'timestamp': FieldValue.serverTimestamp(),
      'userId': adminUid,
      'userDisplayName': adminName,
      'targetUserId': uid,
      'action': 'unban_user',
    });
    await batch.commit();
  }

  Future<void> updateReportStatusWithAudit({
    required String reportId,
    required String newStatus,
    required String comment,
    required String userId,
    required String userName,
  }) async {
    final batch = FirebaseFirestore.instance.batch();

    final reportRef = _reports.doc(reportId);
    batch.update(reportRef, {
      'status': newStatus,
      'updatedAt': FieldValue.serverTimestamp(),
      if (newStatus == 'resolved') 'resolvedAt': FieldValue.serverTimestamp(),
    });

    final auditRef = FirebaseFirestore.instance.collection('auditLogs').doc();
    batch.set(auditRef, {
      'timestamp': FieldValue.serverTimestamp(),
      'userId': userId,
      'userDisplayName': userName,
      'reportId': reportId,
      'action': 'status_change',
      'newStatus': newStatus,
      'comment': comment,
    });

    await batch.commit();
  }

  /// Oculta a denúncia (soft-delete) e ajusta o **score** do autor — mas
  /// preserva `reportCount`, que representa quantas denúncias o usuário
  /// já criou (histórico imutável). O ajuste de score usa `authorUid`,
  /// que existe inclusive em denúncias anônimas.
  Future<void> hideReportWithAudit({
    required String reportId,
    required String adminUid,
    required String adminName,
    String? reason,
  }) async {
    final reportSnap = await _reports.doc(reportId).get();
    final reportData = reportSnap.data();
    final ownerId =
        (reportData?['authorUid'] as String?) ??
            (reportData?['userId'] as String?);
    final wasResolved = reportData?['status'] == 'resolved';
    final alreadyHidden = reportData?['isHidden'] == true;

    final batch = FirebaseFirestore.instance.batch();

    batch.update(_reports.doc(reportId), {
      'isHidden': true,
      'hiddenAt': FieldValue.serverTimestamp(),
      'hiddenBy': adminUid,
      'hiddenReason': reason,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    if (!alreadyHidden && ownerId != null) {
      final scoreDelta = -10 + (wasResolved ? -20 : 0);
      batch.update(_users.doc(ownerId), {
        'score': FieldValue.increment(scoreDelta),
      });
    }

    final auditRef = FirebaseFirestore.instance.collection('auditLogs').doc();
    batch.set(auditRef, {
      'timestamp': FieldValue.serverTimestamp(),
      'userId': adminUid,
      'userDisplayName': adminName,
      'reportId': reportId,
      'action': 'hide_report',
      'reason': reason,
    });

    await batch.commit();
  }

  Future<void> unhideReportWithAudit({
    required String reportId,
    required String adminUid,
    required String adminName,
    String? reason,
  }) async {
    final reportSnap = await _reports.doc(reportId).get();
    final reportData = reportSnap.data();
    final ownerId =
        (reportData?['authorUid'] as String?) ??
            (reportData?['userId'] as String?);
    final wasResolved = reportData?['status'] == 'resolved';
    final wasHidden = reportData?['isHidden'] == true;

    final batch = FirebaseFirestore.instance.batch();

    batch.update(_reports.doc(reportId), {
      'isHidden': false,
      'hiddenAt': null,
      'hiddenBy': null,
      'hiddenReason': null,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    if (wasHidden && ownerId != null) {
      final scoreDelta = 10 + (wasResolved ? 20 : 0);
      batch.update(_users.doc(ownerId), {
        'score': FieldValue.increment(scoreDelta),
      });
    }

    final auditRef = FirebaseFirestore.instance.collection('auditLogs').doc();
    batch.set(auditRef, {
      'timestamp': FieldValue.serverTimestamp(),
      'userId': adminUid,
      'userDisplayName': adminName,
      'reportId': reportId,
      'action': 'unhide_report',
      'reason': reason,
    });

    await batch.commit();
  }
}
