import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Показывает нижний шит выбора фото
Future<void> showPhotoSourceSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(),
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => const _PhotoSourceSheet(),
  );
}

/// Нижний шит с источниками фото и его удалением
class _PhotoSourceSheet extends StatelessWidget {
  const _PhotoSourceSheet();

  /// Разделитель между пунктами
  static const _divider = Divider(height: 0.5, thickness: 0.5, color: AppColors.placeholder);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PhotoSourceItem(
            label: 'Сфотографировать',
            // TODO: Реализовать после реализации выбора фото
            onPressed: () => Navigator.pop(context),
          ),
          _divider,
          _PhotoSourceItem(
            label: 'Выбрать из альбома',
            // TODO: Реализовать после реализации выбора фото
            onPressed: () => Navigator.pop(context),
          ),
          _divider,
          _PhotoSourceItem(
            label: 'Удалить',
            color: AppColors.danger,
            // TODO: Реализовать вместе с прикреплением фото к комментарию
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(height: 8),
          Center(
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.field,
                foregroundColor: AppColors.text,
                minimumSize: const Size(401, 46),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: const StadiumBorder(),
                textStyle: const TextStyle(fontSize: 16),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
          ),
          const SizedBox(height: 34),
        ],
      ),
    );
  }
}

/// Пункт шита выбора фото во всю ширину
class _PhotoSourceItem extends StatelessWidget {
  const _PhotoSourceItem({required this.label, required this.onPressed, this.color = AppColors.text});

  /// Подпись пункта
  final String label;

  /// Действие по нажатию
  final VoidCallback onPressed;

  /// Цвет подписи
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: SizedBox(
        height: 66,
        child: Center(
          child: Text(label, style: TextStyle(fontSize: 16, color: color)),
        ),
      ),
    );
  }
}
