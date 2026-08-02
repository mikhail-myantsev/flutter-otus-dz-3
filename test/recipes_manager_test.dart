import 'package:flutter_test/flutter_test.dart';
import 'package:recipes/data/recipes_manager.dart';
import 'package:recipes/models/recipe_ingredient.dart';
import 'package:recipes/models/recipe_step.dart';

void main() {
  group('RecipesManager', () {
    test('каталог ингредиентов не пуст', () => expect(RecipesManager().ingredients, isNotEmpty));

    test('справочник единиц измерения не пуст', () => expect(RecipesManager().measureUnits, isNotEmpty));

    test('возвращаемые списки нельзя изменить снаружи', () {
      final manager = RecipesManager();
      expect(() => manager.recipes.clear(), throwsUnsupportedError);
      expect(() => manager.ingredients.clear(), throwsUnsupportedError);
      expect(() => manager.measureUnits.clear(), throwsUnsupportedError);
    });

    test('добавляется ингредиент с новым id и заданной единицей', () {
      final manager = RecipesManager();
      final unit = manager.measureUnits.first;
      final existingIds = manager.ingredients.map((ingredient) => ingredient.id).toList();
      final added = manager.addIngredient('Кунжут', unit);
      expect(added.name, 'Кунжут');
      expect(added.measureUnit, unit);
      expect(existingIds, isNot(contains(added.id)));
      expect(manager.ingredients.last, added);
    });

    test('последовательные добавленные ингредиенты получают разные id', () {
      final manager = RecipesManager();
      final unit = manager.measureUnits.first;
      final first = manager.addIngredient('Кинза', unit);
      final second = manager.addIngredient('Укроп', unit);
      expect(first.id, isNot(second.id));
    });

    test('добавление ингредиента уведомляет слушателей', () {
      final manager = RecipesManager();
      var notifications = 0;
      manager.addListener(() => notifications++);
      manager.addIngredient('Кориандр', manager.measureUnits.first);
      expect(notifications, 1);
    });

    group('saveRecipe', () {
      test('добавляет рецепт в конец списка с новым id', () {
        final manager = RecipesManager();
        final ingredient = RecipeIngredient(count: 2, ingredient: manager.ingredients.first);
        final existingIds = manager.recipes.map((recipe) => recipe.id).toList();
        final saved = manager.saveRecipe(
          name: 'Тестовый рецепт',
          ingredients: [ingredient],
          steps: const [RecipeStep(name: 'Смешать всё', duration: 300)],
        );
        expect(manager.recipes.last, saved);
        expect(saved.name, 'Тестовый рецепт');
        expect(existingIds, isNot(contains(saved.id)));
        expect(saved.ingredients, [ingredient]);
      });

      test('округляет суммарную длительность шагов вверх до минут', () {
        final manager = RecipesManager();
        // 330 + 90 = 420 секунд = ровно 7 минут
        final exact = manager.saveRecipe(
          name: 'Ровно семь минут',
          ingredients: [RecipeIngredient(count: 1, ingredient: manager.ingredients.first)],
          steps: const [
            RecipeStep(name: 'Первый', duration: 330),
            RecipeStep(name: 'Второй', duration: 90),
          ],
        );
        expect(exact.duration, 7);
        // 61 секунда = 2 минуты с округлением вверх
        final rounded = manager.saveRecipe(
          name: 'Две минуты',
          ingredients: [RecipeIngredient(count: 1, ingredient: manager.ingredients.first)],
          steps: const [RecipeStep(name: 'Единственный', duration: 61)],
        );
        expect(rounded.duration, 2);
      });

      test('сохраняет пустое фото', () {
        final manager = RecipesManager();
        final saved = manager.saveRecipe(
          name: 'Без фото',
          ingredients: [RecipeIngredient(count: 1, ingredient: manager.ingredients.first)],
          steps: const [RecipeStep(name: 'Шаг', duration: 60)],
        );
        expect(saved.photo, isEmpty);
      });

      test('уведомляет слушателей', () {
        final manager = RecipesManager();
        var notifications = 0;
        manager.addListener(() => notifications++);
        manager.saveRecipe(
          name: 'С уведомлением',
          ingredients: [RecipeIngredient(count: 1, ingredient: manager.ingredients.first)],
          steps: const [RecipeStep(name: 'Шаг', duration: 60)],
        );
        expect(notifications, 1);
      });
    });

    group('сиды рецептов', () {
      test('рецепты из макета наполнены ингредиентами и шагами', () {
        final manager = RecipesManager();
        for (final id in const [0, 6]) {
          final recipe = manager.recipes.firstWhere((recipe) => recipe.id == id);
          expect(recipe.ingredients, isNotEmpty, reason: 'ингредиенты рецепта $id');
          expect(recipe.steps, isNotEmpty, reason: 'шаги рецепта $id');
        }
      });

      test('лимонный сок отмерен половинками столовых ложек', () {
        final manager = RecipesManager();
        final salmon = manager.recipes.firstWhere((recipe) => recipe.id == 0);
        final lemonJuice = salmon.ingredients.firstWhere((item) => item.ingredient.name == 'Лимонный сок');
        expect(lemonJuice.count, 1.5);
        expect(lemonJuice.ingredient.measureUnit.one, 'ст. ложка');
      });

      test('сумма длительностей шагов совпадает со временем приготовления', () {
        final manager = RecipesManager();
        for (final recipe in manager.recipes.where((recipe) => recipe.steps.isNotEmpty)) {
          final totalSeconds = recipe.steps.fold(0, (sum, step) => sum + step.duration);
          expect(totalSeconds, recipe.duration * 60, reason: 'шаги рецепта ${recipe.name}');
        }
      });
    });

    group('избранное', () {
      test('по умолчанию рецепт не в избранном', () => expect(RecipesManager().isFavorite(0), isFalse));

      test('рецепт добавляется в избранное и убирается из него', () {
        final manager = RecipesManager();
        manager.toggleFavorite(0);
        expect(manager.isFavorite(0), isTrue);
        manager.toggleFavorite(0);
        expect(manager.isFavorite(0), isFalse);
      });

      test('отметки разных рецептов независимы', () {
        final manager = RecipesManager();
        manager.toggleFavorite(0);
        expect(manager.isFavorite(0), isTrue);
        expect(manager.isFavorite(6), isFalse);
      });

      test('каждое переключение уведомляет слушателей', () {
        final manager = RecipesManager();
        var notifications = 0;
        manager.addListener(() => notifications++);
        manager.toggleFavorite(0);
        manager.toggleFavorite(0);
        expect(notifications, 2);
      });
    });

    group('комментарии', () {
      test('рецепты из макета имеют комментарии-сиды', () {
        final manager = RecipesManager();
        expect(manager.commentsOf(0), isNotEmpty);
        expect(manager.commentsOf(6), isNotEmpty);
      });

      test('у рецепта без комментариев список пуст', () => expect(RecipesManager().commentsOf(1), isEmpty));

      test('возвращаемые списки нельзя изменить снаружи', () {
        final manager = RecipesManager();
        expect(() => manager.commentsOf(0).clear(), throwsUnsupportedError);
        expect(() => manager.commentsOf(1).clear(), throwsUnsupportedError);
      });

      test('addComment добавляет комментарий текущего пользователя в конец списка', () {
        final manager = RecipesManager();
        final countBefore = manager.commentsOf(0).length;
        final added = manager.addComment(0, 'Очень вкусно');
        expect(added.author, 'Вы');
        expect(added.text, 'Очень вкусно');
        expect(manager.commentsOf(0), hasLength(countBefore + 1));
        expect(manager.commentsOf(0).last, added);
      });

      test('добавление комментария работает для рецепта без комментариев', () {
        final manager = RecipesManager();
        final added = manager.addComment(1, 'Первый комментарий');
        expect(manager.commentsOf(1), [added]);
      });

      test('датой комментария становится момент добавления', () {
        final manager = RecipesManager();
        final before = DateTime.now();
        final added = manager.addComment(0, 'Только что');
        final after = DateTime.now();
        expect(added.date.isBefore(before), isFalse);
        expect(added.date.isAfter(after), isFalse);
      });

      test('добавление комментария уведомляет слушателей', () {
        final manager = RecipesManager();
        var notifications = 0;
        manager.addListener(() => notifications++);
        manager.addComment(0, 'С уведомлением');
        expect(notifications, 1);
      });
    });
  });
}
