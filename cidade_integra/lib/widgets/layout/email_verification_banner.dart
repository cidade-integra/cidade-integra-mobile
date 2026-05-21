import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';

class EmailVerificationBanner extends StatefulWidget {
  const EmailVerificationBanner({super.key});

  @override
  State<EmailVerificationBanner> createState() =>
      _EmailVerificationBannerState();
}

class _EmailVerificationBannerState extends State<EmailVerificationBanner> {
  bool _sending = false;
  bool _sent = false;
  bool _checking = false;
  bool _verifiedLocally = false;

  Future<void> _resend() async {
    setState(() => _sending = true);
    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      if (mounted) {
        setState(() {
          _sent = true;
          _sending = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _checkNow() async {
    setState(() => _checking = true);
    try {
      await FirebaseAuth.instance.currentUser?.reload();
      final verified =
          FirebaseAuth.instance.currentUser?.emailVerified ?? false;
      if (mounted) {
        setState(() {
          _checking = false;
          _verifiedLocally = verified;
        });
        if (verified) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('E-mail verificado com sucesso!'),
              backgroundColor: AppColors.verde,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Ainda não verificamos. Confira sua caixa de entrada.',
              ),
            ),
          );
        }
      }
    } catch (_) {
      if (mounted) setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (!auth.isLoggedIn) return const SizedBox.shrink();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.emailVerified || _verifiedLocally) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: const Color(0xFFFFF3CD),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 20,
            color: AppColors.vermelho,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _sent
                  ? 'E-mail enviado! Após confirmar, toque em "Já verifiquei".'
                  : 'Verifique seu e-mail para liberar todas as funcionalidades.',
              style: const TextStyle(fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: _checking ? null : _checkNow,
            child: Text(_checking ? 'Conferindo...' : 'Já verifiquei'),
          ),
          if (!_sent)
            TextButton(
              onPressed: _sending ? null : _resend,
              child: Text(_sending ? 'Enviando...' : 'Reenviar'),
            ),
        ],
      ),
    );
  }
}
