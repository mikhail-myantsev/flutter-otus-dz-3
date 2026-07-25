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

    test('addIngredient добавляет ингредиент с новым id и заданной единицей', () {
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
        // 61 секунда = 2 минуты (округляем вверх)
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
  });
}
