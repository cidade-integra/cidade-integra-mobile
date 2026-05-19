import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:go_router/go_router.dart';
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
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Text(
                _content!,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: AppColors.preto,
                ),
              ),
            ),
    );
  }
}
