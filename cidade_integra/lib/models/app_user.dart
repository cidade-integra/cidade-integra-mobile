import 'package:cloud_firestore/cloud_firestore.dart';

/// Estados de conta — alinhados ao plano LGPD descrito em `planning/sdl.md`.
class UserStatus {
  UserStatus._();
  static const String active = 'active';

  /// Usuário desativou a própria conta. Pode reativar entrando de novo.
  static const String suspended = 'suspended';

  /// Administrador bloqueou a conta. Usuário NÃO pode entrar.
  static const String banned = 'banned';

  /// Conta excluída pelo titular (LGPD art. 18, VI). Dados pessoais
  /// foram anonimizados e a credencial Firebase Auth removida.
  static const String deleted = 'deleted';
}

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
  final bool verified;
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
    this.verified = false,
    this.status = UserStatus.active,
  });

  bool get isAdmin => role == 'admin';
  bool get isActive => status == UserStatus.active;
  bool get isSuspended => status == UserStatus.suspended;
  bool get isBanned => status == UserStatus.banned;
  bool get isDeleted => status == UserStatus.deleted;

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
      verified: data['verified'] ?? false,
      status: data['status'] ?? UserStatus.active,
    );
  }

  AppUser copyWith({
    String? displayName,
    String? photoURL,
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
      verified: verified ?? this.verified,
      status: status ?? this.status,
    );
  }
}
