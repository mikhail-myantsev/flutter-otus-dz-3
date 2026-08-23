import 'package:flutter_test/flutter_test.dart';
import 'package:recipes/api/food_api.dart';
import 'package:recipes/data/recipes_manager.dart';
import 'package:recipes/models/food_data.dart';
import 'package:recipes/models/ingredient.dart';
import 'package:recipes/models/measure_unit.dart';
import 'package:recipes/models/recipe.dart';
import 'package:recipes/models/recipe_ingredient.dart';
import 'package:recipes/models/recipe_step.dart';

import 'fakes.dart';
import 'fixtures.dart';

void main() {
  final newIngredients = [const RecipeIngredient(count: 2, ingredient: soySauce)];
  final newSteps = [
    const RecipeStep(name: 'Смешать всё', duration: 90),
    const RecipeStep(name: 'Подать', duration: 30),
  ];

  group('загрузка', () {
    test('данные с сервера попадают в хранилище и доступны через менеджер', () async {
      final store = InMemoryRecipesStore();
      final manager = RecipesManager(
        api: FakeFoodApi(data: fixtureData()),
        store: store,
      );

      await manager.init();

      expect(manager.isLoading, isFalse);
      expect(manager.recipes.map((recipe) => recipe.name), contains('Лосось в соусе терияки'));
      expect(manager.ingredients, hasLength(21));
      expect(manager.measureUnits, hasLength(7));
      expect(store.loadRecipes(), hasLength(7), reason: 'полученное сохранено в локальную базу');
    });

    test('при недоступном сервере используются сохранённые данные', () async {
      final store = InMemoryRecipesStore(
        recipes: fixtureRecipes,
        ingredients: fixtureIngredients,
        measureUnits: fixtureMeasureUnits,
      );
      final manager = RecipesManager(api: FakeFoodApi(offline: true), store: store);

      await manager.init();

      expect(manager.isLoading, isFalse);
      expect(manager.recipes, hasLength(7));
      expect(manager.measureUnits, hasLength(7));
    });

    test('без сети и без сохранённых данных менеджер работает с пустым списком', () async {
      final manager = RecipesManager(api: FakeFoodApi(offline: true), store: InMemoryRecipesStore());

      await manager.init();

      expect(manager.isLoading, isFalse);
      expect(manager.recipes, isEmpty);
    });

    test('уведомляет и при показе кэша, и после ответа сервера', () async {
      final manager = RecipesManager(
        api: FakeFoodApi(data: fixtureData()),
        store: InMemoryRecipesStore(),
      );
      var notifications = 0;
      manager.addListener(() => notifications++);

      await manager.init();

      expect(notifications, greaterThanOrEqualTo(2));
    });

    test('пустой ответ сервера не стирает сохранённые рецепты', () async {
      final store = InMemoryRecipesStore(
        recipes: fixtureRecipes,
        ingredients: fixtureIngredients,
        measureUnits: fixtureMeasureUnits,
      );
      final manager = RecipesManager(
        api: FakeFoodApi(
          data: const FoodData(recipes: [], ingredients: [], measureUnits: []),
        ),
        store: store,
      );

      await manager.init();

      expect(manager.recipes, hasLength(7), reason: 'сменившийся формат ответа выглядит как пустой успех');
      expect(store.loadRecipes(), hasLength(7));
    });

    test('пустой каталог с сервера не стирает сохранённые ингредиенты и единицы', () async {
      final store = InMemoryRecipesStore(
        recipes: fixtureRecipes,
        ingredients: fixtureIngredients,
        measureUnits: fixtureMeasureUnits,
      );

      final manager = RecipesManager(
        api: FakeFoodApi(
          data: const FoodData(recipes: fixtureRecipes, ingredients: [], measureUnits: []),
        ),
        store: store,
      );
      await manager.init();

      expect(manager.ingredients, hasLength(21), reason: 'без каталога нельзя создать ни один рецепт');
      expect(manager.measureUnits, hasLength(7));
      expect(store.loadIngredients(), hasLength(21));
    });

    test('ошибка в собственном коде не маскируется под недоступный сервер', () async {
      final manager = RecipesManager(api: _BrokenFoodApi(), store: InMemoryRecipesStore());

      await expectLater(manager.init(), throwsA(isA<TypeError>()));
    });

    test('отказ записи в хранилище не оставляет вечный индикатор загрузки', () async {
      final manager = RecipesManager(
        api: FakeFoodApi(data: fixtureData()),
        store: InMemoryRecipesStore(failOnSaveAll: true),
      );

      await expectLater(manager.init(), throwsStateError);

      expect(manager.isLoading, isFalse, reason: 'ожидание завершено даже при отказе диска');
    });

    test('возвращаемые списки нельзя изменить', () async {
      final manager = RecipesManager(
        api: FakeFoodApi(data: fixtureData()),
        store: InMemoryRecipesStore(),
      );
      await manager.init();

      expect(() => manager.recipes.clear(), throwsUnsupportedError);
      expect(() => manager.ingredients.clear(), throwsUnsupportedError);
      expect(() => manager.measureUnits.clear(), throwsUnsupportedError);
    });
  });

  group('создание рецепта', () {
    test('при доступном сервере рецепт получает серверный идентификатор и сохраняется локально', () async {
      final store = InMemoryRecipesStore();
      final manager = RecipesManager(
        api: FakeFoodApi(data: fixtureData()),
        store: store,
      );
      await manager.init();
      var notified = false;
      manager.addListener(() => notified = true);

      final recipe = await manager.saveRecipe(name: 'Новый', ingredients: newIngredients, steps: newSteps);

      expect(recipe.id, 100, reason: 'идентификатор присвоен «сервером»');
      expect(recipe.duration, 2, reason: '120 секунд шагов округляются до 2 минут');
      expect(manager.recipes.map((r) => r.id), contains(100));
      expect(store.loadRecipes().map((r) => r.id), contains(100), reason: 'сохранено и локально');
      expect(notified, isTrue);
    });

    test('без сети рецепт получает отрицательный идентификатор и сохраняется локально', () async {
      final store = InMemoryRecipesStore(
        recipes: fixtureRecipes,
        ingredients: fixtureIngredients,
        measureUnits: fixtureMeasureUnits,
      );
      final manager = RecipesManager(api: FakeFoodApi(offline: true), store: store);
      await manager.init();

      final first = await manager.saveRecipe(name: 'Первый черновик', ingredients: newIngredients, steps: newSteps);
      final second = await manager.saveRecipe(name: 'Второй черновик', ingredients: newIngredients, steps: newSteps);

      expect(first.id, -1);
      expect(second.id, -2);
      expect(store.loadRecipes().map((r) => r.id), containsAll([-1, -2]));
    });

    test('оффлайн-рецепты идут после серверных в порядке создания', () async {
      final manager = RecipesManager(
        api: FakeFoodApi(offline: true),
        store: InMemoryRecipesStore(recipes: fixtureRecipes),
      );
      await manager.init();

      await manager.saveRecipe(name: 'Первый черновик', ingredients: newIngredients, steps: newSteps);
      await manager.saveRecipe(name: 'Второй черновик', ingredients: newIngredients, steps: newSteps);

      final names = manager.recipes.map((r) => r.name).toList();
      expect(names.sublist(names.length - 2), ['Первый черновик', 'Второй черновик']);
      expect(manager.recipes.first.id, 0, reason: 'серверные рецепты остаются в начале по возрастанию id');
    });

    test('рецепт с ингредиентом, созданным без сети, на сервер не отправляется', () async {
      final api = FakeFoodApi(data: fixtureData());
      final manager = RecipesManager(
        api: api,
        store: InMemoryRecipesStore(measureUnits: fixtureMeasureUnits),
      );
      await manager.init();

      api.offline = true;
      final local = await manager.addIngredient('Соль морская', gram);
      api.offline = false;

      final recipe = await manager.saveRecipe(
        name: 'Рецепт с локальным ингредиентом',
        ingredients: [
          const RecipeIngredient(count: 2, ingredient: soySauce),
          RecipeIngredient(count: 1, ingredient: local),
        ],
        steps: newSteps,
      );

      expect(local.id, isNegative);
      expect(api.createRecipeCalls, 0, reason: 'связь ушла бы на неизвестный серверу идентификатор');
      expect(recipe.id, isNegative);
      expect(manager.recipes.map((r) => r.id), contains(recipe.id));
    });

    test('длительностью является сумма шагов, округлённая вверх до минут', () async {
      final manager = RecipesManager(api: FakeFoodApi(offline: true), store: InMemoryRecipesStore());
      await manager.init();

      final recipe = await manager.saveRecipe(
        name: 'Быстрый',
        ingredients: newIngredients,
        steps: [const RecipeStep(name: 'Один шаг', duration: 61)],
      );

      expect(recipe.duration, 2);
    });
  });

  group('каталог ингредиентов', () {
    test('при доступном сервере ингредиент получает серверный идентификатор', () async {
      final store = InMemoryRecipesStore();
      final manager = RecipesManager(
        api: FakeFoodApi(data: fixtureData()),
        store: store,
      );
      await manager.init();

      final ingredient = await manager.addIngredient('Соль морская', gram);

      expect(ingredient.id, 100);
      expect(manager.ingredients, contains(ingredient));
      expect(store.loadIngredients().map((i) => i.id), contains(100));
    });

    test('без сети ингредиент получает отрицательный идентификатор и сохраняется', () async {
      final store = InMemoryRecipesStore(ingredients: fixtureIngredients, measureUnits: fixtureMeasureUnits);
      final manager = RecipesManager(api: FakeFoodApi(offline: true), store: store);
      await manager.init();

      final ingredient = await manager.addIngredient('Соль морская', gram);

      expect(ingredient.id, -1);
      expect(store.loadIngredients().map((i) => i.id), contains(-1));
    });
  });

  group('избранное', () {
    test('переключается, уведомляет и переживает пересоздание менеджера', () async {
      final store = InMemoryRecipesStore(recipes: fixtureRecipes);
      final manager = RecipesManager(api: FakeFoodApi(offline: true), store: store);
      await manager.init();
      var notifications = 0;
      manager.addListener(() => notifications++);

      manager.toggleFavorite(0);
      expect(manager.isFavorite(0), isTrue);
      expect(manager.isFavorite(1), isFalse);
      expect(notifications, 1);

      manager.toggleFavorite(0);
      expect(manager.isFavorite(0), isFalse);
      expect(notifications, 2);

      manager.toggleFavorite(6);
      final reopened = RecipesManager(api: FakeFoodApi(offline: true), store: store);
      await reopened.init();
      expect(reopened.isFavorite(6), isTrue, reason: 'избранное хранится в локальной базе');
    });
  });

  group('комментарии', () {
    test('комментарии читаются из хранилища', () async {
      final manager = RecipesManager(
        api: FakeFoodApi(offline: true),
        store: InMemoryRecipesStore(comments: fixtureComments()),
      );
      await manager.init();

      expect(manager.commentsOf(0).single.author, 'anna_obraztsova');
      expect(manager.commentsOf(1), isEmpty);
      expect(() => manager.commentsOf(0).clear(), throwsUnsupportedError);
    });

    test('добавленный комментарий подписан, уведомляет и переживает пересоздание', () async {
      final store = InMemoryRecipesStore(comments: fixtureComments());
      final manager = RecipesManager(api: FakeFoodApi(offline: true), store: store);
      await manager.init();
      var notified = false;
      manager.addListener(() => notified = true);
      final before = DateTime.now();

      final comment = manager.addComment(0, 'Очень вкусно!');

      expect(comment.author, 'Вы');
      expect(comment.text, 'Очень вкусно!');
      expect(comment.date.isBefore(before), isFalse, reason: 'датой комментария является момент добавления');
      expect(notified, isTrue);
      expect(manager.commentsOf(0).map((c) => c.text), contains('Очень вкусно!'));

      final reopened = RecipesManager(api: FakeFoodApi(offline: true), store: store);
      await reopened.init();
      expect(
        reopened.commentsOf(0).map((c) => c.text),
        contains('Очень вкусно!'),
        reason: 'комментарий сохранён в локальной базе',
      );
    });
  });
}

/// Падения приведения типа не должны подменяться локальными данными
class _BrokenFoodApi implements FoodApi {
  @override
  Future<FoodData> fetchFoodData() async {
    final Object wrongType = 'не FoodData';
    return wrongType as FoodData;
  }

  @override
  Future<Recipe> createRecipe({
    required String name,
    required int duration,
    required List<RecipeIngredient> ingredients,
    required List<RecipeStep> steps,
  }) => throw UnimplementedError();

  @override
  Future<Ingredient> createIngredient(String name, MeasureUnit measureUnit) => throw UnimplementedError();
}
