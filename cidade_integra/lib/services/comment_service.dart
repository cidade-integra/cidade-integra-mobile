import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/comment.dart';

class CommentService {
  CollectionReference _commentsRef(String reportId) {
    return FirebaseFirestore.instance
        .collection('reports')
        .doc(reportId)
        .collection('comments');
  }

  Stream<List<Comment>> getComments(String reportId) {
    return _commentsRef(reportId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Comment.fromFirestore(doc)).toList(),
        );
  }

  Future<void> addComment(String reportId, Comment comment) async {
    await _commentsRef(reportId).add(comment.toFirestore());
  }

  Future<void> updateComment(
    String reportId,
    String commentId,
    String newMessage,
  ) async {
    await _commentsRef(reportId).doc(commentId).update({
      'message': newMessage,
      'editedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Apaga um comentário e devolve, se possível, os pontos que o autor
  /// havia ganhado ao criá-lo (-2). Pulamos o decremento quando o autor
  /// já foi anonimizado (`authorId == 'deleted'`) ou quando não temos o
  /// ID — caso de comentários antigos sem o campo persistido.
  Future<void> deleteComment(
    String reportId,
    String commentId, {
    String? authorId,
  }) async {
    final ref = _commentsRef(reportId).doc(commentId);
    final shouldRefundScore =
        authorId != null && authorId.isNotEmpty && authorId != 'deleted';

    if (!shouldRefundScore) {
      await ref.delete();
      return;
    }

    final batch = FirebaseFirestore.instance.batch();
    batch.delete(ref);
    batch.update(
      FirebaseFirestore.instance.collection('users').doc(authorId),
      {'score': FieldValue.increment(-2)},
    );
    await batch.commit();
  }
}
