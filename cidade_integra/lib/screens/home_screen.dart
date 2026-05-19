import 'package:flutter/material.dart';
import '../utils/refresh_scope.dart';
import '../widgets/home/hero_section.dart';
import '../widgets/home/stats_section.dart';
import '../widgets/home/categories_section.dart';
import '../widgets/home/how_it_works_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Key _statsKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    RefreshScope.register(() async {
      setState(() => _statsKey = UniqueKey());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const HeroSection(),
        StatsSection(key: _statsKey),
        const CategoriesSection(),
        const HowItWorksSection(),
      ],
    );
  }
}
