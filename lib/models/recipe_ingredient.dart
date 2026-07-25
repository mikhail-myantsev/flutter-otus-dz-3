import 'ingredient.dart';

/// Ингредиент в составе рецепта
class RecipeIngredient {
  const RecipeIngredient({required this.count, required this.ingredient});

  /// Количество в единицах измерения ингредиента
  final int count;

  /// Ингредиент из каталога
  final Ingredient ingredient;
}
