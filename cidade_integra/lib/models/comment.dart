import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String author;
  final String authorId;
  final String message;
  final DateTime createdAt;
  final int avatarColor;
  final String role;

  const Comment({
    required this.id,
    required this.author,
    required this.authorId,
    required this.message,
    required this.createdAt,
    this.avatarColor = 0xFF3498DB,
    this.role = 'user',
  });

  bool get isAdmin => role == 'admin';

  factory Comment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Comment(
      id: doc.id,
      author: data['author'] ?? 'Anônimo',
      authorId: data['authorId'] ?? '',
      message: data['message'] ?? '',
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      avatarColor: data['avatarColor'] ?? 0xFF3498DB,
      role: data['role'] ?? 'user',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'author': author,
      'authorId': authorId,
      'message': message,
      'createdAt': FieldValue.serverTimestamp(),
      'avatarColor': avatarColor,
      'role': role,
    };
  }
}
