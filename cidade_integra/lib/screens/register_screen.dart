import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../utils/app_theme.dart';
import '../utils/auth_error_mapper.dart';
import '../services/analytics_service.dart';
import '../utils/input_sanitizer.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _aceitouTermos = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_aceitouTermos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Você precisa aceitar os termos de uso.'),
        ),
      );
      return;
    }

    final nome = InputSanitizer.sanitize(_nomeController.text);

    setState(() => _loading = true);
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _senhaController.text,
      );

      await cred.user!.updateDisplayName(nome);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(cred.user!.uid)
          .set({
        'displayName': nome,
        'email': cred.user!.email,
        'photoURL': '',
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

      await AnalyticsService.logRegister();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cadastro realizado com sucesso!')),
        );
        context.go('/');
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mapAuthError(e.code))),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro inesperado. Tente novamente.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 32),
              _buildHeader(),
              const SizedBox(height: 28),
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
          child: Icon(Icons.person_add_outlined, size: 36, color: AppColors.verde),
        ),
        const SizedBox(height: 16),
        Text(
          'Criar Conta',
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
          'Cadastre-se para reportar problemas na sua cidade.',
          style: TextStyle(fontSize: 14, color: AppColors.textoSecundario),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCard() {
    final senhaMatch = _confirmarSenhaController.text.isNotEmpty &&
        _senhaController.text == _confirmarSenhaController.text;
    final senhaMismatch = _confirmarSenhaController.text.isNotEmpty &&
        _senhaController.text != _confirmarSenhaController.text;

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
              'Cadastrar',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.azul,
              ),
            ),
            const SizedBox(height: 20),

            TextFormField(
              controller: _nomeController,
              textInputAction: TextInputAction.next,
              maxLength: 60,
              decoration: const InputDecoration(
                labelText: 'Nome completo',
                hintText: 'Seu nome',
                prefixIcon: Icon(Icons.person_outline),
                counterText: '',
              ),
              validator: (v) => InputSanitizer.validateName(v),
            ),
            const SizedBox(height: 16),

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
              textInputAction: TextInputAction.next,
              onChanged: (_) => setState(() {}),
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
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Informe a senha';
                if (v.length < 6) return 'A senha deve ter pelo menos 6 caracteres';
                return null;
              },
            ),

            if (_senhaController.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 12),
                child: Row(
                  children: [
                    Icon(
                      _senhaController.text.length >= 6
                          ? Icons.check_circle
                          : Icons.cancel,
                      size: 14,
                      color: _senhaController.text.length >= 6
                          ? AppColors.verde
                          : AppColors.vermelho,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'A senha deve ter 6 caracteres ou mais',
                      style: TextStyle(
                        fontSize: 12,
                        color: _senhaController.text.length >= 6
                            ? AppColors.verde
                            : AppColors.textoSecundario,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _confirmarSenhaController,
              obscureText: _obscureConfirm,
              textInputAction: TextInputAction.done,
              onChanged: (_) => setState(() {}),
              onFieldSubmitted: (_) => _registrar(),
              decoration: InputDecoration(
                labelText: 'Confirmar senha',
                hintText: '••••••••',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Confirme a senha';
                if (v != _senhaController.text) return 'As senhas não coincidem';
                return null;
              },
            ),

            if (senhaMatch || senhaMismatch)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 12),
                child: Row(
                  children: [
                    Icon(
                      senhaMatch ? Icons.check_circle : Icons.cancel,
                      size: 14,
                      color: senhaMatch ? AppColors.verde : AppColors.vermelho,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      senhaMatch
                          ? 'As senhas coincidem'
                          : 'As senhas não são iguais',
                      style: TextStyle(
                        fontSize: 12,
                        color: senhaMatch
                            ? AppColors.verde
                            : AppColors.vermelho,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: _aceitouTermos,
                  onChanged: (v) => setState(() => _aceitouTermos = v ?? false),
                  activeColor: AppColors.verde,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _aceitouTermos = !_aceitouTermos),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text.rich(
                        TextSpan(
                          text: 'Li e aceito os ',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textoSecundario,
                          ),
                          children: [
                            TextSpan(
                              text: 'Termos de Uso',
                              style: TextStyle(
                                color: AppColors.verde,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const TextSpan(text: ' e a '),
                            TextSpan(
                              text: 'Política de Privacidade',
                              style: TextStyle(
                                color: AppColors.verde,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const TextSpan(text: '.'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _loading ? null : _registrar,
                child: _loading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Cadastrar'),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Já tem conta? ',
                  style: TextStyle(color: AppColors.textoSecundario),
                ),
                GestureDetector(
                  onTap: () => context.go('/login'),
                  child: Text(
                    'Entrar',
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
