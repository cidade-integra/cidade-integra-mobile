import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/app_user.dart';
import '../services/notification_service.dart';
import '../services/secure_storage_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  String _role = 'user';
  String _status = UserStatus.active;
  bool _isLoading = true;
  String? _blockedReason;
  String? _suspendedUid;

  late final StreamSubscription<User?> _authSub;

  AuthProvider() {
    _authSub = FirebaseAuth.instance.authStateChanges().listen(_onAuthChanged);
  }

  User? get user => _user;

  /// Verdadeiro apenas se o usuário existe E a conta está ativa.
  /// Contas suspensas/banidas/excluídas retornam `false` para que
  /// o router proteja rotas autenticadas.
  bool get isLoggedIn => _user != null && _status == UserStatus.active;

  bool get isAdmin => _role == 'admin' && _status == UserStatus.active;
  bool get isLoading => _isLoading;
  String get role => _role;
  String get status => _status;

  /// Não-null quando o último login foi recusado por banimento/exclusão.
  String? get blockedReason => _blockedReason;

  /// Não-null quando o último login foi feito com uma conta suspensa
  /// (desativada pelo próprio usuário). A tela de login pode oferecer
  /// um botão "Reativar conta" usando este UID.
  String? get suspendedUid => _suspendedUid;

  void clearBlockedReason() {
    if (_blockedReason != null || _suspendedUid != null) {
      _blockedReason = null;
      _suspendedUid = null;
      notifyListeners();
    }
  }

  Future<void> _onAuthChanged(User? user) async {
    if (user == null) {
      _user = null;
      _role = 'user';
      _status = UserStatus.active;
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final ref = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final doc = await ref.get();

      if (!doc.exists) {
        await ref.set({
          'displayName': user.displayName ?? '',
          'email': user.email ?? '',
          'photoURL': user.photoURL ?? '',
          'role': 'user',
          'createdAt': DateTime.now().toIso8601String(),
          'score': 0,
          'reportCount': 0,
          'lastLoginAt': DateTime.now().toIso8601String(),
          'verified': false,
          'status': UserStatus.active,
        });
        _user = user;
        _role = 'user';
        _status = UserStatus.active;
        _isLoading = false;
        notifyListeners();
        return;
      }

      final data = doc.data() ?? {};
      final status = data['status'] as String? ?? UserStatus.active;

      if (status == UserStatus.banned) {
        _blockedReason =
            'Sua conta foi suspensa pela administração. Entre em contato com o suporte.';
        await _signOutEverywhere();
        _user = null;
        _isLoading = false;
        notifyListeners();
        return;
      }

      if (status == UserStatus.deleted) {
        _blockedReason = 'Esta conta foi excluída e não pode ser reativada.';
        await _signOutEverywhere();
        _user = null;
        _isLoading = false;
        notifyListeners();
        return;
      }

      if (status == UserStatus.suspended) {
        // Mantemos o usuário autenticado em "limbo" para que ele possa
        // reativar a própria conta (isOwner() das regras precisa de auth).
        // isLoggedIn permanece false porque getter checa status == active.
        _user = user;
        _role = data['role'] as String? ?? 'user';
        _status = UserStatus.suspended;
        _suspendedUid = user.uid;
        _isLoading = false;
        notifyListeners();
        return;
      }

      _user = user;
      _role = data['role'] as String? ?? 'user';
      _status = status;
      await ref.update({
        'lastLoginAt': DateTime.now().toIso8601String(),
      });
      await NotificationService().saveTokenForUser(user.uid);
    } catch (_) {
      _user = user;
      _role = 'user';
      _status = UserStatus.active;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _signOutEverywhere() async {
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {}
    await SecureStorageService.clearAll();
    await FirebaseAuth.instance.signOut();
  }

  Future<void> logout() async {
    await _signOutEverywhere();
  }

  /// Reativa uma conta suspensa do próprio usuário. Deve ser chamada
  /// enquanto o user está autenticado em "limbo" (status = suspended).
  Future<void> reactivateSelf(String uid) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'status': UserStatus.active,
      'suspendedAt': null,
    });
    _status = UserStatus.active;
    _suspendedUid = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSub.cancel();
    super.dispose();
  }
}
