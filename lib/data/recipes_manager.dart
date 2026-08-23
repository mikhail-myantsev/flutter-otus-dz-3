import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../api/food_api.dart';
import '../models/comment.dart';
import '../models/food_data.dart';
import '../models/ingredient.dart';
import '../models/measure_unit.dart';
import '../models/recipe.dart';
import '../models/recipe_ingredient.dart';
import '../models/recipe_step.dart';
import 'recipes_store.dart';

/// Точка доступа к рецептам, каталогу ингредиентов и единицам измерения, уведомляющая слушателей об изменении данных
///
/// Сервер является источником данных, а локальное хранилище является источником истины для интерфейса.
/// Загрузка обновляет хранилище, интерфейс показывает сохранённое, и без сети приложение работает на локальных данных
class RecipesManager extends ChangeNotifier {
  RecipesManager({required this._api, required this._store});

  // TODO: Заменить именем авторизованного пользователя
  static const String _currentUser = 'Вы';

  final FoodApi _api;
  final RecipesStore _store;

  List<Recipe> _recipes = [];
  List<Ingredient> _ingredients = [];
  List<MeasureUnit> _measureUnits = [];

  /// Кэш комментариев по идентификатору рецепта
  final Map<int, List<Comment>> _comments = {};

  /// Идентификаторы избранных рецептов
  Set<int> _favoriteIds = {};

  bool _isLoading = true;

  /// Идёт первая загрузка данных
  bool get isLoading => _isLoading;

  /// **Все** доступные рецепты
  List<Recipe> get recipes => List.unmodifiable(_recipes);

  /// Каталог ингредиентов
  List<Ingredient> get ingredients => List.unmodifiable(_ingredients);

  /// Справочник единиц измерения
  List<MeasureUnit> get measureUnits => List.unmodifiable(_measureUnits);

  /// Показывает сохранённые данные и обновляет их с сервера
  ///
  /// Ответ сервера сохраняется в локальную базу, если не выглядит потерей данных
  Future<void> init() async {
    // Локальное хранилище читается синхронно, поэтому первый кадр рисуется без ожидания сети
    _favoriteIds = _store.loadFavoriteIds();
    _reload();
    notifyListeners();

    try {
      // Ответ сервера сначала попадает в хранилище и только оттуда в интерфейс
      final data = await _tryRemote(_api.fetchFoodData);
      if (data != null && _isSafeToReplace(data)) {
        await _store.saveAll(data);
        _reload();
      }
    } finally {
      // Ожидание закончено при любом исходе, включая отказ записи на диск, иначе остался бы вечный индикатор
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Добавляет в каталог новый ингредиент и возвращает его
  ///
  /// Без сети ингредиент получает локальный отрицательный идентификатор
  Future<Ingredient> addIngredient(String name, MeasureUnit measureUnit) async {
    final ingredient =
        await _tryRemote(() => _api.createIngredient(name, measureUnit)) ??
        Ingredient(id: _nextLocalId(_ingredients.map((i) => i.id)), name: name, measureUnit: measureUnit);

    _ingredients.add(ingredient);
    await _store.putIngredient(ingredient);
    notifyListeners();

    return ingredient;
  }

  /// Сохраняет новый рецепт и возвращает его
  ///
  /// Время приготовления является суммой длительностей шагов, округлённой вверх до минут.
  /// Рецепт в любом случае сохраняется локально.
  /// Без сети рецепт получает локальный отрицательный идентификатор, чтобы синхронизация его не перезаписала
  Future<Recipe> saveRecipe({
    required String name,
    required List<RecipeIngredient> ingredients,
    required List<RecipeStep> steps,
  }) async {
    final totalSeconds = steps.fold(0, (sum, step) => sum + step.duration);
    final duration = (totalSeconds / 60).ceil();

    // Ингредиент, созданный без сети, серверу неизвестен
    final isKnownToServer = ingredients.every((item) => item.ingredient.id >= 0);
    final remote = isKnownToServer
        ? await _tryRemote(
            () => _api.createRecipe(name: name, duration: duration, ingredients: ingredients, steps: steps),
          )
        : null;
    final recipe =
        remote ??
        Recipe(
          id: _nextLocalId(_recipes.map((r) => r.id)),
          name: name,
          duration: duration,
          // TODO: Загрузка фото ещё не реализована
          photo: '',
          ingredients: List.unmodifiable(ingredients),
          steps: List.unmodifiable(steps),
        );

    _recipes
      ..add(recipe)
      ..sort(_compareRecipes);
    await _store.putRecipe(recipe);
    notifyListeners();

    return recipe;
  }

  /// Входит ли рецепт в избранное
  bool isFavorite(int recipeId) => _favoriteIds.contains(recipeId);

  /// Переключает отметку избранного рецепта
  void toggleFavorite(int recipeId) {
    final isNowFavorite = !isFavorite(recipeId);
    if (isNowFavorite) {
      _favoriteIds.add(recipeId);
    } else {
      _favoriteIds.remove(recipeId);
    }

    unawaited(_store.saveFavorite(recipeId, isNowFavorite));
    notifyListeners();
  }

  /// Комментарии к рецепту в порядке добавления
  List<Comment> commentsOf(int recipeId) => List.unmodifiable(_commentsOf(recipeId));

  /// Добавляет комментарий текущего пользователя к рецепту и возвращает его
  Comment addComment(int recipeId, String text) {
    final comment = Comment(author: _currentUser, text: text, date: DateTime.now());
    final comments = _commentsOf(recipeId)..add(comment);

    unawaited(_store.saveComments(recipeId, comments));
    notifyListeners();

    return comment;
  }

  /// Изменяемый список комментариев из кэша
  List<Comment> _commentsOf(int recipeId) => _comments.putIfAbsent(recipeId, () => _store.loadComments(recipeId));

  /// Перечитывает данные из хранилища
  void _reload() {
    _recipes = _store.loadRecipes()..sort(_compareRecipes);
    _ingredients = _store.loadIngredients();
    _measureUnits = _store.loadMeasureUnits();
  }

  /// Выполняет запрос к серверу и возвращает `null`, если он недоступен или ответил неожиданными данными
  ///
  /// Ловится только `Exception`, чтобы намеренно падать на всех остальных
  static Future<T?> _tryRemote<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on Exception catch (error) {
      debugPrint('Запрос к серверу не удался. $error');
      return null;
    }
  }

  /// Стоит ли замещать сохранённое ответом сервера
  ///
  /// Разбор терпим к битым записям, и пустой набор поверх непустого кэша не применяется
  bool _isSafeToReplace(FoodData data) =>
      (data.recipes.isNotEmpty || _recipes.isEmpty) &&
      (data.ingredients.isNotEmpty || _ingredients.isEmpty) &&
      (data.measureUnits.isNotEmpty || _measureUnits.isEmpty);

  /// Локальный идентификатор для созданного без сети, например `−1`
  ///
  /// Отрицательные значения не пересекаются с серверными, поэтому синхронизация не перезапишет созданное оффлайн
  int _nextLocalId(Iterable<int> ids) => ids.fold(0, min) - 1;

  /// Серверные рецепты по возрастанию идентификатора, затем локальные в порядке создания
  static int _compareRecipes(Recipe a, Recipe b) {
    final aLocal = a.id < 0;
    if (aLocal != (b.id < 0)) {
      return aLocal ? 1 : -1;
    }

    return aLocal ? b.id.compareTo(a.id) : a.id.compareTo(b.id);
  }
}
