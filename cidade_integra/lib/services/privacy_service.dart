import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/app_user.dart';

class PrivacyService {
  final _firestore = FirebaseFirestore.instance;

  Future<void> exportUserData(String uid) async {
    final userDoc = await _firestore.collection('users').doc(uid).get();
    final reportsSnap = await _firestore
        .collection('reports')
        .where('userId', isEqualTo: uid)
        .get();
    final savedSnap = await _firestore
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

  /// Exclusão de conta segundo o art. 18, VI da LGPD.
  ///
  /// 1. Anonimiza comentários do usuário (autoria → "Usuário removido").
  /// 2. Anonimiza as denúncias do usuário em vez de apagá-las — elas
  ///    permanecem disponíveis por interesse público (art. 7º, IX da LGPD)
  ///    mas perdem o vínculo com o titular.
  /// 3. Marca o documento do usuário como `deleted` e remove os campos
  ///    pessoais (nome, e-mail, foto). Mantemos o doc para auditoria e
  ///    para impedir reaproveitamento do UID.
  /// 4. Remove a credencial em Firebase Auth (requer reautenticação
  ///    recente — se falhar com `requires-recent-login`, o chamador deve
  ///    pedir login novo e tentar de novo).
  ///
  /// Por que não usar `batch.delete(users/uid)`?
  /// As regras Firestore não permitem `delete` em `users/*` para evitar
  /// reuso do UID e quebrar referências históricas — exatamente o que
  /// estava causando o `permission-denied` reportado pelos testadores.
  Future<void> deleteAccount(String uid) async {
    final batch = _firestore.batch();

    final commentsSnap = await _firestore
        .collectionGroup('comments')
        .where('authorId', isEqualTo: uid)
        .get();
    for (final doc in commentsSnap.docs) {
      batch.update(doc.reference, {
        'author': 'Usuário removido',
        'authorId': 'deleted',
      });
    }

    final reportsSnap = await _firestore
        .collection('reports')
        .where('userId', isEqualTo: uid)
        .get();
    for (final doc in reportsSnap.docs) {
      batch.update(doc.reference, {
        'isAnonymous': true,
        'userId': null,
      });
    }

    final savedSnap = await _firestore
        .collection('users')
        .doc(uid)
        .collection('denunciasSalvas')
        .get();
    for (final doc in savedSnap.docs) {
      batch.delete(doc.reference);
    }

    batch.update(_firestore.collection('users').doc(uid), {
      'status': UserStatus.deleted,
      'displayName': 'Usuário removido',
      'email': '',
      'photoURL': '',
      'deletedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();

    try {
      await FirebaseAuth.instance.currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      debugPrint('[PrivacyService] auth delete falhou: ${e.code} ${e.message}');
      rethrow;
    }
  }
}
