import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';
import '../models/report.dart';

class AdminService {
  final _reports = FirebaseFirestore.instance.collection('reports');
  final _users = FirebaseFirestore.instance.collection('users');

  Future<Map<String, int>> getReportStats() async {
    final snapshot = await _reports.get();
    final stats = {'total': 0, 'pending': 0, 'review': 0, 'resolved': 0, 'rejected': 0};

    for (final doc in snapshot.docs) {
      stats['total'] = (stats['total'] ?? 0) + 1;
      final status = doc.data()['status'] as String? ?? 'pending';
      stats[status] = (stats[status] ?? 0) + 1;
    }
    return stats;
  }

  Future<int> getTotalUsers() async {
    final snapshot = await _users.count().get();
    return snapshot.count ?? 0;
  }

  Future<List<Report>> getRecentReports({int limit = 5}) async {
    final snapshot = await _reports
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

  Future<void> updateUserStatus(String uid, String newStatus) async {
    await _users.doc(uid).update({'status': newStatus});
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
}
