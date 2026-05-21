import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import '../utils/auth_error_mapper.dart';
import '../services/analytics_service.dart';
import '../utils/input_sanitizer.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _loading = false;
  bool _googleLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _loginComEmail() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _senhaController.text,
      );
      await AnalyticsService.logLogin('email');
      // Não chamamos context.go('/') aqui: o GoRouter redirect dispara
      // automaticamente quando AuthProvider termina a checagem de status.
      // Contas banidas/excluídas/suspensas permanecem em /login com o
      // banner correspondente em vez de pular para a home brevemente.
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(mapAuthError(e.code))));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro inesperado ao fazer login.')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loginComGoogle() async {
    setState(() => _googleLoading = true);
    try {
      final account = await GoogleSignIn.instance.authenticate();
      final googleAuth = account.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      await AnalyticsService.logLogin('google');
      // Idem ao login por e-mail: redirect via router.
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(mapAuthError(e.code))));
      }
    } catch (e) {
      debugPrint('Google Sign-In error: $e');
      if (mounted && e.toString().contains('canceled')) return;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao fazer login com o Google: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  Future<void> _reactivate(String uid) async {
    setState(() => _loading = true);
    try {
      await context.read<AuthProvider>().reactivateSelf(uid);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conta reativada com sucesso!'),
            backgroundColor: AppColors.verde,
          ),
        );
        // Router redireciona sozinho assim que isLoggedIn vira true.
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível reativar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 32),
              _buildHeader(),
              const SizedBox(height: 20),
              if (auth.blockedReason != null)
                _StatusBanner(
                  message: auth.blockedReason!,
                  color: AppColors.vermelho,
                  icon: Icons.block,
                  onClose: () => auth.clearBlockedReason(),
                ),
              if (auth.suspendedUid != null)
                _StatusBanner(
                  message:
                      'Esta conta está desativada. Deseja reativá-la?',
                  color: AppColors.verdeEscuro,
                  icon: Icons.refresh,
                  actionLabel: 'Reativar',
                  onAction: () => _reactivate(auth.suspendedUid!),
                  onClose: () => auth.clearBlockedReason(),
                ),
              const SizedBox(height: 8),
              _buildCard(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.verde.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.location_on, size: 36, color: AppColors.verde),
        ),
        const SizedBox(height: 16),
        Text(
          'Bem-vindo ao\nCidade Integra',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppColors.azul,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Faça login para reportar problemas urbanos na sua cidade.',
          style: TextStyle(fontSize: 14, color: AppColors.textoSecundario),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCard() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.branco,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Entrar',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.azul,
              ),
            ),
            const SizedBox(height: 20),

            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'seu@email.com',
                prefixIcon: Icon(Icons.mail_outline),
              ),
              validator: (v) => InputSanitizer.validateEmail(v),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _senhaController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _loginComEmail(),
              decoration: InputDecoration(
                labelText: 'Senha',
                hintText: '••••••••',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed:
                      () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Informe a senha';
                if (v.length < 6) return 'Mínimo 6 caracteres';
                return null;
              },
            ),
            const SizedBox(height: 8),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.go('/recuperar-senha'),
                child: const Text('Esqueceu a senha?'),
              ),
            ),
            const SizedBox(height: 8),

            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _loading ? null : _loginComEmail,
                child:
                    _loading
                        ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Text('Entrar'),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'ou',
                    style: TextStyle(
                      color: AppColors.textoSecundario,
                      fontSize: 13,
                    ),
                  ),
                ),
                const Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 16),

            SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: _googleLoading ? null : _loginComGoogle,
                icon:
                    _googleLoading
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Icon(Icons.g_mobiledata, size: 24),
                label: Text(
                  _googleLoading ? 'Entrando...' : 'Entrar com Google',
                ),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Não tem conta? ',
                  style: TextStyle(color: AppColors.textoSecundario),
                ),
                GestureDetector(
                  onTap: () => context.go('/registro'),
                  child: Text(
                    'Criar conta',
                    style: TextStyle(
                      color: AppColors.verde,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final String message;
  final Color color;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback? onClose;

  const _StatusBanner({
    required this.message,
    required this.color,
    required this.icon,
    this.actionLabel,
    this.onAction,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 13, color: color),
            ),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
          if (onClose != null)
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              color: color,
              onPressed: onClose,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}
