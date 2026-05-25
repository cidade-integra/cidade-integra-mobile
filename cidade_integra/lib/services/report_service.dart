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

  /// Lista todas as denúncias do usuário — inclusive as anônimas — usando
  /// `authorUid` (que sempre é preenchido na criação, mesmo em anônimas).
  /// Mais robusto que depender só da subcoleção `meusReports`, que pode
  /// não ter sido populada em versões antigas.
  Future<List<Report>> getReportsByUser(
    String userId, {
    bool includeHidden = false,
  }) async {
    final ids = <String>{};
    final reports = <Report>[];

    // Fonte 1: query direta por authorUid (cobre denúncias novas e
    // antigas não-anônimas).
    try {
      final snap = await _collection
          .where('authorUid', isEqualTo: userId)
          .get();
      for (final doc in snap.docs) {
        if (ids.add(doc.id)) reports.add(Report.fromFirestore(doc));
      }
    } catch (_) {}

    // Fonte 2: denúncias antigas sem `authorUid` (não-anônimas) ainda
    // expõem `userId`.
    try {
      final snap = await _collection
          .where('userId', isEqualTo: userId)
          .get();
      for (final doc in snap.docs) {
        if (ids.add(doc.id)) reports.add(Report.fromFirestore(doc));
      }
    } catch (_) {}

    // Fonte 3: índice privado `users/{uid}/meusReports` (mantido por
    // compatibilidade com versões anteriores).
    try {
      final users = FirebaseFirestore.instance.collection('users');
      final indexSnap = await users
          .doc(userId)
          .collection('meusReports')
          .get();
      for (final indexDoc in indexSnap.docs) {
        if (ids.contains(indexDoc.id)) continue;
        final doc = await _collection.doc(indexDoc.id).get();
        if (doc.exists) {
          ids.add(doc.id);
          reports.add(Report.fromFirestore(doc));
        }
      }
    } catch (_) {}

    reports.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (includeHidden) return reports;
    return reports.where((r) => !r.isHidden).toList();
  }

  Future<Report?> getReportById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;
    return Report.fromFirestore(doc);
  }

  /// Cria uma denúncia. Se [authorUid] for fornecido, a denúncia também
  /// é indexada em `users/{authorUid}/meusReports/{reportId}` — permite
  /// que o autor veja a própria denúncia em "Minhas Denúncias" mesmo
  /// quando foi enviada como anônima (e portanto sem `userId` no doc
  /// público).
  Future<String> createReport(
    Report report, {
    String? authorUid,
  }) async {
    final data = report.toFirestore();
    data['createdAt'] = FieldValue.serverTimestamp();
    data['updatedAt'] = FieldValue.serverTimestamp();
    data['status'] = ReportStatus.pending.name;
    data['resolvedAt'] = null;

    final docRef = await _collection.add(data);
    final uid = authorUid ?? report.userId;

    // A partir daqui as operações são auxiliares: cada uma vai num
    // try-catch isolado para que NUNCA propaguem erro ao chamador — a
    // denúncia já foi criada com sucesso e o usuário não deve ver
    // "erro de servidor" por causa de uma escrita secundária.
    if (uid != null) {
      final users = FirebaseFirestore.instance.collection('users');

      try {
        await users.doc(uid).collection('meusReports').doc(docRef.id).set({
          'createdAt': FieldValue.serverTimestamp(),
          'isAnonymous': report.isAnonymous,
        });
      } catch (_) {}

      // Score e reportCount sobem em qualquer denúncia autenticada.
      // Usamos `set(merge:true)` para criar o doc do usuário caso
      // ainda não exista (race condition em logins muito novos).
      try {
        await users.doc(uid).set({
          'score': FieldValue.increment(10),
          'reportCount': FieldValue.increment(1),
        }, SetOptions(merge: true));
      } catch (_) {}
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
