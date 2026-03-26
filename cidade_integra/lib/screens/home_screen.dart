import 'package:flutter/material.dart';
import '../widgets/home/hero_section.dart';
import '../widgets/home/stats_section.dart';
import '../widgets/home/categories_section.dart';
import '../widgets/home/how_it_works_section.dart';
import '../widgets/layout/app_footer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        children: [
          HeroSection(),
          StatsSection(),
          CategoriesSection(),
          HowItWorksSection(),
          AppFooter(),
        ],
      ),
    );
  }
}
