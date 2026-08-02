import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipes/theme/app_colors.dart';
import 'package:recipes/widgets/favorite_button.dart';

void main() {
  group('FavoriteButton', () {
    /// Выводит кнопку на экран в минимальном окружении
    Future<void> pumpButton(WidgetTester tester, {required bool isFavorite, VoidCallback? onPressed}) {
      return tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: FavoriteButton(isFavorite: isFavorite, onPressed: onPressed ?? () {}),
          ),
        ),
      );
    }

    /// Возвращает [HeartPainter] из поддерева кнопки
    HeartPainter painterOf(WidgetTester tester) {
      final customPaint = tester.widget<CustomPaint>(
        find.descendant(of: find.byType(FavoriteButton), matching: find.byType(CustomPaint)),
      );

      return customPaint.painter! as HeartPainter;
    }

    testWidgets('тап по кнопке вызывает переданную функцию', (tester) async {
      var taps = 0;
      await pumpButton(tester, isFavorite: false, onPressed: () => taps++);

      await tester.tap(find.byType(FavoriteButton));

      expect(taps, 1);
    });

    testWidgets('рисует сердце на canvas, а не готовой иконкой', (tester) async {
      await pumpButton(tester, isFavorite: false);

      expect(find.descendant(of: find.byType(FavoriteButton), matching: find.byType(CustomPaint)), findsOneWidget);
      expect(painterOf(tester), isA<HeartPainter>());
      expect(find.byType(Icon), findsNothing);
    });

    testWidgets('рисует сердце размером 30 в области нажатия размером 40', (tester) async {
      await pumpButton(tester, isFavorite: false);

      expect(tester.getSize(find.byType(FavoriteButton)), const Size(40, 40));
      expect(
        tester.getSize(find.descendant(of: find.byType(FavoriteButton), matching: find.byType(CustomPaint))),
        const Size(30, 30),
      );
    });

    testWidgets('цвет зависит от состояния избранного', (tester) async {
      await pumpButton(tester, isFavorite: false);
      expect(painterOf(tester).color, AppColors.likeInactive);

      await pumpButton(tester, isFavorite: true);
      expect(painterOf(tester).color, AppColors.likeActive);
    });

    testWidgets('перерисовывается при смене состояния', (tester) async {
      await pumpButton(tester, isFavorite: false);
      final inactive = painterOf(tester);

      await pumpButton(tester, isFavorite: true);
      final active = painterOf(tester);

      expect(active.shouldRepaint(inactive), isTrue);
      expect(active.shouldRepaint(active), isFalse);
    });
  });
}
