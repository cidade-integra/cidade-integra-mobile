import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/refresh_scope.dart';
import '../../utils/scroll_to_top.dart';
import 'app_bottom_nav.dart';
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
  bool? _wasLoggedIn;

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

  void _onAuthChange(AuthProvider auth) {
    final isLogged = auth.isLoggedIn;
    if (_wasLoggedIn == null) {
      _wasLoggedIn = isLogged;
      return;
    }
    if (_wasLoggedIn == isLogged) return;
    _wasLoggedIn = isLogged;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final messenger = ScaffoldMessenger.maybeOf(context);
      if (messenger == null) return;
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            isLogged
                ? 'Bem-vindo(a), ${auth.user?.displayName ?? "usuário"}!'
                : 'Você saiu da sua conta.',
          ),
          backgroundColor:
              isLogged ? AppColors.verde : AppColors.textoSecundario,
          duration: const Duration(seconds: 2),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    _onAuthChange(auth);

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
        bottomNavigationBar: const AppBottomNav(),
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
                const SizedBox(height: 32),
                const AppFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
