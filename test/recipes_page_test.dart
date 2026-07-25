import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipes/data/recipes_manager.dart';
import 'package:recipes/models/recipe_ingredient.dart';
import 'package:recipes/models/recipe_step.dart';
import 'package:recipes/screens/add_recipe_page.dart';
import 'package:recipes/screens/recipes_page.dart';

void main() {
  group('RecipesPage', () {
    testWidgets('показывает рецепт, сохранённый менеджером, без ручного обновления', (tester) async {
      final manager = RecipesManager();
      await tester.pumpWidget(MaterialApp(home: RecipesPage(manager: manager)));
      await tester.pump();

      manager.saveRecipe(
        name: 'Рецепт из теста',
        ingredients: [RecipeIngredient(count: 1, ingredient: manager.ingredients.first)],
        steps: const [RecipeStep(name: 'Смешать', duration: 60)],
      );
      await tester.pump();

      // Новый рецепт попадает в конец списка, и до него нужно доскроллить
      await tester.scrollUntilVisible(find.text('Рецепт из теста'), 300);
      expect(find.text('Рецепт из теста'), findsOneWidget);
    });

    testWidgets('кнопка добавления открывает страницу нового рецепта', (tester) async {
      await tester.pumpWidget(MaterialApp(home: RecipesPage(manager: RecipesManager())));
      await tester.pump();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.byType(AddRecipePage), findsOneWidget);
    });
  });
}
