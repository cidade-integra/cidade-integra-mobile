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
  /// Executa as etapas em **sequência separada** (não em batch único) para
  /// que uma falha em uma etapa não cancele as outras — algumas etapas
  /// podem precisar de índices compostos ou regras adicionais que
  /// dependem do ambiente, e a etapa essencial (anonimização do próprio
  /// `users/{uid}`) precisa acontecer mesmo se as auxiliares falharem.
  ///
  /// Por que não usar `batch.delete(users/uid)`? As regras proíbem
  /// `delete` em `users/*` para evitar reuso de UID. Anonimizamos.
  Future<void> deleteAccount(String uid) async {
    // 1. Anonimiza comentários (collectionGroup pode exigir índice).
    try {
      final commentsSnap = await _firestore
          .collectionGroup('comments')
          .where('authorId', isEqualTo: uid)
          .get();
      for (final doc in commentsSnap.docs) {
        await doc.reference.update({
          'author': 'Usuário removido',
          'authorId': 'deleted',
        });
      }
      debugPrint(
        '[Delete] anonimizou ${commentsSnap.docs.length} comentário(s).',
      );
    } catch (e, s) {
      debugPrint('[Delete] etapa COMMENTS falhou (continuando): $e');
      debugPrintStack(stackTrace: s);
    }

    // 2. Anonimiza denúncias (mantém para interesse público).
    try {
      final reportsSnap = await _firestore
          .collection('reports')
          .where('userId', isEqualTo: uid)
          .get();
      for (final doc in reportsSnap.docs) {
        await doc.reference.update({
          'isAnonymous': true,
          'userId': null,
          // authorUid permanece para o admin conseguir descontar score.
        });
      }
      debugPrint(
        '[Delete] anonimizou ${reportsSnap.docs.length} denúncia(s).',
      );
    } catch (e, s) {
      debugPrint('[Delete] etapa REPORTS falhou (continuando): $e');
      debugPrintStack(stackTrace: s);
    }

    // 3. Limpa subcoleções pessoais (denunciasSalvas, meusReports).
    try {
      final saved = await _firestore
          .collection('users')
          .doc(uid)
          .collection('denunciasSalvas')
          .get();
      for (final doc in saved.docs) {
        await doc.reference.delete();
      }
      final meusReports = await _firestore
          .collection('users')
          .doc(uid)
          .collection('meusReports')
          .get();
      for (final doc in meusReports.docs) {
        await doc.reference.delete();
      }
      debugPrint(
        '[Delete] limpou ${saved.docs.length} salva(s) e '
        '${meusReports.docs.length} índices.',
      );
    } catch (e, s) {
      debugPrint('[Delete] etapa SUBCOLLECTIONS falhou (continuando): $e');
      debugPrintStack(stackTrace: s);
    }

    // 4. ETAPA CRÍTICA: anonimiza o doc do usuário. Se isso falhar,
    //    propaga para o caller — não conseguimos deixar a conta em
    //    estado inconsistente.
    try {
      await _firestore.collection('users').doc(uid).update({
        'status': UserStatus.deleted,
        'displayName': 'Usuário removido',
        'email': '',
        'photoURL': '',
        'deletedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('[Delete] users/$uid anonimizado.');
    } catch (e, s) {
      debugPrint('[Delete] etapa USERS DOC falhou: $e');
      debugPrintStack(stackTrace: s);
      rethrow;
    }

    // 5. Remove a credencial Firebase Auth. Pode falhar com
    //    `requires-recent-login`; o caller trata.
    try {
      await FirebaseAuth.instance.currentUser?.delete();
      debugPrint('[Delete] credencial Auth removida.');
    } on FirebaseAuthException catch (e) {
      debugPrint('[Delete] auth delete falhou: ${e.code} ${e.message}');
      rethrow;
    }
  }
}
