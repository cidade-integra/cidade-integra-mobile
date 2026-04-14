import 'package:flutter/material.dart';
import '../../models/app_user.dart';
import '../../utils/app_theme.dart';
import '../../utils/badge_rules.dart' as rules;

class BadgesDisplay extends StatelessWidget {
  final AppUser user;
  const BadgesDisplay({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final earned = rules.getUserBadges(user);
    final earnedIds = earned.map((b) => b.id).toSet();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.branco,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.bordas),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events_outlined, size: 20, color: AppColors.azul),
              const SizedBox(width: 8),
              Text(
                'Conquistas',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.azul,
                ),
              ),
              const Spacer(),
              Text(
                '${earned.length}/${rules.badgeRules.length}',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textoSecundario,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: rules.badgeRules.map((badge) {
              final isEarned = earnedIds.contains(badge.id);
              return _BadgeChip(badge: badge, earned: isEarned);
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  final rules.Badge badge;
  final bool earned;

  const _BadgeChip({required this.badge, required this.earned});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: earned ? 1.0 : 0.35,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: earned
              ? badge.color.withValues(alpha: 0.1)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: earned
                ? badge.color.withValues(alpha: 0.3)
                : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              badge.icon,
              size: 16,
              color: earned ? badge.color : Colors.grey,
            ),
            const SizedBox(width: 6),
            Text(
              badge.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: earned ? badge.color : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
