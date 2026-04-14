import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/app_user.dart';
import '../../services/admin_service.dart';
import '../../services/export_service.dart';
import '../../utils/app_theme.dart';

class AdminUsuariosScreen extends StatefulWidget {
  const AdminUsuariosScreen({super.key});

  @override
  State<AdminUsuariosScreen> createState() => _AdminUsuariosScreenState();
}

class _AdminUsuariosScreenState extends State<AdminUsuariosScreen> {
  final _service = AdminService();
  final _searchController = TextEditingController();

  List<AppUser> _allUsers = [];
  bool _loading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final users = await _service.getAllUsers();
      if (mounted) setState(() { _allUsers = users; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<AppUser> get _filtered {
    if (_searchQuery.isEmpty) return _allUsers;
    final q = _searchQuery.toLowerCase();
    return _allUsers.where((u) =>
        u.displayName.toLowerCase().contains(q) ||
        u.email.toLowerCase().contains(q)).toList();
  }

  void _confirmRoleChange(AppUser user) {
    final newRole = user.role == 'admin' ? 'user' : 'admin';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Alterar Permissão'),
        content: Text(
          'Alterar "${user.displayName}" de '
          '${user.role == "admin" ? "Admin" : "Usuário"} '
          'para ${newRole == "admin" ? "Admin" : "Usuário"}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _service.updateUserRole(user.uid, newRole);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Permissão alterada para $newRole.')),
                );
                _load();
              }
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _confirmStatusChange(AppUser user) {
    final newStatus = user.status == 'active' ? 'inactive' : 'active';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(newStatus == 'inactive' ? 'Desativar Usuário' : 'Reativar Usuário'),
        content: Text(
          '${newStatus == "inactive" ? "Desativar" : "Reativar"} '
          'a conta de "${user.displayName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _service.updateUserStatus(user.uid, newStatus);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(newStatus == 'inactive'
                        ? 'Usuário desativado.'
                        : 'Usuário reativado.'),
                  ),
                );
                _load();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: newStatus == 'inactive'
                  ? AppColors.vermelho
                  : AppColors.verde,
            ),
            child: Text(newStatus == 'inactive' ? 'Desativar' : 'Reativar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          color: AppColors.azul,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                tooltip: 'Voltar',
                onPressed: () => context.go('/admin'),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Gestão de Usuários',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.file_download, color: Colors.white),
                tooltip: 'Exportar CSV',
                onPressed: _allUsers.isEmpty
                    ? null
                    : () async {
                        await ExportService().exportUsersCSV(_allUsers);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('CSV exportado.')),
                          );
                        }
                      },
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: 'Buscar por nome ou email...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
            ),
          ),
        ),

        if (_loading)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_filtered.isEmpty)
          Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Text(
                'Nenhum usuário encontrado.',
                style: TextStyle(color: AppColors.textoSecundario),
              ),
            ),
          )
        else
          ...List.generate(_filtered.length, (i) {
            final u = _filtered[i];
            return _UserTile(
              user: u,
              onRoleChange: () => _confirmRoleChange(u),
              onStatusChange: () => _confirmStatusChange(u),
            );
          }),
      ],
    );
  }
}

class _UserTile extends StatelessWidget {
  final AppUser user;
  final VoidCallback onRoleChange;
  final VoidCallback onStatusChange;

  const _UserTile({
    required this.user,
    required this.onRoleChange,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = user.status == 'active';

    return Opacity(
      opacity: isActive ? 1.0 : 0.5,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: user.isAdmin ? AppColors.verde : AppColors.azul,
          child: Text(
            user.displayName.isNotEmpty
                ? user.displayName[0].toUpperCase()
                : '?',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
        title: Row(
          children: [
            Flexible(
              child: Text(
                user.displayName,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.azul,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: user.isAdmin
                    ? AppColors.verde.withValues(alpha: 0.15)
                    : AppColors.azul.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                user.isAdmin ? 'Admin' : 'Usuário',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: user.isAdmin ? AppColors.verde : AppColors.azul,
                ),
              ),
            ),
            if (!isActive) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.vermelho.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Inativo',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.vermelho,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(
          '${user.email} · Score: ${user.score}',
          style: TextStyle(fontSize: 12, color: AppColors.textoSecundario),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (action) {
            if (action == 'role') onRoleChange();
            if (action == 'status') onStatusChange();
          },
          itemBuilder: (_) => [
            PopupMenuItem(
              value: 'role',
              child: Row(
                children: [
                  const Icon(Icons.swap_horiz, size: 18),
                  const SizedBox(width: 8),
                  Text(user.isAdmin ? 'Tornar Usuário' : 'Tornar Admin'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'status',
              child: Row(
                children: [
                  Icon(
                    isActive ? Icons.block : Icons.check_circle_outline,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(isActive ? 'Desativar' : 'Reativar'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
