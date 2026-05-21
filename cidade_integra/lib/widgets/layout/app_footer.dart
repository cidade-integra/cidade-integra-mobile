import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/app_theme.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final currentYear = DateTime.now().year;

    return Container(
      color: AppColors.azul,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset('assets/images/logotipo-sem-borda.svg', height: 36),
          const SizedBox(height: 10),
          Text(
            'Uma plataforma para cidadãos reportarem problemas urbanos e '
            'contribuírem para uma cidade melhor.',
            style:
                TextStyle(color: AppColors.cinza, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 18),
          Text(
            'Contato',
            style: TextStyle(
              color: AppColors.verde,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'suporte@cidadeintegra.com',
            style: TextStyle(color: AppColors.cinza, fontSize: 13),
          ),
          const SizedBox(height: 18),
          Divider(color: AppColors.cinza.withValues(alpha: 0.3)),
          const SizedBox(height: 12),
          Center(
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(color: AppColors.cinza, fontSize: 12),
                children: [
                  TextSpan(text: '© $currentYear '),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: GestureDetector(
                      onTap: () async {
                        final uri = Uri.parse(
                          'https://github.com/cidade-integra',
                        );
                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      },
                      child: Text(
                        'Cidade Integra',
                        style: TextStyle(
                          color: AppColors.cinza,
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                          decorationColor:
                              AppColors.cinza.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                  const TextSpan(text: '. Todos os direitos reservados.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
