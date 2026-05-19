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

  Future<void> deleteComment(String reportId, String commentId) async {
    await _commentsRef(reportId).doc(commentId).delete();
  }
}
