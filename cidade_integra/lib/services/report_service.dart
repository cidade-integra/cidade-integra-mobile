import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/report.dart';

class ReportService {
  final _collection = FirebaseFirestore.instance.collection('reports');

  Future<List<Report>> getReports({
    String? category,
    String? status,
    int? limit,
    bool includeHidden = false,
  }) async {
    Query query = _collection.orderBy('createdAt', descending: true);

    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }
    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }
    if (limit != null) {
      query = query.limit(limit);
    }

    final snapshot = await query.get();
    final reports =
        snapshot.docs.map((doc) => Report.fromFirestore(doc)).toList();
    if (includeHidden) return reports;
    return reports.where((r) => !r.isHidden).toList();
  }

  Future<List<Report>> getReportsByUser(
    String userId, {
    bool includeHidden = false,
  }) async {
    final snapshot =
        await _collection
            .where('userId', isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .get();
    final reports =
        snapshot.docs.map((doc) => Report.fromFirestore(doc)).toList();
    if (includeHidden) return reports;
    return reports.where((r) => !r.isHidden).toList();
  }

  Future<Report?> getReportById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;
    return Report.fromFirestore(doc);
  }

  Future<String> createReport(Report report) async {
    final data = report.toFirestore();
    data['createdAt'] = FieldValue.serverTimestamp();
    data['updatedAt'] = FieldValue.serverTimestamp();
    data['status'] = ReportStatus.pending.name;
    data['resolvedAt'] = null;

    final docRef = await _collection.add(data);

    if (report.userId != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(report.userId)
          .update({
            'reportCount': FieldValue.increment(1),
            'score': FieldValue.increment(10),
          });
    }

    return docRef.id;
  }

  Future<void> updateReportStatus(String id, ReportStatus status) async {
    final data = <String, dynamic>{
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (status == ReportStatus.resolved) {
      data['resolvedAt'] = FieldValue.serverTimestamp();
    }

    final report = await getReportById(id);
    await _collection.doc(id).update(data);

    if (status == ReportStatus.resolved &&
        report != null &&
        report.userId != null &&
        report.status != ReportStatus.resolved) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(report.userId)
            .update({'score': FieldValue.increment(20)});
      } catch (_) {}
    }
  }

  Future<void> updateReport(String id, Map<String, dynamic> updates) async {
    updates['updatedAt'] = FieldValue.serverTimestamp();
    await _collection.doc(id).update(updates);
  }

  Future<void> deleteReport(String id) async {
    await _collection.doc(id).delete();
  }

  /// Soft-delete: marca a denúncia como oculta, mas mantém no banco.
  /// O documento continua acessível para admins e para auditoria.
  Future<void> hideReport({
    required String id,
    required String adminUid,
    String? reason,
  }) async {
    await _collection.doc(id).update({
      'isHidden': true,
      'hiddenAt': FieldValue.serverTimestamp(),
      'hiddenBy': adminUid,
      'hiddenReason': reason,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Reverte o soft-delete, tornando a denúncia visível novamente.
  Future<void> unhideReport(String id) async {
    await _collection.doc(id).update({
      'isHidden': false,
      'hiddenAt': null,
      'hiddenBy': null,
      'hiddenReason': null,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
