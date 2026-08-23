import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipes/screens/add_recipe_page.dart';

import 'fakes.dart';
import 'fixtures.dart';
import 'helpers.dart';

void main() {
  /// Прокручивает до кнопки и нажимает её
  Future<void> tapButton(WidgetTester tester, String label) async {
    final button = find.text(label);
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    await tester.tap(button);
    await tester.pumpAndSettle();
  }

  /// Заполняет форму минимальным набором, включающим название, один ингредиент из каталога и один шаг
  Future<void> fillForm(WidgetTester tester) async {
    await tester.enterText(find.widgetWithText(TextFormField, 'Название рецепта'), 'Пробный рецепт');

    await tapButton(tester, 'Добавить ингредиент');
    await tester.enterText(find.widgetWithText(TextFormField, 'Название ингредиента'), 'Мёд');
    await tester.pump();
    await tester.enterText(find.widgetWithText(TextFormField, 'Количество'), '2');
    await tapButton(tester, 'Добавить');

    await tapButton(tester, 'Добавить шаг');
    await tester.enterText(find.widgetWithText(TextFormField, 'Описание шага'), 'Смешать всё');
    await tester.enterText(find.widgetWithText(TextFormField, 'Минуты'), '2');
    await tapButton(tester, 'Добавить');
  }

  testWidgets('повторное нажатие во время сохранения не создаёт второй рецепт', (tester) async {
    final api = FakeFoodApi(data: fixtureData())..delay = const Duration(milliseconds: 200);
    final manager = await createTestManager(api: api);
    final recipesBefore = manager.recipes.length;

    await tester.pumpWidget(MaterialApp(home: AddRecipePage(manager: manager)));
    await fillForm(tester);

    // Первое нажатие уводит сохранение в ожидание ответа сервера
    final saveButton = find.widgetWithText(FilledButton, 'Сохранить рецепт');
    await tester.ensureVisible(saveButton);
    await tester.pumpAndSettle();
    await tester.tap(saveButton);
    await tester.pump();

    // Пока ответ не пришёл, кнопка выключена и показывает индикатор
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(tester.widget<FilledButton>(find.byType(FilledButton).last).onPressed, isNull);

    // Повторный тап по выключенной кнопке ничего не запускает
    await tester.tap(find.byType(FilledButton).last, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(api.createRecipeCalls, 1, reason: 'запрос к серверу ушёл ровно один раз');
    expect(manager.recipes.length, recipesBefore + 1);
  });
}
