import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class PrivacyService {
  final _firestore = FirebaseFirestore.instance;

  Future<void> exportUserData(String uid) async {
    final userDoc = await _firestore.collection('users').doc(uid).get();
    final reportsSnap =
        await _firestore
            .collection('reports')
            .where('userId', isEqualTo: uid)
            .get();
    final savedSnap =
        await _firestore
            .collection('users')
            .doc(uid)
            .collection('denunciasSalvas')
            .get();

    final data = {
      'profile': userDoc.data(),
      'reports':
          reportsSnap.docs.map((d) => {'id': d.id, ...d.data()}).toList(),
      'savedReports': savedSnap.docs.map((d) => d.id).toList(),
      'exportedAt': DateTime.now().toIso8601String(),
    };

    final json = const JsonEncoder.withIndent('  ').convert(data);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/meus_dados_cidadeintegra.json');
    await file.writeAsString(json);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        subject: 'Meus dados — Cidade Integra',
      ),
    );
  }

  Future<void> deleteAccount(String uid) async {
    final batch = _firestore.batch();

    final commentsSnap =
        await _firestore
            .collectionGroup('comments')
            .where('authorId', isEqualTo: uid)
            .get();
    for (final doc in commentsSnap.docs) {
      batch.update(doc.reference, {
        'author': 'Usuário removido',
        'authorId': 'deleted',
      });
    }

    final savedSnap =
        await _firestore
            .collection('users')
            .doc(uid)
            .collection('denunciasSalvas')
            .get();
    for (final doc in savedSnap.docs) {
      batch.delete(doc.reference);
    }

    batch.delete(_firestore.collection('users').doc(uid));
    await batch.commit();

    await FirebaseAuth.instance.currentUser?.delete();
  }
}
