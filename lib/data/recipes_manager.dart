import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/ingredient.dart';
import '../models/measure_unit.dart';
import '../models/recipe.dart';
import '../models/recipe_ingredient.dart';
import '../models/recipe_step.dart';

// TODO: Заменить данными с сервера
/// Точка доступа к рецептам, каталогу ингредиентов и единицам измерения
///
/// Уведомляет слушателей о каждом изменении данных
class RecipesManager extends ChangeNotifier {
  /// **Все** доступные рецепты
  List<Recipe> get recipes => List.unmodifiable(_recipes);

  /// Каталог ингредиентов
  List<Ingredient> get ingredients => List.unmodifiable(_ingredients);

  /// Справочник единиц измерения
  List<MeasureUnit> get measureUnits => List.unmodifiable(_measureUnits);

  /// Добавляет в каталог новый ингредиент и возвращает его
  Ingredient addIngredient(String name, MeasureUnit measureUnit) {
    final ingredient = Ingredient(id: _nextId(_ingredients.map((i) => i.id)), name: name, measureUnit: measureUnit);
    _ingredients.add(ingredient);
    notifyListeners();
    return ingredient;
  }

  /// Сохраняет новый рецепт и возвращает его
  ///
  /// Время приготовления является суммой длительностей шагов, округлённой вверх до минут
  Recipe saveRecipe({
    required String name,
    required List<RecipeIngredient> ingredients,
    required List<RecipeStep> steps,
  }) {
    final totalSeconds = steps.fold(0, (sum, step) => sum + step.duration);
    final recipe = Recipe(
      id: _nextId(_recipes.map((r) => r.id)),
      name: name,
      duration: (totalSeconds / 60).ceil(),
      // TODO: Загрузка фото ещё не реализована
      photo: '',
      ingredients: List.unmodifiable(ingredients),
      steps: List.unmodifiable(steps),
    );
    _recipes.add(recipe);
    notifyListeners();
    return recipe;
  }

  // TODO: После подключения сервера, будет назначаться им
  int _nextId(Iterable<int> ids) => ids.fold(-1, max) + 1;

  static const MeasureUnit _tablespoon = MeasureUnit(id: 0, one: 'ст. ложка', few: 'ст. ложки', many: 'ст. ложек');
  static const MeasureUnit _teaspoon = MeasureUnit(id: 1, one: 'ч. ложка', few: 'ч. ложки', many: 'ч. ложек');
  static const MeasureUnit _gram = MeasureUnit(id: 2, one: 'грамм', few: 'грамма', many: 'граммов');
  static const MeasureUnit _piece = MeasureUnit(id: 3, one: 'штука', few: 'штуки', many: 'штук');
  static const MeasureUnit _glass = MeasureUnit(id: 4, one: 'стакан', few: 'стакана', many: 'стаканов');
  static const MeasureUnit _clove = MeasureUnit(id: 5, one: 'зубчик', few: 'зубчика', many: 'зубчиков');

  final List<MeasureUnit> _measureUnits = const [_tablespoon, _teaspoon, _gram, _piece, _glass, _clove];

  /// Стартовый каталог
  final List<Ingredient> _ingredients = const [
    Ingredient(id: 0, name: 'Соевый соус', measureUnit: _tablespoon),
    Ingredient(id: 1, name: 'Куриное филе', measureUnit: _gram),
    Ingredient(id: 2, name: 'Мёд', measureUnit: _tablespoon),
    Ingredient(id: 3, name: 'Чеснок', measureUnit: _clove),
    Ingredient(id: 4, name: 'Рис', measureUnit: _glass),
    Ingredient(id: 5, name: 'Помидор', measureUnit: _piece),
    Ingredient(id: 6, name: 'Сыр тофу', measureUnit: _gram),
    Ingredient(id: 7, name: 'Оливковое масло', measureUnit: _tablespoon),
    Ingredient(id: 8, name: 'Лимонный сок', measureUnit: _teaspoon),
    Ingredient(id: 9, name: 'Имбирь', measureUnit: _gram),
  ].toList();

  /// Тестовый набор данных
  final List<Recipe> _recipes = const [
    Recipe(id: 0, name: 'Лосось в соусе терияки', duration: 45, photo: 'assets/images/recipe_0.jpg'),
    Recipe(id: 1, name: 'Поке боул с сыром тофу', duration: 30, photo: 'assets/images/recipe_1.jpg'),
    Recipe(
      id: 2,
      name: 'Стейк из говядины по-грузински с кукурузой',
      duration: 75,
      photo: 'assets/images/recipe_2.jpg',
    ),
    Recipe(id: 3, name: 'Тосты с голубикой и бананом', duration: 45, photo: 'assets/images/recipe_3.jpg'),
    Recipe(id: 4, name: 'Паста с морепродуктами', duration: 25, photo: 'assets/images/recipe_4.jpg'),
    Recipe(id: 5, name: 'Бургер с двумя котлетами', duration: 60, photo: 'assets/images/recipe_5.jpg'),
    Recipe(id: 6, name: 'Пицца Маргарита домашняя', duration: 25, photo: 'assets/images/recipe_6.jpg'),
  ].toList();
}
