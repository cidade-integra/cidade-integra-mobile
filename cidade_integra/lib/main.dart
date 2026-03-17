import 'package:flutter/material.dart';
import 'utils/app_theme.dart';

void main() {
  runApp(const CidadeIntegraApp());
}

class CidadeIntegraApp extends StatelessWidget {
  const CidadeIntegraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cidade Integra',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const Scaffold(
        body: Center(child: Text('Cidade Integra')),
      ),
    );
  }
}
