import 'package:flutter/material.dart';

class CategoryItem {
  final IconData icon;
  final String title;
  final String description;
  final String value;

  const CategoryItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.value,
  });
}

const categories = [
  CategoryItem(
    icon: Icons.water_drop,
    title: 'Vazamentos',
    description: 'Problemas com água e esgoto, vazamentos e enchentes',
    value: 'vazamentos',
  ),
  CategoryItem(
    icon: Icons.lightbulb,
    title: 'Iluminação',
    description: 'Postes com problemas ou áreas sem iluminação adequada',
    value: 'iluminacao',
  ),
  CategoryItem(
    icon: Icons.circle_outlined,
    title: 'Buracos',
    description: 'Buracos em ruas, calçadas e outros espaços públicos',
    value: 'buracos',
  ),
  CategoryItem(
    icon: Icons.delete_outline,
    title: 'Lixo',
    description: 'Acúmulo de lixo, problemas na coleta ou descarte irregular',
    value: 'lixo',
  ),
  CategoryItem(
    icon: Icons.park,
    title: 'Áreas Verdes',
    description: 'Manutenção de praças, parques e áreas verdes',
    value: 'areas-verdes',
  ),
  CategoryItem(
    icon: Icons.warning_amber,
    title: 'Outros',
    description: 'Demais problemas urbanos que precisam de atenção',
    value: 'outros',
  ),
];
