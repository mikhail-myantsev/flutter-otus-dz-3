import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
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

    /// Собирает узлы поддерева [root], принимающие нажатие
    List<SemanticsNode> tappableNodes(SemanticsNode root) {
      final nodes = <SemanticsNode>[];

      void visit(SemanticsNode node) {
        if (node.getSemanticsData().hasAction(SemanticsAction.tap)) {
          nodes.add(node);
        }

        node.visitChildren((child) {
          visit(child);
          return true;
        });
      }

      visit(root);
      return nodes;
    }

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

    testWidgets('вся карточка остаётся единственным элементом управления', (tester) async {
      final handle = tester.ensureSemantics();
      var checked = false;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: StatefulBuilder(
              builder: (context, setState) => SizedBox(
                width: 400,
                child: RecipeStepCard(
                  number: 2,
                  step: const RecipeStep(name: shortStep, duration: 420),
                  checked: checked,
                  onToggle: () => setState(() => checked = !checked),
                ),
              ),
            ),
          ),
        ),
      );

      // Тап по карточке дублирует чекбокс, поэтому в дереве остаётся один нажимаемый узел
      final checkbox = find.descendant(of: find.byType(RecipeStepCard), matching: find.byType(GestureDetector)).last;
      final owner = tester.getSemantics(checkbox).owner!;
      final tappable = tappableNodes(owner.rootSemanticsNode!);
      expect(tappable, hasLength(1));

      // Номер, текст шага и время склеены в метку одного узла с отметкой
      expect(
        tappable.single,
        matchesSemantics(label: '2\n$shortStep\n07:00', hasCheckedState: true, hasTapAction: true),
      );

      // Отметка шага переключает состояние того же узла
      await tester.tap(checkbox);
      await tester.pump();

      final toggled = tappableNodes(owner.rootSemanticsNode!);
      expect(toggled, hasLength(1));
      expect(
        toggled.single,
        matchesSemantics(label: '2\n$shortStep\n07:00', hasCheckedState: true, isChecked: true, hasTapAction: true),
      );

      handle.dispose();
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
