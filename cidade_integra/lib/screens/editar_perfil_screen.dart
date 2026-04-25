import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/app_user.dart';
import '../providers/auth_provider.dart';
import '../services/user_service.dart';
import '../utils/app_theme.dart';
import '../utils/input_sanitizer.dart';

class EditarPerfilScreen extends StatelessWidget {
  const EditarPerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.isLoggedIn) {
      return const Center(child: Text('Faça login para editar seu perfil.'));
    }

    return FutureBuilder<AppUser?>(
      future: UserService().getUserById(auth.user!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final user = snapshot.data;
        if (user == null) {
          return const Center(child: Text('Usuário não encontrado.'));
        }
        return _EditForm(user: user);
      },
    );
  }
}

class _EditForm extends StatefulWidget {
  final AppUser user;
  const _EditForm({required this.user});

  @override
  State<_EditForm> createState() => _EditFormState();
}

class _EditFormState extends State<_EditForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeController;
  late final TextEditingController _bioController;
  late final TextEditingController _regiaoController;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.user.displayName);
    _bioController = TextEditingController(text: widget.user.bio);
    _regiaoController = TextEditingController(text: widget.user.region);
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _bioController.dispose();
    _regiaoController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final nome = InputSanitizer.sanitize(_nomeController.text);
    final bio = InputSanitizer.sanitize(_bioController.text);
    final regiao = InputSanitizer.sanitize(_regiaoController.text);

    setState(() => _loading = true);

    try {
      await UserService().updateProfile(
        uid: widget.user.uid,
        displayName: nome,
        bio: bio,
        region: regiao,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil atualizado com sucesso!')),
        );
        context.go('/perfil');
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao atualizar perfil.')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _confirmarDesativacao() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Desativar Conta'),
        content: const Text(
          'Tem certeza que deseja desativar sua conta? '
          'Você poderá reativá-la entrando em contato com o suporte.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await UserService().deactivateAccount(widget.user.uid);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Conta desativada com sucesso.'),
                  ),
                );
                context.go('/login');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.vermelho,
            ),
            child: const Text('Desativar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.grey.shade50, Colors.white],
            ),
          ),
          child: Column(
            children: [
              Text(
                'Editar Perfil',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.azul,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Atualize suas informações pessoais.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textoSecundario,
                ),
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nomeController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Nome de exibição *',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  maxLength: 60,
                  validator: (v) => InputSanitizer.validateName(v),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _bioController,
                  maxLines: 3,
                  maxLength: 200,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Bio',
                    hintText: 'Conte um pouco sobre você...',
                    prefixIcon: Icon(Icons.info_outline),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _regiaoController,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Região',
                    hintText: 'Ex: São Paulo - SP',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _loading ? null : _salvar,
                    icon: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save_outlined, size: 20),
                    label: Text(_loading ? 'Salvando...' : 'Salvar'),
                  ),
                ),
                const SizedBox(height: 12),

                SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () => context.go('/perfil'),
                    icon: const Icon(Icons.arrow_back, size: 18),
                    label: const Text('Cancelar'),
                  ),
                ),

                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 16),

                Text(
                  'Zona de Perigo',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.vermelho,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: _confirmarDesativacao,
                    icon: const Icon(Icons.block, size: 18),
                    label: const Text('Desativar Conta'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.vermelho,
                      side: const BorderSide(color: AppColors.vermelho),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
