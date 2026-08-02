import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Кнопка избранного
class FavoriteButton extends StatelessWidget {
  const FavoriteButton({super.key, required this.isFavorite, required this.onPressed});

  /// Видимый размер сердца
  static const double heartSize = 30;

  /// Размер области нажатия
  static const double tapSize = 40;

  /// Отмечена как избранная
  final bool isFavorite;

  /// Обработчик нажатия
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: tapSize,
        height: tapSize,
        child: Center(
          child: CustomPaint(
            size: const Size.square(heartSize),
            painter: HeartPainter(color: isFavorite ? AppColors.likeActive : AppColors.likeInactive),
          ),
        ),
      ),
    );
  }
}

/// Рисует заполненное сердце одним замкнутым путём из кубических кривых Безье
class HeartPainter extends CustomPainter {
  const HeartPainter({required this.color});

  /// Цвет заливки сердца
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final path = Path()
      // верхняя выемка между долями
      ..moveTo(w * 0.500, h * 0.232)
      // от выемки к макушке влево
      ..cubicTo(w * 0.461, h * 0.140, w * 0.370, h * 0.080, w * 0.270, h * 0.080)
      // от макушки к левому краю
      ..cubicTo(w * 0.132, h * 0.080, w * 0.020, h * 0.192, w * 0.020, h * 0.330)
      // от левого края к нижнему кончику
      ..cubicTo(w * 0.020, h * 0.460, w * 0.051, h * 0.464, w * 0.500, h * 0.920)
      // от кончика к правому краю
      ..cubicTo(w * 0.949, h * 0.464, w * 0.980, h * 0.460, w * 0.980, h * 0.330)
      // от правого края к макушке
      ..cubicTo(w * 0.980, h * 0.192, w * 0.868, h * 0.080, w * 0.730, h * 0.080)
      // от макушки обратно к выемке
      ..cubicTo(w * 0.630, h * 0.080, w * 0.539, h * 0.140, w * 0.500, h * 0.232)
      ..close();

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(HeartPainter oldDelegate) => oldDelegate.color != color;
}
