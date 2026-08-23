import 'package:flutter/material.dart';

import '../data/recipes_manager.dart';
import '../models/recipe_ingredient.dart';
import '../models/recipe_step.dart';
import '../theme/app_colors.dart';
import '../utils/validators.dart';
import '../widgets/ingredient_dialog.dart';
import '../widgets/landscape_half_width.dart';
import '../widgets/recipe_ingredient_tile.dart';
import '../widgets/recipe_photo.dart';
import '../widgets/recipe_step_tile.dart';
import '../widgets/step_dialog.dart';

/// Страница создания нового рецепта
class AddRecipePage extends StatefulWidget {
  const AddRecipePage({super.key, required this.manager});

  /// Хранилище рецептов
  final RecipesManager manager;

  /// Маршрут на эту страницу
  static Route<void> route({required RecipesManager manager}) {
    return MaterialPageRoute(builder: (_) => AddRecipePage(manager: manager));
  }

  @override
  State<AddRecipePage> createState() => _AddRecipePageState();
}

class _AddRecipePageState extends State<AddRecipePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ingredients = <RecipeIngredient>[];
  final _steps = <RecipeStep>[];

  /// Идёт сохранение рецепта
  bool _isSaving = false;

  /// Для определения активности кнопки сохранения
  bool get _canSave {
    return !_isSaving && _nameController.text.trim().isNotEmpty && _ingredients.isNotEmpty && _steps.isNotEmpty;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _addIngredient() async {
    final added = await showIngredientDialog(context, manager: widget.manager);
    if (added == null) {
      return;
    }

    setState(() => _ingredients.add(added));
  }

  Future<void> _editIngredient(int index) async {
    final edited = await showIngredientDialog(context, manager: widget.manager, initial: _ingredients[index]);
    if (edited == null) {
      return;
    }

    setState(() => _ingredients[index] = edited);
  }

  Future<void> _addStep() async {
    final added = await showStepDialog(context);
    if (added == null) {
      return;
    }

    setState(() => _steps.add(added));
  }

  Future<void> _editStep(int index) async {
    final edited = await showStepDialog(context, initial: _steps[index]);
    if (edited == null) {
      return;
    }

    setState(() => _steps[index] = edited);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      await widget.manager.saveRecipe(name: _nameController.text.trim(), ingredients: _ingredients, steps: _steps);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }

    if (!mounted) {
      return;
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Новый рецепт',
          style: TextStyle(fontFamily: 'Roboto', fontSize: 20, fontWeight: FontWeight.w400, color: AppColors.primary),
        ),
      ),
      body: Center(
        child: LandscapeHalfWidth(
          child: Form(
            key: _formKey,
            // Для обновления цвета кнопки сохранения
            onChanged: () => setState(() {}),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 24,
                children: [
                  TextFormField(
                    controller: _nameController,
                    validator: validateRecipeName,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: const InputDecoration(labelText: 'Название рецепта'),
                  ),
                  // TODO: Показывать выбранное фото после реализации его загрузки
                  const SizedBox(height: 215, child: RecipePhoto(photo: '')),
                  const Text(
                    'Ингредиенты',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.primary),
                  ),
                  if (_ingredients.isEmpty)
                    const Center(
                      child: Text('нет ингредиентов', style: TextStyle(fontSize: 12, color: AppColors.text)),
                    )
                  else
                    Column(
                      spacing: 8,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final (index, item) in _ingredients.indexed)
                          RecipeIngredientTile(
                            item: item,
                            onEdit: () => _editIngredient(index),
                            onDelete: () => setState(() => _ingredients.removeAt(index)),
                          ),
                      ],
                    ),
                  Center(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary, width: 3),
                        minimumSize: const Size(232, 48),
                        shape: const StadiumBorder(),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      onPressed: _addIngredient,
                      child: const Text('Добавить ингредиент'),
                    ),
                  ),
                  const Text(
                    'Шаги приготовления',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.primary),
                  ),
                  if (_steps.isEmpty)
                    const Center(
                      child: Text('нет шагов приготовления', style: TextStyle(fontSize: 12, color: AppColors.text)),
                    )
                  else
                    Column(
                      spacing: 8,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final (index, step) in _steps.indexed)
                          RecipeStepTile(
                            number: index + 1,
                            step: step,
                            onEdit: () => _editStep(index),
                            onDelete: () => setState(() => _steps.removeAt(index)),
                          ),
                      ],
                    ),
                  Center(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary, width: 3),
                        minimumSize: const Size(232, 48),
                        shape: const StadiumBorder(),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      onPressed: _addStep,
                      child: const Text('Добавить шаг'),
                    ),
                  ),
                  Center(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        disabledBackgroundColor: AppColors.muted,
                        disabledForegroundColor: AppColors.background,
                        minimumSize: const Size(232, 48),
                        shape: const StadiumBorder(),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      onPressed: _canSave ? _save : null,
                      child: _isSaving
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.background),
                            )
                          : const Text('Сохранить рецепт'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
