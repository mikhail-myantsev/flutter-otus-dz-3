import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/recipes_manager.dart';
import '../models/ingredient.dart';
import '../models/measure_unit.dart';
import '../models/recipe_ingredient.dart';
import '../theme/app_colors.dart';
import '../utils/validators.dart';

/// Показывает диалог ввода ингредиента
///
/// Вернёт позицию состава или `null`, если диалог закрыли
Future<RecipeIngredient?> showIngredientDialog(
  BuildContext context, {
  required RecipesManager manager,
  RecipeIngredient? initial,
}) {
  return showDialog<RecipeIngredient>(
    context: context,
    builder: (context) => _IngredientDialog(manager: manager, initial: initial),
  );
}

/// Диалог ввода ингредиента
///
/// Название можно выбрать из каталога, и единица измерения возьмётся из него
/// Название можно ввести новое, и тогда появляется выбор единицы, а ингредиент добавится в каталог
class _IngredientDialog extends StatefulWidget {
  const _IngredientDialog({required this.manager, this.initial});

  /// Источник каталога ингредиентов и единиц измерения
  final RecipesManager manager;

  /// Исходная позиция состава при редактировании
  final RecipeIngredient? initial;

  @override
  State<_IngredientDialog> createState() => _IngredientDialogState();
}

class _IngredientDialogState extends State<_IngredientDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _name = widget.initial?.ingredient.name ?? '';
  late final _countController = TextEditingController(text: widget.initial?.count.toString());

  /// Единица измерения для нового ингредиента
  MeasureUnit? _newIngredientUnit;

  @override
  void dispose() {
    _countController.dispose();
    super.dispose();
  }

  /// Ингредиент каталога с введённым именем
  Ingredient? get _existing {
    final query = _name.trim().toLowerCase();
    return widget.manager.ingredients.where((i) => i.name.toLowerCase() == query).firstOrNull;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Новое имя попадает в каталог только при подтверждении диалога
    final ingredient = _existing ?? widget.manager.addIngredient(_name.trim(), _newIngredientUnit!);
    Navigator.pop(context, RecipeIngredient(count: int.parse(_countController.text), ingredient: ingredient));
  }

  @override
  Widget build(BuildContext context) {
    final existing = _existing;
    return Dialog(
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      // Прокрутка спасает от переполнения, когда клавиатура съедает высоту на небольших экранах
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16,
              children: [
                const Text('Ингредиент', style: TextStyle(fontSize: 16, color: AppColors.text)),
                Autocomplete<Ingredient>(
                  initialValue: TextEditingValue(text: _name),
                  displayStringForOption: (ingredient) => ingredient.name,
                  optionsBuilder: (value) {
                    final query = value.text.trim().toLowerCase();
                    if (query.isEmpty) {
                      return const Iterable<Ingredient>.empty();
                    }

                    return widget.manager.ingredients.where((i) => i.name.toLowerCase().contains(query));
                  },
                  onSelected: (ingredient) => setState(() => _name = ingredient.name),
                  fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                    return TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      validator: validateIngredientName,
                      onChanged: (value) => setState(() => _name = value),
                      decoration: const InputDecoration(labelText: 'Название ингредиента'),
                    );
                  },
                ),
                // Для нового ингредиента единицу выбирают, у известного она уже есть
                if (existing == null)
                  DropdownButtonFormField<MeasureUnit>(
                    initialValue: _newIngredientUnit,
                    items: [
                      for (final unit in widget.manager.measureUnits)
                        DropdownMenuItem(value: unit, child: Text(unit.one)),
                    ],
                    onChanged: (unit) => setState(() => _newIngredientUnit = unit),
                    validator: (unit) => unit == null ? 'Выберите единицу измерения' : null,
                    decoration: const InputDecoration(labelText: 'Единица измерения'),
                  ),
                TextFormField(
                  controller: _countController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: validateIngredientCount,
                  decoration: InputDecoration(labelText: 'Количество', suffixText: existing?.measureUnit.many),
                ),
                Center(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      minimumSize: const Size(232, 48),
                      shape: const StadiumBorder(),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    onPressed: _submit,
                    child: Text(widget.initial == null ? 'Добавить' : 'Сохранить'),
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
