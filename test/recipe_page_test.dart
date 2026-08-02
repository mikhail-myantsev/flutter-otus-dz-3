import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipes/data/recipes_manager.dart';
import 'package:recipes/models/recipe.dart';
import 'package:recipes/screens/recipe_page.dart';
import 'package:recipes/widgets/favorite_button.dart';
import 'package:recipes/widgets/recipe_step_card.dart';

void main() {
  group('RecipePage', () {
    /// Открывает страницу рецепта и возвращает менеджер, на котором она построена
    ///
    /// Без [recipe] берётся первый рецепт
    Future<RecipesManager> pumpPage(WidgetTester tester, {Recipe? recipe}) async {
      final manager = RecipesManager();
      await tester.pumpWidget(
        MaterialApp(
          home: RecipePage(manager: manager, recipe: recipe ?? manager.recipes.first),
        ),
      );
      await tester.pump();
      return manager;
    }

    /// Прокручивает страницу до [finder]
    Future<void> scrollTo(WidgetTester tester, Finder finder) {
      return tester.scrollUntilVisible(finder, 300, scrollable: find.byType(Scrollable).first);
    }

    testWidgets('показывает название, время приготовления, состав и шаги', (tester) async {
      await pumpPage(tester);

      expect(find.text('Лосось в соусе терияки'), findsOneWidget);
      expect(find.text('45 минут'), findsOneWidget);
      expect(find.text('•  Соевый соус'), findsOneWidget);
      expect(find.text('680 граммов'), findsOneWidget);
      expect(find.text('8 ст. ложек'), findsWidgets);
      expect(find.text('1½ ст. ложки'), findsOneWidget);

      // До шагов нужно доскроллить
      final secondStep = find.textContaining('Поставьте на средний огонь');
      await scrollTo(tester, secondStep);
      expect(secondStep, findsOneWidget);
    });

    testWidgets('тап по чекбоксу отмечает шаг пройденным и снимает отметку', (tester) async {
      await pumpPage(tester);

      // До первого шага нужно доскроллить
      await scrollTo(tester, find.textContaining('В маленькой кастрюле'));

      // Тап обрабатывают вся карточка и чекбокс, он в дереве карточки последний
      final firstCard = find.byType(RecipeStepCard).first;
      final checkbox = find.descendant(of: firstCard, matching: find.byType(GestureDetector)).last;
      expect(find.byIcon(Icons.check), findsNothing);

      await tester.tap(checkbox);
      await tester.pump();
      expect(find.byIcon(Icons.check), findsOneWidget);

      await tester.tap(checkbox);
      await tester.pump();
      expect(find.byIcon(Icons.check), findsNothing);
    });

    testWidgets('отправленный комментарий появляется в списке', (tester) async {
      await pumpPage(tester);

      final field = find.byType(TextField);
      await scrollTo(tester, field);

      await tester.enterText(field, '  Готовил дважды  ');
      await tester.pump();

      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      // Поле ввода очищается при отправке, поэтому текст в дереве является комментарием
      expect(find.text('Готовил дважды'), findsOneWidget);
    });

    testWidgets('кнопка отправки видна только при непустом тексте', (tester) async {
      await pumpPage(tester);

      final field = find.byType(TextField);
      await scrollTo(tester, field);

      // Прокрутка доводится до конца, иначе нажатие придётся по старым координатам поля
      await tester.pumpAndSettle();

      // В покое поле выглядит как в макете с отображением только иконки фото
      expect(find.byIcon(Icons.photo_size_select_actual), findsOneWidget);
      expect(find.byIcon(Icons.send), findsNothing);

      // Одни пробелы отправлять нечего
      await tester.enterText(field, '   ');
      await tester.pump();
      expect(find.byIcon(Icons.send), findsNothing);

      await tester.enterText(field, 'Готовил дважды');
      await tester.pump();
      expect(find.byIcon(Icons.send), findsOneWidget);

      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      // После отправки поле очищается, поэтому кнопка скрывается сама
      expect(find.byIcon(Icons.send), findsNothing);
      expect(find.byIcon(Icons.photo_size_select_actual), findsOneWidget);
    });

    testWidgets('иконка фото не сдвигается при появлении кнопки отправки', (tester) async {
      await pumpPage(tester);

      final field = find.byType(TextField);
      await scrollTo(tester, field);

      // Прокрутка доводится до конца, иначе замеры придутся по разным координатам поля
      await tester.pumpAndSettle();

      final photoIcon = find.byIcon(Icons.photo_size_select_actual);
      final beforeInput = tester.getRect(photoIcon);

      await tester.enterText(field, 'Готовил дважды');
      await tester.pumpAndSettle();

      // Место кнопки отправки занято и при пустом поле, поэтому иконка фото остаётся на прежнем месте
      expect(find.byIcon(Icons.send), findsOneWidget);
      expect(tester.getRect(photoIcon), beforeInput);
    });

    testWidgets('кнопка отправки стоит под иконкой фото и обе умещаются в поле', (tester) async {
      await pumpPage(tester);

      final field = find.byType(TextField);
      await scrollTo(tester, field);

      // Прокрутка доводится до конца, иначе замеры придутся по разным координатам поля
      await tester.pumpAndSettle();

      await tester.enterText(field, 'Готовил дважды');
      await tester.pumpAndSettle();

      final photoCenter = tester.getCenter(find.byIcon(Icons.photo_size_select_actual));
      final sendCenter = tester.getCenter(find.byIcon(Icons.send));

      // Иконки стоят в столбик
      expect(sendCenter.dx, photoCenter.dx);
      expect(sendCenter.dy, greaterThan(photoCenter.dy));

      // Столбик кнопок сделан компактным ради того, чтобы уместиться в высоту поля из макета
      final fieldRect = tester.getRect(field);
      expect(tester.getRect(find.byIcon(Icons.photo_size_select_actual)).top, greaterThanOrEqualTo(fieldRect.top));
    });

    testWidgets('тап по иконке фото в поле комментария открывает шит выбора фото', (tester) async {
      await pumpPage(tester);

      await scrollTo(tester, find.byType(TextField));

      // Прокрутка доводится до конца, иначе нажатие придётся по старым координатам поля
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.photo_size_select_actual));
      await tester.pumpAndSettle();

      expect(find.text('Сфотографировать'), findsOneWidget);
    });

    testWidgets('тап по кнопке избранного отмечает рецепт в менеджере', (tester) async {
      final manager = await pumpPage(tester);
      expect(manager.isFavorite(0), isFalse);

      await tester.tap(find.byType(FavoriteButton));
      await tester.pump();

      expect(manager.isFavorite(0), isTrue);
    });

    testWidgets('рецепт без состава и шагов показывает подписи-заглушки', (tester) async {
      final manager = RecipesManager();
      final recipe = manager.recipes.firstWhere((r) => r.ingredients.isEmpty && r.steps.isEmpty);
      await pumpPage(tester, recipe: recipe);

      expect(find.text('нет ингредиентов'), findsOneWidget);
      await scrollTo(tester, find.text('нет шагов приготовления'));
      expect(find.text('нет шагов приготовления'), findsOneWidget);
    });
  });
}
