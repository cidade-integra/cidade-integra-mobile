import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class AppNavbar extends StatelessWidget implements PreferredSizeWidget {
  const AppNavbar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.azul,
      foregroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.menu),
        tooltip: 'Menu',
        onPressed: () => Scaffold.of(context).openDrawer(),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.verde,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.location_city, size: 20, color: Colors.white),
          ),
          const SizedBox(width: 8),
          const Text(
            'Cidade Integra',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
        ],
      ),
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 2,
    );
  }
}
