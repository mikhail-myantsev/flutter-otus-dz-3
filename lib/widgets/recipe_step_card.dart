import 'package:flutter/material.dart';

import '../models/recipe_step.dart';
import '../theme/app_colors.dart';
import '../utils/duration_format.dart';

/// Карточка шага приготовления на странице рецепта
class RecipeStepCard extends StatelessWidget {
  const RecipeStepCard({
    super.key,
    required this.number,
    required this.step,
    required this.checked,
    required this.onToggle,
  });

  /// Минимальная высота карточки
  static const double minHeight = 120;

  /// Ширина колонки с номером шага
  static const double numberWidth = 72;

  /// Видимый размер чекбокса
  static const double checkboxSize = 30;

  /// Размер области нажатия на чекбокс
  static const double tapSize = 40;

  /// Насколько область нажатия выступает за края чекбокса с каждой стороны
  static const double _tapInset = (tapSize - checkboxSize) / 2;

  /// Порядковый номер шага, начиная с единицы
  final int number;

  /// Отображаемый шаг
  final RecipeStep step;

  /// Отмечен ли шаг как пройденный
  final bool checked;

  /// Переключает отметку шага
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: checked ? AppColors.stepActiveBackground : AppColors.field,
          borderRadius: BorderRadius.circular(5),
        ),
        // Высота карточки определяется текстом шага, но не меньше `minHeight`
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: minHeight),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: numberWidth,
                  child: Center(
                    child: Text(
                      '$number',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        color: checked ? AppColors.accent : AppColors.placeholder,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 17, 20, 17),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        step.name,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.5,
                          color: checked ? AppColors.stepActiveText : AppColors.muted,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  // Отступы уменьшены на вылет области нажатия, чтобы чекбокс остался на месте
                  padding: const EdgeInsets.only(top: 33 - _tapInset, right: 22 - _tapInset),
                  child: Column(
                    spacing: 14 - _tapInset,
                    children: [
                      GestureDetector(
                        onTap: onToggle,
                        behavior: HitTestBehavior.opaque,
                        child: SizedBox(
                          width: tapSize,
                          height: tapSize,
                          child: Center(child: _Checkbox(checked: checked)),
                        ),
                      ),
                      Text(
                        formatDurationSeconds(step.duration),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: checked ? AppColors.primary : AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Квадратный чекбокс шага
class _Checkbox extends StatelessWidget {
  const _Checkbox({required this.checked});

  /// Отмечен ли чекбокс
  final bool checked;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: RecipeStepCard.checkboxSize,
      height: RecipeStepCard.checkboxSize,
      decoration: BoxDecoration(
        color: checked ? AppColors.primary : null,
        border: checked ? null : Border.all(color: AppColors.muted, width: 4),
        borderRadius: BorderRadius.circular(5),
      ),
      child: checked ? const Icon(Icons.check, size: 22, color: AppColors.background) : null,
    );
  }
}
