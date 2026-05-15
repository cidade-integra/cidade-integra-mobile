import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';

class EmailVerificationBanner extends StatefulWidget {
  const EmailVerificationBanner({super.key});

  @override
  State<EmailVerificationBanner> createState() => _EmailVerificationBannerState();
}

class _EmailVerificationBannerState extends State<EmailVerificationBanner> {
  bool _sending = false;
  bool _sent = false;

  Future<void> _resend() async {
    setState(() => _sending = true);
    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      if (mounted) setState(() { _sent = true; _sending = false; });
    } catch (_) {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (!auth.isLoggedIn) return const SizedBox.shrink();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.emailVerified) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: const Color(0xFFFFF3CD),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, size: 20, color: AppColors.vermelho),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _sent
                  ? 'E-mail de verificação reenviado!'
                  : 'Verifique seu e-mail para liberar todas as funcionalidades.',
              style: const TextStyle(fontSize: 13),
            ),
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
