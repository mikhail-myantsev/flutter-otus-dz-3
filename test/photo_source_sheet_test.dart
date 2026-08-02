import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipes/widgets/photo_source_sheet.dart';

void main() {
  group('showPhotoSourceSheet', () {
    /// Открывает шит с кнопками в минимальном окружении
    Future<void> pumpSheet(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) =>
                  TextButton(onPressed: () => showPhotoSourceSheet(context), child: const Text('фото')),
            ),
          ),
        ),
      );

      await tester.tap(find.text('фото'));
      await tester.pumpAndSettle();
    }

    testWidgets('показывает съёмку, выбор из альбома, удаление и отмену', (tester) async {
      await pumpSheet(tester);

      expect(find.text('Сфотографировать'), findsOneWidget);
      expect(find.text('Выбрать из альбома'), findsOneWidget);
      expect(find.text('Удалить'), findsOneWidget);
      expect(find.text('Отмена'), findsOneWidget);
    });

    testWidgets('тап по отмене закрывает шит', (tester) async {
      await pumpSheet(tester);

      await tester.tap(find.text('Отмена'));
      await tester.pumpAndSettle();

      expect(find.text('Отмена'), findsNothing);
    });

    testWidgets('тап по пункту-заглушке закрывает шит', (tester) async {
      for (final label in ['Сфотографировать', 'Выбрать из альбома', 'Удалить']) {
        await pumpSheet(tester);

        await tester.tap(find.text(label));
        await tester.pumpAndSettle();

        expect(find.text(label), findsNothing, reason: 'пункт $label должен закрывать шит');
      }
    });

    testWidgets('на низком экране помещается целиком и отмена остаётся доступной', (tester) async {
      const screen = Size(800, 360);
      tester.view.physicalSize = screen;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await pumpSheet(tester);

      expect(tester.takeException(), isNull, reason: 'содержимое шита не должно переполняться');

      final cancel = tester.getRect(find.byType(FilledButton));
      expect(cancel.top, greaterThanOrEqualTo(0.0));
      expect(cancel.bottom, lessThanOrEqualTo(screen.height), reason: 'кнопка отмены должна быть в границах экрана');
      expect(cancel.left, greaterThanOrEqualTo(0.0));
      expect(cancel.right, lessThanOrEqualTo(screen.width));

      await tester.tap(find.text('Отмена'));
      await tester.pumpAndSettle();

      expect(find.text('Отмена'), findsNothing, reason: 'тап по отмене должен закрывать шит');
    });

    testWidgets('на экране ниже содержимого шит прокручивается до отмены', (tester) async {
      const screen = Size(600, 200);
      tester.view.physicalSize = screen;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await pumpSheet(tester);

      expect(tester.takeException(), isNull, reason: 'содержимое шита не должно переполняться');

      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -200));
      await tester.pumpAndSettle();

      final cancel = tester.getRect(find.byType(FilledButton));
      expect(cancel.bottom, lessThanOrEqualTo(screen.height), reason: 'после прокрутки отмена должна быть на экране');

      await tester.tap(find.text('Отмена'));
      await tester.pumpAndSettle();

      expect(find.text('Отмена'), findsNothing, reason: 'тап по отмене должен закрывать шит');
    });
  });
}
