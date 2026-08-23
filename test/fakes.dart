import 'package:recipes/api/food_api.dart';
import 'package:recipes/data/recipes_store.dart';
import 'package:recipes/models/comment.dart';
import 'package:recipes/models/food_data.dart';
import 'package:recipes/models/ingredient.dart';
import 'package:recipes/models/measure_unit.dart';
import 'package:recipes/models/recipe.dart';
import 'package:recipes/models/recipe_ingredient.dart';
import 'package:recipes/models/recipe_step.dart';

/// Сетевой API для тестов
///
/// При [offline] каждый метод бросает исключение, как настоящий клиент без сети
class FakeFoodApi implements FoodApi {
  FakeFoodApi({FoodData? data, this.offline = false})
    : data = data ?? const FoodData(recipes: [], ingredients: [], measureUnits: []);

  /// Данные, отдаваемые [fetchFoodData]
  FoodData data;

  /// Имитация отсутствия сети
  bool offline;

  /// Идентификатор, присваиваемый следующему созданному объекту
  int nextId = 100;

  /// Сколько раз запрашивали создание рецепта
  int createRecipeCalls = 0;

  /// Искусственная задержка ответа для тестов, проверяющих поведение во время ожидания
  Duration delay = Duration.zero;

  @override
  Future<FoodData> fetchFoodData() async {
    _throwIfOffline();
    return data;
  }

  @override
  Future<Recipe> createRecipe({
    required String name,
    required int duration,
    required List<RecipeIngredient> ingredients,
    required List<RecipeStep> steps,
  }) async {
    createRecipeCalls++;
    // Таймер заводим только когда тест сам его прокачает
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }

    _throwIfOffline();
    return Recipe(
      id: nextId++,
      name: name,
      duration: duration,
      photo: '',
      ingredients: List.unmodifiable(ingredients),
      steps: List.unmodifiable(steps),
    );
  }

  @override
  Future<Ingredient> createIngredient(String name, MeasureUnit measureUnit) async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }

    _throwIfOffline();
    return Ingredient(id: nextId++, name: name, measureUnit: measureUnit);
  }

  void _throwIfOffline() {
    if (offline) {
      throw Exception('сеть недоступна');
    }
  }
}

/// Хранилище в памяти для тестов
class InMemoryRecipesStore implements RecipesStore {
  InMemoryRecipesStore({
    List<Recipe> recipes = const [],
    List<Ingredient> ingredients = const [],
    List<MeasureUnit> measureUnits = const [],
    Map<int, List<Comment>> comments = const {},
    Set<int> favoriteIds = const {},
    this.failOnSaveAll = false,
  }) : _recipes = {for (final recipe in recipes) recipe.id: recipe},
       _ingredients = {for (final item in ingredients) item.id: item},
       _measureUnits = {for (final unit in measureUnits) unit.id: unit},
       _comments = {
         for (final entry in comments.entries) entry.key: [...entry.value],
       },
       _favoriteIds = {...favoriteIds};

  final Map<int, Recipe> _recipes;
  final Map<int, Ingredient> _ingredients;
  final Map<int, MeasureUnit> _measureUnits;
  final Map<int, List<Comment>> _comments;
  final Set<int> _favoriteIds;

  @override
  List<Recipe> loadRecipes() => _recipes.values.toList();

  @override
  List<Ingredient> loadIngredients() => _ingredients.values.toList();

  @override
  List<MeasureUnit> loadMeasureUnits() => _measureUnits.values.toList();

  @override
  List<Comment> loadComments(int recipeId) => [...?_comments[recipeId]];

  @override
  Set<int> loadFavoriteIds() => {..._favoriteIds};

  /// Имитация отказа записи на диск
  final bool failOnSaveAll;

  @override
  Future<void> saveAll(FoodData data) async {
    if (failOnSaveAll) {
      throw StateError('запись в хранилище не удалась');
    }

    _recipes.removeWhere((id, _) => id >= 0);
    _recipes.addAll({for (final recipe in data.recipes) recipe.id: recipe});
    _ingredients.removeWhere((id, _) => id >= 0);
    _ingredients.addAll({for (final item in data.ingredients) item.id: item});
    _measureUnits.removeWhere((id, _) => id >= 0);
    _measureUnits.addAll({for (final unit in data.measureUnits) unit.id: unit});
  }

  @override
  Future<void> putRecipe(Recipe recipe) async => _recipes[recipe.id] = recipe;

  @override
  Future<void> putIngredient(Ingredient ingredient) async => _ingredients[ingredient.id] = ingredient;

  @override
  Future<void> saveComments(int recipeId, List<Comment> comments) async => _comments[recipeId] = [...comments];

  @override
  Future<void> saveFavorite(int recipeId, bool isFavorite) async {
    if (isFavorite) {
      _favoriteIds.add(recipeId);
    } else {
      _favoriteIds.remove(recipeId);
    }
  }
}
