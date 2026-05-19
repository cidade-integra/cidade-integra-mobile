import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/app_theme.dart';

enum LegalKind { termos, politica }

class LegalScreen extends StatefulWidget {
  final LegalKind kind;
  const LegalScreen({super.key, required this.kind});

  @override
  State<LegalScreen> createState() => _LegalScreenState();
}

class _LegalScreenState extends State<LegalScreen> {
  String? _content;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final asset = widget.kind == LegalKind.termos
        ? 'assets/legal/termos_de_uso.md'
        : 'assets/legal/politica_privacidade.md';
    final txt = await rootBundle.loadString(asset);
    if (mounted) setState(() => _content = txt);
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.kind == LegalKind.termos
        ? 'Termos de Uso'
        : 'Política de Privacidade';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppColors.azul,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/'),
        ),
      ),
      body: _content == null
          ? const Center(child: CircularProgressIndicator())
          : Markdown(
              data: _content!,
              padding: const EdgeInsets.all(20),
              onTapLink: (text, href, title) async {
                if (href == null) return;
                final uri = Uri.tryParse(href);
                if (uri == null) return;
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              },
              styleSheet: MarkdownStyleSheet(
                p: TextStyle(
                  fontSize: 14,
                  height: 1.55,
                  color: AppColors.preto,
                ),
                h1: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.azul,
                  height: 1.3,
                ),
                h2: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: AppColors.azul,
                  height: 1.4,
                ),
                h3: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.azul,
                  height: 1.4,
                ),
                h1Padding: const EdgeInsets.only(top: 4, bottom: 8),
                h2Padding: const EdgeInsets.only(top: 18, bottom: 6),
                h3Padding: const EdgeInsets.only(top: 12, bottom: 4),
                listBullet: TextStyle(
                  fontSize: 14,
                  color: AppColors.preto,
                ),
                strong: const TextStyle(fontWeight: FontWeight.w700),
                em: const TextStyle(fontStyle: FontStyle.italic),
                a: TextStyle(
                  color: AppColors.verde,
                  decoration: TextDecoration.underline,
                ),
                blockquote: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: AppColors.textoSecundario,
                ),
                blockquoteDecoration: BoxDecoration(
                  color: AppColors.verde.withValues(alpha: 0.06),
                  border: Border(
                    left: BorderSide(color: AppColors.verde, width: 3),
                  ),
                ),
                blockquotePadding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                code: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  backgroundColor: Colors.grey.shade100,
                ),
                horizontalRuleDecoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: AppColors.bordas, width: 1),
                  ),
                ),
              ),
            ),
    );
  }
}
