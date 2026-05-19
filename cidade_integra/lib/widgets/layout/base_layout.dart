import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../utils/refresh_scope.dart';
import 'app_navbar.dart';
import 'app_drawer.dart';
import 'app_footer.dart';
import 'email_verification_banner.dart';

class BaseLayout extends StatelessWidget {
  final Widget child;
  const BaseLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        final loc = GoRouterState.of(context).uri.toString();
        if (loc == '/') {
          SystemNavigator.pop();
        } else if (context.canPop()) {
          context.pop();
        } else {
          context.go('/');
        }
      },
      child: Scaffold(
        appBar: const AppNavbar(),
        drawer: const AppDrawer(),
        body: RefreshIndicator(
          onRefresh: RefreshScope.trigger,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const EmailVerificationBanner(),
                child,
                const AppFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
