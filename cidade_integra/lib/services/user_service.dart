import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';

class UserService {
  final _collection = FirebaseFirestore.instance.collection('users');

  Future<AppUser?> getUserById(String uid) async {
    final doc = await _collection.doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromFirestore(doc);
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _collection.doc(uid).update(data);
  }

  Future<void> updateProfile({
    required String uid,
    required String displayName,
  }) async {
    await _collection.doc(uid).update({'displayName': displayName});
    await FirebaseAuth.instance.currentUser?.updateDisplayName(displayName);
  }

  /// Suspende a própria conta (LGPD: pausa voluntária). Pode ser revertida
  /// pelo próprio usuário ao logar de novo.
  Future<void> suspendOwnAccount(String uid) async {
    await _collection.doc(uid).update({
      'status': UserStatus.suspended,
      'suspendedAt': FieldValue.serverTimestamp(),
    });
    await FirebaseAuth.instance.signOut();
  }

  /// Reativa uma conta suspensa pelo próprio titular.
  Future<void> reactivateOwnAccount(String uid) async {
    await _collection.doc(uid).update({
      'status': UserStatus.active,
      'suspendedAt': null,
    });
  }

  Future<int> getTotalUsers() async {
    final snapshot = await _collection.count().get();
    return snapshot.count ?? 0;
  }
}
