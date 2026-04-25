import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/comment.dart';
import '../../providers/auth_provider.dart';
import '../../services/comment_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/input_sanitizer.dart';

class CommentSection extends StatefulWidget {
  final String reportId;
  const CommentSection({super.key, required this.reportId});

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final _service = CommentService();
  final _controller = TextEditingController();
  bool _sending = false;

  static const _maxLength = 500;
  static const _minLength = 5;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = InputSanitizer.sanitize(_controller.text);
    if (text.length < _minLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comentário deve ter pelo menos 5 caracteres.')),
      );
      return;
    }

    if (InputSanitizer.containsBlockedWords(text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('O comentário contém palavras inadequadas.')),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn) return;

    setState(() => _sending = true);
    try {
      final comment = Comment(
        id: '',
        author: auth.user?.displayName ?? 'Usuário',
        authorId: auth.user!.uid,
        message: text,
        createdAt: DateTime.now(),
        role: auth.role,
      );
      await _service.addComment(widget.reportId, comment);
      _controller.clear();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao publicar comentário.')),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.chat_bubble_outline, size: 20, color: AppColors.azul),
                  const SizedBox(width: 8),
                  Text(
                    'Comentários',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.azul,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (auth.isLoggedIn) ...[
                TextField(
                  controller: _controller,
                  maxLength: _maxLength,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Adicione seu comentário sobre esta denúncia…',
                    helperText: 'Seja respeitoso e construtivo.',
                    helperStyle: TextStyle(fontSize: 12, color: AppColors.textoSecundario),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: _sending ? null : _submit,
                    child: _sending
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Publicar Comentário'),
                  ),
                ),
                const SizedBox(height: 16),
              ] else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.bordas),
                  ),
                  child: Text(
                    'Faça login para comentar.',
                    style: TextStyle(color: AppColors.textoSecundario),
                    textAlign: TextAlign.center,
                  ),
                ),

              const SizedBox(height: 8),

              StreamBuilder<List<Comment>>(
                stream: _service.getComments(widget.reportId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final comments = snapshot.data ?? [];
                  if (comments.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          'Nenhum comentário ainda.',
                          style: TextStyle(color: AppColors.textoSecundario),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: comments
                        .map((c) => _CommentCard(comment: c))
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CommentCard extends StatelessWidget {
  final Comment comment;
  const _CommentCard({required this.comment});

  @override
  Widget build(BuildContext context) {
    final timeAgo = _formatTimeAgo(comment.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: comment.isAdmin
            ? AppColors.verde.withValues(alpha: 0.05)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: comment.isAdmin
              ? AppColors.verde.withValues(alpha: 0.2)
              : AppColors.bordas,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Color(comment.avatarColor),
                child: Text(
                  comment.author.isNotEmpty
                      ? comment.author[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            comment.author,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.azul,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (comment.isAdmin) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.verde.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Admin',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.verde,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      timeAgo,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textoSecundario,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            comment.message,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.preto,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'agora';
    if (diff.inMinutes < 60) return 'há ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'há ${diff.inHours}h';
    if (diff.inDays < 7) return 'há ${diff.inDays}d';
    return DateFormat('dd/MM/yyyy').format(date);
  }
}
