import 'package:flutter/material.dart';

import '../models/recipe.dart';
import '../widgets/recipe_card.dart';

/// Экран рецептов с прокручиваемым списком карточек
class RecipesPage extends StatelessWidget {
  const RecipesPage({super.key, required this.recipes});

  /// Рецепты
  final List<Recipe> recipes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Рецепты')),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        itemCount: recipes.length,
        separatorBuilder: (context, index) => const SizedBox(height: 24),
        itemBuilder: (context, index) => RecipeCard(recipe: recipes[index]),
      ),
    );
  }
}
