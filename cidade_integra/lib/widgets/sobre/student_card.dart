import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/equipe.dart';
import '../../utils/app_theme.dart';

class StudentCard extends StatelessWidget {
  final TeamMember member;
  const StudentCard({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 44,
              backgroundColor: AppColors.cinza,
              backgroundImage: AssetImage(member.assetImage),
            ),
            const SizedBox(height: 14),
            Text(
              member.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.azul,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.verde.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                member.role,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.verdeEscuro,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              member.description,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textoSecundario,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            if (member.github.isNotEmpty || member.linkedin.isNotEmpty) ...[
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (member.github.isNotEmpty)
                    _SocialButton(
                      icon: Icons.code,
                      tooltip: 'GitHub',
                      onTap: () => _open(member.github),
                    ),
                  if (member.github.isNotEmpty && member.linkedin.isNotEmpty)
                    const SizedBox(width: 12),
                  if (member.linkedin.isNotEmpty)
                    _SocialButton(
                      icon: Icons.person,
                      tooltip: 'LinkedIn',
                      onTap: () => _open(member.linkedin),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

Future<void> _open(String url) async {
  final uri = Uri.parse(url);
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _SocialButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.azul.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: AppColors.azul),
        ),
      ),
    );
  }
}
