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
    String? bio,
    String? region,
  }) async {
    await _collection.doc(uid).update({
      'displayName': displayName,
      if (bio != null) 'bio': bio,
      if (region != null) 'region': region,
    });

    await FirebaseAuth.instance.currentUser?.updateDisplayName(displayName);
  }

  Future<void> deactivateAccount(String uid) async {
    await _collection.doc(uid).update({'status': 'inactive'});
    await FirebaseAuth.instance.signOut();
  }

  Future<int> getTotalUsers() async {
    final snapshot = await _collection.count().get();
    return snapshot.count ?? 0;
  }
}
