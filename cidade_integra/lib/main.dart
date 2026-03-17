import 'package:flutter/material.dart';

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
      home: const Scaffold(
        body: Center(child: Text('Cidade Integra')),
      ),
    );
  }
}
