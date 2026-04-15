import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/notification_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  String _role = 'user';
  bool _isLoading = true;
  late final StreamSubscription<User?> _authSub;

  AuthProvider() {
    _authSub = FirebaseAuth.instance.authStateChanges().listen(_onAuthChanged);
  }

  User? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isAdmin => _role == 'admin';
  bool get isLoading => _isLoading;
  String get role => _role;

  Future<void> _onAuthChanged(User? user) async {
    _user = user;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          _role = doc.data()?['role'] ?? 'user';
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({'lastLoginAt': DateTime.now().toIso8601String()});
          await NotificationService().saveTokenForUser(user.uid);
        } else {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
            'displayName': user.displayName ?? '',
            'email': user.email ?? '',
            'photoURL': user.photoURL ?? '',
            'role': 'user',
            'createdAt': DateTime.now().toIso8601String(),
            'score': 0,
            'reportCount': 0,
            'lastLoginAt': DateTime.now().toIso8601String(),
            'region': '',
            'verified': false,
            'bio': '',
            'status': 'active',
          });
          _role = 'user';
        }
      } catch (_) {
        _role = 'user';
      }
    } else {
      _role = 'user';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {}
    await FirebaseAuth.instance.signOut();
  }

  @override
  void dispose() {
    _authSub.cancel();
    super.dispose();
  }
}
