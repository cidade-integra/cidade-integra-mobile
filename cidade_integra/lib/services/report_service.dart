import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/report.dart';

class ReportService {
  final _collection = FirebaseFirestore.instance.collection('reports');

  Future<List<Report>> getReports({
    String? category,
    String? status,
    int? limit,
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
    return snapshot.docs.map((doc) => Report.fromFirestore(doc)).toList();
  }

  Future<List<Report>> getReportsByUser(String userId) async {
    final snapshot = await _collection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => Report.fromFirestore(doc)).toList();
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
          .update({'reportCount': FieldValue.increment(1)});
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

    await _collection.doc(id).update(data);
  }

  Future<void> updateReport(String id, Map<String, dynamic> updates) async {
    updates['updatedAt'] = FieldValue.serverTimestamp();
    await _collection.doc(id).update(updates);
  }

  Future<void> deleteReport(String id) async {
    await _collection.doc(id).delete();
  }
}
