import 'package:flutter/material.dart';
import '../models/app_user.dart';

class Badge {
  final String id;
  final String label;
  final IconData icon;
  final Color color;
  final bool Function(AppUser user) condition;

  const Badge({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
    required this.condition,
  });
}

final badgeRules = [
  Badge(
    id: 'iniciante',
    label: 'Iniciante',
    icon: Icons.eco,
    color: const Color(0xFF2ECC71),
    condition: (u) => u.score >= 0 && u.score < 100,
  ),
  Badge(
    id: 'engajado',
    label: 'Engajado',
    icon: Icons.local_fire_department,
    color: const Color(0xFFF39C12),
    condition: (u) => u.score >= 100 && u.score < 500,
  ),
  Badge(
    id: 'vigilante',
    label: 'Vigilante Urbano',
    icon: Icons.shield,
    color: const Color(0xFF3498DB),
    condition: (u) => u.score >= 500,
  ),
  Badge(
    id: 'reportador_frequente',
    label: 'Reportador Frequente',
    icon: Icons.campaign,
    color: const Color(0xFF9B59B6),
    condition: (u) => u.reportCount >= 20,
  ),
  Badge(
    id: 'verificado',
    label: 'Usuário Verificado',
    icon: Icons.verified,
    color: const Color(0xFF1ABC9C),
    condition: (u) => u.verified,
  ),
];

List<Badge> getUserBadges(AppUser user) {
  return badgeRules.where((b) => b.condition(user)).toList();
}
