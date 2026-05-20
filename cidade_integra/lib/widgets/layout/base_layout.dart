import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../utils/refresh_scope.dart';
import '../../utils/scroll_to_top.dart';
import 'app_navbar.dart';
import 'app_drawer.dart';
import 'app_footer.dart';
import 'email_verification_banner.dart';

class BaseLayout extends StatefulWidget {
  final Widget child;
  const BaseLayout({super.key, required this.child});

  @override
  State<BaseLayout> createState() => _BaseLayoutState();
}

class _BaseLayoutState extends State<BaseLayout> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    ScrollToTop.controller = _scrollController;
  }

  @override
  void dispose() {
    if (ScrollToTop.controller == _scrollController) {
      ScrollToTop.controller = null;
    }
    _scrollController.dispose();
    super.dispose();
  }

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
        backgroundColor: Colors.white,
        body: RefreshIndicator(
          onRefresh: RefreshScope.trigger,
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const EmailVerificationBanner(),
                widget.child,
                const AppFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
