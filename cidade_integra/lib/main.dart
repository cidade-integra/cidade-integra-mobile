import 'package:flutter/material.dart';
import 'utils/app_theme.dart';
import 'routes/app_router.dart';

void main() {
  runApp(const CidadeIntegraApp());
}

class CidadeIntegraApp extends StatelessWidget {
  const CidadeIntegraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Cidade Integra',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}
