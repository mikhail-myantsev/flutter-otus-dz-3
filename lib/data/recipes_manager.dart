import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/comment.dart';
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

  /// Идентификаторы избранных рецептов
  final Set<int> _favoriteIds = {};

  /// Входит ли рецепт в избранное
  bool isFavorite(int recipeId) => _favoriteIds.contains(recipeId);

  /// Переключает отметку избранного рецепта
  void toggleFavorite(int recipeId) {
    if (isFavorite(recipeId)) {
      _favoriteIds.remove(recipeId);
    } else {
      _favoriteIds.add(recipeId);
    }

    notifyListeners();
  }

  /// Комментарии к рецепту в порядке добавления
  List<Comment> commentsOf(int recipeId) => List.unmodifiable(_comments[recipeId] ?? const []);

  /// Добавляет комментарий текущего пользователя к рецепту и возвращает его
  Comment addComment(int recipeId, String text) {
    final comment = Comment(author: _currentUser, text: text, date: DateTime.now());
    _comments.putIfAbsent(recipeId, () => []).add(comment);

    notifyListeners();

    return comment;
  }

  // TODO: После подключения сервера, будет назначаться им
  int _nextId(Iterable<int> ids) => ids.fold(-1, max) + 1;

  // TODO: Заменить именем авторизованного пользователя
  static const String _currentUser = 'Вы';

  static const MeasureUnit _tablespoon = MeasureUnit(id: 0, one: 'ст. ложка', few: 'ст. ложки', many: 'ст. ложек');
  static const MeasureUnit _teaspoon = MeasureUnit(id: 1, one: 'ч. ложка', few: 'ч. ложки', many: 'ч. ложек');
  static const MeasureUnit _gram = MeasureUnit(id: 2, one: 'грамм', few: 'грамма', many: 'граммов');
  static const MeasureUnit _piece = MeasureUnit(id: 3, one: 'штука', few: 'штуки', many: 'штук');
  static const MeasureUnit _glass = MeasureUnit(id: 4, one: 'стакан', few: 'стакана', many: 'стаканов');
  static const MeasureUnit _clove = MeasureUnit(id: 5, one: 'зубчик', few: 'зубчика', many: 'зубчиков');
  static const MeasureUnit _pinch = MeasureUnit(id: 6, one: 'щепотка', few: 'щепотки', many: 'щепоток');

  final List<MeasureUnit> _measureUnits = const [_tablespoon, _teaspoon, _gram, _piece, _glass, _clove, _pinch];

  static const Ingredient _soySauce = Ingredient(id: 0, name: 'Соевый соус', measureUnit: _tablespoon);
  static const Ingredient _chickenFillet = Ingredient(id: 1, name: 'Куриное филе', measureUnit: _gram);
  static const Ingredient _honey = Ingredient(id: 2, name: 'Мёд', measureUnit: _tablespoon);
  static const Ingredient _garlic = Ingredient(id: 3, name: 'Чеснок', measureUnit: _clove);
  static const Ingredient _rice = Ingredient(id: 4, name: 'Рис', measureUnit: _glass);
  static const Ingredient _tomato = Ingredient(id: 5, name: 'Помидор', measureUnit: _piece);
  static const Ingredient _tofu = Ingredient(id: 6, name: 'Сыр тофу', measureUnit: _gram);
  static const Ingredient _oliveOil = Ingredient(id: 7, name: 'Оливковое масло', measureUnit: _tablespoon);
  static const Ingredient _lemonJuice = Ingredient(id: 8, name: 'Лимонный сок', measureUnit: _tablespoon);
  static const Ingredient _ginger = Ingredient(id: 9, name: 'Имбирь', measureUnit: _gram);
  static const Ingredient _water = Ingredient(id: 10, name: 'Вода', measureUnit: _tablespoon);
  static const Ingredient _brownSugar = Ingredient(id: 11, name: 'Коричневый сахар', measureUnit: _tablespoon);
  static const Ingredient _gratedGinger = Ingredient(id: 12, name: 'Тёртый свежий имбирь', measureUnit: _tablespoon);
  static const Ingredient _cornStarch = Ingredient(id: 13, name: 'Кукурузный крахмал', measureUnit: _tablespoon);
  static const Ingredient _vegetableOil = Ingredient(id: 14, name: 'Растительное масло', measureUnit: _teaspoon);
  static const Ingredient _salmonFillet = Ingredient(id: 15, name: 'Филе лосося', measureUnit: _gram);
  static const Ingredient _sesame = Ingredient(id: 16, name: 'Кунжут', measureUnit: _pinch);
  static const Ingredient _pizzaDough = Ingredient(id: 17, name: 'Тесто для пиццы', measureUnit: _gram);
  static const Ingredient _tomatoSauce = Ingredient(id: 18, name: 'Соус томатный', measureUnit: _gram);
  static const Ingredient _mozzarella = Ingredient(id: 19, name: 'Сыр Моцарелла', measureUnit: _gram);
  static const Ingredient _basil = Ingredient(id: 20, name: 'Базилик зелёный', measureUnit: _piece);

  /// Стартовый каталог
  final List<Ingredient> _ingredients = const [
    _soySauce,
    _chickenFillet,
    _honey,
    _garlic,
    _rice,
    _tomato,
    _tofu,
    _oliveOil,
    _lemonJuice,
    _ginger,
    _water,
    _brownSugar,
    _gratedGinger,
    _cornStarch,
    _vegetableOil,
    _salmonFillet,
    _sesame,
    _pizzaDough,
    _tomatoSauce,
    _mozzarella,
    _basil,
  ].toList();

  /// Тестовый набор данных
  final List<Recipe> _recipes = const [
    Recipe(
      id: 0,
      name: 'Лосось в соусе терияки',
      duration: 45,
      photo: 'assets/images/recipe_0.jpg',
      ingredients: [
        RecipeIngredient(count: 8, ingredient: _soySauce),
        RecipeIngredient(count: 8, ingredient: _water),
        RecipeIngredient(count: 3, ingredient: _honey),
        RecipeIngredient(count: 2, ingredient: _brownSugar),
        RecipeIngredient(count: 3, ingredient: _garlic),
        RecipeIngredient(count: 1, ingredient: _gratedGinger),
        RecipeIngredient(count: 1.5, ingredient: _lemonJuice),
        RecipeIngredient(count: 1, ingredient: _cornStarch),
        RecipeIngredient(count: 1, ingredient: _vegetableOil),
        RecipeIngredient(count: 680, ingredient: _salmonFillet),
        RecipeIngredient(count: 1, ingredient: _sesame),
      ],
      steps: [
        RecipeStep(
          name:
              'В маленькой кастрюле соедините соевый соус, 6 столовых ложек воды, мёд, сахар, '
              'измельчённый чеснок, имбирь и лимонный сок.',
          duration: 330,
        ),
        RecipeStep(name: 'Поставьте на средний огонь и, помешивая, доведите до лёгкого кипения.', duration: 420),
        RecipeStep(name: 'Смешайте оставшуюся воду с крахмалом. Добавьте в кастрюлю и перемешайте.', duration: 360),
        RecipeStep(
          name: 'Готовьте, непрерывно помешивая венчиком, 1 минуту. Снимите с огня и немного остудите.',
          duration: 90,
        ),
        RecipeStep(name: 'Смажьте форму маслом и выложите туда рыбу. Полейте её соусом.', duration: 360),
        RecipeStep(name: 'Поставьте в разогретую до 200 °C духовку примерно на 15 минут.', duration: 900),
        RecipeStep(name: 'Перед подачей полейте соусом из формы и посыпьте кунжутом.', duration: 240),
      ],
    ),
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
    Recipe(
      id: 6,
      name: 'Пицца Маргарита домашняя',
      duration: 25,
      photo: 'assets/images/recipe_6.jpg',
      ingredients: [
        RecipeIngredient(count: 300, ingredient: _pizzaDough),
        RecipeIngredient(count: 130, ingredient: _tomatoSauce),
        RecipeIngredient(count: 180, ingredient: _mozzarella),
        RecipeIngredient(count: 1, ingredient: _tomato),
        RecipeIngredient(count: 1, ingredient: _basil),
        RecipeIngredient(count: 1, ingredient: _oliveOil),
      ],
      steps: [
        RecipeStep(
          name:
              'Тесто для пиццы раскатываем толщиной 2-3 мм, диаметром 32-35 см. Для того, чтобы получить '
              'красивые бортики на пицце, загибаем края по 2-3 см внутрь и хорошо залепляем, '
              'чтобы при выпекании они не отклеились.',
          duration: 60,
        ),
        RecipeStep(
          name:
              'Кладём на раскатанную основу томатный соус, пусть его будет побольше, особенно если вы '
              'используете не кетчуп или томатную пасту, а соус из помидоров.',
          duration: 60,
        ),
        RecipeStep(name: 'Равномерно распределяем соус по тесту, поливаем сверху оливковым маслом.', duration: 60),
        RecipeStep(
          name:
              'Духовку разогреваем до максимальной температуры (250-270 °C), ставим перевёрнутый противень '
              'с тестом на нижний уровень и выпекаем в течение 5-10 минут.',
          duration: 600,
        ),
        RecipeStep(name: 'Пока запекается корж, нарезаем моцареллу пластинами 5-10 мм толщиной.', duration: 60),
        RecipeStep(name: 'Нарезаем помидор ломтиками 3-5 мм.', duration: 60),
        RecipeStep(
          name:
              'Кладём сыр, помидоры и базилик на основу, ставим в духовку еще на 10 минут. '
              'Пицца готова, когда сыр расплавится.',
          duration: 600,
        ),
      ],
    ),
  ].toList();

  /// Комментарии к рецептам по идентификатору рецепта
  final Map<int, List<Comment>> _comments = {
    0: [
      Comment(
        author: 'anna_obraztsova',
        text: 'Я не большой любитель рыбы, но решила приготовить по этому рецепту и просто влюбилась!',
        date: DateTime(2022, 5, 25),
        avatar: 'assets/images/avatar_0.png',
        photo: 'assets/images/comment_0.jpg',
      ),
    ],
    6: [
      Comment(
        author: 'maxprimerov',
        text: 'Идеальный холостяцкий ужин',
        date: DateTime(2022, 5, 21),
        avatar: 'assets/images/avatar_1.png',
        photo: 'assets/images/comment_1.jpg',
      ),
    ],
  };
}
