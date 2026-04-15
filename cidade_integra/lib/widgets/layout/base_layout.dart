import 'package:flutter/material.dart';
import 'app_navbar.dart';
import 'app_drawer.dart';
import 'app_footer.dart';

class BaseLayout extends StatelessWidget {
  final Widget child;
  const BaseLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppNavbar(),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            child,
            const AppFooter(),
          ],
        ),
      ),
    );
  }
}
