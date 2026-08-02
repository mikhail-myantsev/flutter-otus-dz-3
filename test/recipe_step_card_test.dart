import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipes/models/recipe_step.dart';
import 'package:recipes/widgets/recipe_step_card.dart';

void main() {
  group('RecipeStepCard', () {
    /// Текст заведомо ниже карточки минимальной высоты
    const shortStep = 'Поставьте на средний огонь и, помешивая, доведите до лёгкого кипения.';

    /// Текст заведомо выше карточки минимальной высоты
    const longStep =
        'В маленькой кастрюле соедините соевый соус, 6 столовых ложек воды, мёд, сахар, измельчённый '
        'чеснок, имбирь и лимонный сок. Готовьте, непрерывно помешивая венчиком, одну минуту.';

    /// Вертикальные отступы текста шага, они же минимальные
    const textInset = 17.0;

    /// Выводит карточку шага на экран в отведённой ширине
    Future<void> pumpCard(WidgetTester tester, String name, {required double width}) {
      return tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: SizedBox(
              width: width,
              child: RecipeStepCard(
                number: 2,
                step: RecipeStep(name: name, duration: 420),
                checked: false,
                onToggle: () {},
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('текст короткого шага стоит по центру карточки по вертикали', (tester) async {
      await pumpCard(tester, shortStep, width: 700);

      final card = tester.getRect(find.byType(RecipeStepCard));
      final text = tester.getRect(find.text(shortStep));

      // Карточка держит минимальную высоту, а свободное место делится поровну над текстом и под ним
      expect(card.height, RecipeStepCard.minHeight);
      expect(text.top - card.top, greaterThan(textInset));
      expect(text.top - card.top, closeTo(card.bottom - text.bottom, 2));
    });

    testWidgets('длинный шаг растит карточку и сохраняет минимальные отступы', (tester) async {
      await pumpCard(tester, longStep, width: 400);

      final card = tester.getRect(find.byType(RecipeStepCard));
      final text = tester.getRect(find.text(longStep));

      expect(card.height, greaterThan(RecipeStepCard.minHeight));
      expect(text.top - card.top, textInset);
      expect(card.bottom - text.bottom, textInset);
      expect(tester.takeException(), isNull);
    });
  });
}
