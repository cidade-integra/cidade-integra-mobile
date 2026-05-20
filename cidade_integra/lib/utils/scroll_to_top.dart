import 'package:flutter/material.dart';

/// Mantém uma referência global ao ScrollController do BaseLayout
/// para permitir que widgets como o footer disparem scroll-to-top
/// após uma navegação.
class ScrollToTop {
  ScrollToTop._();

  static ScrollController? controller;

  static void trigger() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final c = controller;
      if (c == null || !c.hasClients) return;
      c.animateTo(
        0,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    });
  }
}
