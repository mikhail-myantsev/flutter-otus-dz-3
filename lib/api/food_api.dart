import '../models/food_data.dart';
import '../models/ingredient.dart';
import '../models/measure_unit.dart';
import '../models/recipe.dart';
import '../models/recipe_ingredient.dart';
import '../models/recipe_step.dart';

/// API рецептов
///
/// Методы бросают исключение при недоступности сервера для возможности переключения на локальные данные
abstract interface class FoodApi {
  /// Загружает рецепты с составом и шагами вместе с каталогами
  Future<FoodData> fetchFoodData();

  /// Создаёт рецепт на сервере и возвращает его с присвоенным идентификатором
  Future<Recipe> createRecipe({
    required String name,
    required int duration,
    required List<RecipeIngredient> ingredients,
    required List<RecipeStep> steps,
  });

  /// Создаёт ингредиент каталога на сервере и возвращает его с присвоенным идентификатором
  Future<Ingredient> createIngredient(String name, MeasureUnit measureUnit);
}
