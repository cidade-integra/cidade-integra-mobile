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
        .map((snapshot) =>
            snapshot.docs.map((doc) => Comment.fromFirestore(doc)).toList());
  }

  Future<void> addComment(String reportId, Comment comment) async {
    await _commentsRef(reportId).add(comment.toFirestore());
  }
}
