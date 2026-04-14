import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String displayName;
  final String email;
  final String photoURL;
  final String role;
  final String createdAt;
  final int score;
  final int reportCount;
  final String lastLoginAt;
  final String region;
  final bool verified;
  final String bio;
  final String status;

  const AppUser({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoURL = '',
    this.role = 'user',
    required this.createdAt,
    this.score = 0,
    this.reportCount = 0,
    required this.lastLoginAt,
    this.region = '',
    this.verified = false,
    this.bio = '',
    this.status = 'active',
  });

  bool get isAdmin => role == 'admin';

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUser(
      uid: doc.id,
      displayName: data['displayName'] ?? '',
      email: data['email'] ?? '',
      photoURL: data['photoURL'] ?? '',
      role: data['role'] ?? 'user',
      createdAt: data['createdAt'] ?? '',
      score: data['score'] ?? 0,
      reportCount: data['reportCount'] ?? 0,
      lastLoginAt: data['lastLoginAt'] ?? '',
      region: data['region'] ?? '',
      verified: data['verified'] ?? false,
      bio: data['bio'] ?? '',
      status: data['status'] ?? 'active',
    );
  }

  AppUser copyWith({
    String? displayName,
    String? photoURL,
    String? bio,
    String? region,
    int? score,
    int? reportCount,
    bool? verified,
    String? status,
  }) {
    return AppUser(
      uid: uid,
      displayName: displayName ?? this.displayName,
      email: email,
      photoURL: photoURL ?? this.photoURL,
      role: role,
      createdAt: createdAt,
      score: score ?? this.score,
      reportCount: reportCount ?? this.reportCount,
      lastLoginAt: lastLoginAt,
      region: region ?? this.region,
      verified: verified ?? this.verified,
      bio: bio ?? this.bio,
      status: status ?? this.status,
    );
  }
}
