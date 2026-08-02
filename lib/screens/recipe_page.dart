import 'package:flutter/material.dart';

import '../data/recipes_manager.dart';
import '../models/recipe.dart';
import '../theme/app_colors.dart';
import '../utils/count_format.dart';
import '../utils/duration_format.dart';
import '../widgets/comment_tile.dart';
import '../widgets/favorite_button.dart';
import '../widgets/image_placeholder.dart';
import '../widgets/landscape_half_width.dart';
import '../widgets/photo_source_sheet.dart';
import '../widgets/recipe_step_card.dart';

/// Страница просмотра рецепта, включающая состав, шаги приготовления и комментарии
///
/// Отметки пройденных шагов локальны для страницы
class RecipePage extends StatefulWidget {
  const RecipePage({super.key, required this.manager, required this.recipe});

  /// Хранилище рецептов
  final RecipesManager manager;

  /// Отображаемый рецепт
  final Recipe recipe;

  /// Маршрут на эту страницу
  static Route<void> route({required RecipesManager manager, required Recipe recipe}) {
    return MaterialPageRoute(
      builder: (_) => RecipePage(manager: manager, recipe: recipe),
    );
  }

  @override
  State<RecipePage> createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  /// Индексы шагов, отмеченных как пройденные
  final Set<int> _checkedSteps = {};

  final _commentController = TextEditingController();

  /// Рамка поля нового комментария
  static const _commentBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(5)),
    borderSide: BorderSide(color: AppColors.primary, width: 2),
  );

  /// Размер кнопки-иконки в поле комментария
  static const _iconButtonSize = 32.0;

  @override
  void initState() {
    super.initState();
    widget.manager.addListener(_handleManagerChange);
  }

  @override
  void dispose() {
    widget.manager.removeListener(_handleManagerChange);
    _commentController.dispose();
    super.dispose();
  }

  void _handleManagerChange() => setState(() {});

  void _toggleStep(int index) {
    setState(() {
      if (_checkedSteps.contains(index)) {
        _checkedSteps.remove(index);
      } else {
        _checkedSteps.add(index);
      }
    });
  }

  void _submitComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) {
      return;
    }

    // Комментарий появится в списке по уведомлению менеджера
    widget.manager.addComment(widget.recipe.id, text);
    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;

    // Горизонтальный отступ навешивается на секции точечно, а не на ListView, чтобы разделитель шёл от края до края
    Widget padded(Widget child) => Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: child);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Рецепт',
          style: TextStyle(fontFamily: 'Roboto', fontSize: 20, fontWeight: FontWeight.w400, color: AppColors.primary),
        ),
        actions: [
          // TODO: Реализовать после подключения сервера
          IconButton(onPressed: () {}, icon: const Icon(Icons.share)),
        ],
      ),
      body: Center(
        child: LandscapeHalfWidth(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(0, 24, 0, 40),
            children: [
              // Название и отметка избранного
              padded(
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        recipe.name,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: AppColors.text),
                      ),
                    ),
                    FavoriteButton(
                      isFavorite: widget.manager.isFavorite(recipe.id),
                      onPressed: () => widget.manager.toggleFavorite(recipe.id),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              padded(
                Row(
                  spacing: 8,
                  children: [
                    const Icon(Icons.access_time, size: 16, color: AppColors.text),
                    Text(
                      formatDurationMinutes(recipe.duration),
                      style: const TextStyle(fontSize: 16, color: AppColors.accent),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              padded(
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: SizedBox(
                    width: double.infinity,
                    height: 220,
                    child: Image.asset(
                      recipe.photo,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const ImagePlaceholder(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 17),
              padded(
                const Text(
                  'Ингредиенты',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 18),
              padded(_buildIngredients()),
              const SizedBox(height: 19),
              padded(
                Center(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary, width: 3),
                      minimumSize: const Size(232, 48),
                      shape: const StadiumBorder(),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    // TODO: Реализовать вместе со списком продуктов в холодильнике
                    onPressed: () {},
                    child: const Text('Проверить наличие'),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              padded(
                const Text(
                  'Шаги приготовления',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 20),
              padded(_buildSteps()),
              const SizedBox(height: 27),
              padded(
                Center(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.background,
                      minimumSize: const Size(232, 48),
                      shape: const StadiumBorder(),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    // TODO: Реализовать вместе с таймером приготовления
                    onPressed: () {},
                    child: const Text('Начать готовить'),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Единственный элемент без боковых отступов во всю ширину
              const Divider(height: 0.5, thickness: 0.5, color: AppColors.muted),
              const SizedBox(height: 32),
              padded(_buildComments()),
              const SizedBox(height: 48),
              padded(
                TextField(
                  controller: _commentController,
                  minLines: 2,
                  maxLines: 4,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    filled: false,
                    hintText: 'оставить комментарий',
                    hintStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.placeholder),
                    contentPadding: const EdgeInsets.all(14),
                    enabledBorder: _commentBorder,
                    focusedBorder: _commentBorder,
                    suffixIconConstraints: const BoxConstraints(minWidth: _iconButtonSize, minHeight: _iconButtonSize),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(left: 8, top: 4, right: 8, bottom: 8),
                      child: ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _commentController,
                        builder: (context, value, _) => Column(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 4,
                          children: [
                            _commentIconButton(
                              icon: Icons.photo_size_select_actual,
                              onPressed: () => showPhotoSourceSheet(context),
                            ),
                            if (value.text.trim().isNotEmpty)
                              _commentIconButton(icon: Icons.send, onPressed: _submitComment)
                            else
                              const SizedBox.square(dimension: _iconButtonSize),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Состав рецепта
  Widget _buildIngredients() {
    final ingredients = widget.recipe.ingredients;
    if (ingredients.isEmpty) {
      return const Center(
        child: Text('нет ингредиентов', style: TextStyle(fontSize: 12, color: AppColors.text)),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.muted, width: 3),
        borderRadius: BorderRadius.circular(5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
      child: Table(
        columnWidths: const {1: IntrinsicColumnWidth()},
        children: [
          for (final item in ingredients)
            TableRow(
              children: [
                Text(
                  '•  ${item.ingredient.name}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 27 / 14,
                    color: AppColors.text,
                  ),
                ),
                Text(
                  formatCount(item.count, item.ingredient.measureUnit),
                  style: const TextStyle(fontSize: 13, height: 27 / 13, color: AppColors.muted),
                ),
              ],
            ),
        ],
      ),
    );
  }

  /// Список шагов приготовления с отметками пройденных
  Widget _buildSteps() {
    final steps = widget.recipe.steps;
    if (steps.isEmpty) {
      return const Center(
        child: Text('нет шагов приготовления', style: TextStyle(fontSize: 12, color: AppColors.text)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 15,
      children: [
        for (final (index, step) in steps.indexed)
          RecipeStepCard(
            number: index + 1,
            step: step,
            checked: _checkedSteps.contains(index),
            onToggle: () => _toggleStep(index),
          ),
      ],
    );
  }

  /// Комментарии к рецепту в порядке добавления
  Widget _buildComments() {
    final comments = widget.manager.commentsOf(widget.recipe.id);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 32,
      children: [for (final comment in comments) CommentTile(comment: comment)],
    );
  }

  /// Кнопка-иконка поля комментария со стороной [_iconButtonSize]
  Widget _commentIconButton({required IconData icon, required VoidCallback onPressed}) {
    return IconButton(
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.standard,
      constraints: const BoxConstraints.tightFor(width: _iconButtonSize, height: _iconButtonSize),
      style: IconButton.styleFrom(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
      icon: Icon(icon, color: AppColors.primary),
    );
  }
}
