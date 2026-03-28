import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../utils/app_theme.dart';

class AppNavbar extends StatelessWidget implements PreferredSizeWidget {
  const AppNavbar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.azul,
      foregroundColor: Colors.white,
      automaticallyImplyLeading: false,
      toolbarHeight: 70,
      titleSpacing: 16,
      title: GestureDetector(
        onTap: () => context.go('/'),
        child: SvgPicture.asset(
          'assets/images/logotipo-sem-borda.svg',
          height: 60,
        ),
      ),
      centerTitle: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.menu, size: 28),
          tooltip: 'Menu',
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        const SizedBox(width: 8),
      ],
      elevation: 0,
      scrolledUnderElevation: 2,
    );
  }
}
