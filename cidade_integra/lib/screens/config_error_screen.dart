import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_theme.dart';

/// Tela exibida quando o app é executado sem os segredos necessários
/// (Supabase, Google Sign-In, etc.). Substitui o crash silencioso que
/// deixava o usuário preso em uma tela em branco do Android.
class ConfigErrorScreen extends StatelessWidget {
  final List<String> missing;

  const ConfigErrorScreen({super.key, required this.missing});

  static const _command = './scripts/setup_env.sh && ./scripts/run.sh';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: Scaffold(
        backgroundColor: AppColors.verde,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 480),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 18,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: AppColors.vermelho,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Configuração ausente',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.azul,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'O app foi compilado sem os segredos necessários '
                      'para se conectar ao Supabase e ao Google Sign-In.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: AppColors.preto,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Variáveis faltando:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.azul,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ...missing.map(
                      (s) => Padding(
                        padding: const EdgeInsets.only(left: 8, bottom: 2),
                        child: Text(
                          '• $s',
                          style: TextStyle(
                            fontSize: 13,
                            fontFamily: 'monospace',
                            color: AppColors.vermelho,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Como resolver',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.azul,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'No terminal, na raiz do projeto, execute:',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textoSecundario,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.bordas),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: SelectableText(
                              _command,
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Copiar',
                            icon: const Icon(Icons.copy, size: 18),
                            onPressed: () {
                              Clipboard.setData(
                                const ClipboardData(text: _command),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Comando copiado!'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Em produção, esses segredos são injetados pelo '
                      'pipeline de build via --dart-define-from-file.',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: AppColors.textoSecundario,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
