import 'package:flutter/material.dart';

import '../models/recipe.dart';
import '../theme/app_colors.dart';
import '../utils/duration_format.dart';

/// Карточка рецепта
class RecipeCard extends StatelessWidget {
  const RecipeCard({super.key, required this.recipe});

  /// Рецепт, который отображает карточка
  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(5),
        boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 10, offset: Offset(0, 2))],
      ),
      child: SizedBox(
        // Высота карточки фиксирована, поэтому внутренняя раскладка построена так, чтобы контент любой длины помещался
        height: 136,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Фото слева
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(5)),
              child: SizedBox(
                width: 149,
                child: Image.asset(
                  recipe.photo,
                  fit: BoxFit.cover,
                  // Нейтральная серая заглушка
                  errorBuilder: (context, error, stackTrace) => const ColoredBox(
                    color: Color(0xFFEEEEEE),
                    child: Center(child: Icon(Icons.image_not_supported_outlined, color: Color(0xFFBDBDBD))),
                  ),
                ),
              ),
            ),
            // Название и время приготовления справа
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 30, 16, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 13,
                  children: [
                    // Длинное название обрезается многоточием
                    Expanded(
                      child: Text(
                        recipe.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          height: 1.0,
                          letterSpacing: 0,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                    Row(
                      spacing: 8,
                      children: [
                        const Icon(Icons.access_time, size: 16, color: AppColors.text),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              formatDurationMinutes(recipe.duration),
                              style: const TextStyle(fontSize: 16, color: AppColors.accent),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
