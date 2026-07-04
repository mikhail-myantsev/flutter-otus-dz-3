import 'package:flutter/material.dart';

import 'data/recipes_manager.dart';
import 'screens/recipes_page.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const App(manager: RecipesManager()));
}

class App extends StatelessWidget {
  const App({super.key, required this.manager});

  /// Источник рецептов
  final RecipesManager manager;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Otus.Food',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: RecipesPage(recipes: manager.getRecipes()),
    );
  }
}
