import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/report.dart';

class SavedReportsService {
  CollectionReference _savedRef(String uid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('denunciasSalvas');
  }

  Future<void> saveReport(String uid, String reportId) async {
    await _savedRef(uid).doc(reportId).set({
      'savedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeReport(String uid, String reportId) async {
    await _savedRef(uid).doc(reportId).delete();
  }

  Future<bool> isSaved(String uid, String reportId) async {
    final doc = await _savedRef(uid).doc(reportId).get();
    return doc.exists;
  }

  Future<List<Report>> getSavedReports(String uid) async {
    final savedDocs = await _savedRef(uid)
        .orderBy('savedAt', descending: true)
        .get();

    final reportIds = savedDocs.docs.map((d) => d.id).toList();
    if (reportIds.isEmpty) return [];

    final reports = <Report>[];
    for (final id in reportIds) {
      final doc = await FirebaseFirestore.instance
          .collection('reports')
          .doc(id)
          .get();
      if (doc.exists) {
        reports.add(Report.fromFirestore(doc));
      }
    }
    return reports;
  }
}
