/// Пустое ли значение после обрезки пробелов
bool _isBlank(String? value) => value == null || value.trim().isEmpty;

/// Сообщение об ошибке, если значение пустое после обрезки пробелов, иначе `null`
String? _requireNonBlank(String? value, String message) => _isBlank(value) ? message : null;

/// Проверяет, что название рецепта является непустым после обрезки пробелов
String? validateRecipeName(String? value) => _requireNonBlank(value, 'Введите название рецепта');

/// Проверяет, что название ингредиента является непустым после обрезки пробелов
String? validateIngredientName(String? value) => _requireNonBlank(value, 'Введите название ингредиента');

/// Проверяет, что описание шага является непустым после обрезки пробелов
String? validateStepDescription(String? value) => _requireNonBlank(value, 'Введите описание шага');

/// Проверяет, что количество ингредиента является целым числом больше нуля
String? validateIngredientCount(String? value) {
  final count = int.tryParse(value ?? '');
  return (count == null || count <= 0) ? 'Введите целое число больше нуля' : null;
}

/// Проверяет, что время шага является целым числом больше нуля и меньше 59
String? validateStepTimePart(String? value) {
  if (_isBlank(value)) {
    return null;
  }

  final parsed = int.tryParse(value!);
  return (parsed == null || parsed < 0 || parsed > 59) ? 'Число от 0 до 59' : null;
}

/// Длительность шага в секундах из текстовых значений
///
/// Пустые или некорректные значения заменяет нулём
int stepDurationSeconds({required String? minutes, required String? seconds}) {
  return (int.tryParse(minutes ?? '') ?? 0) * 60 + (int.tryParse(seconds ?? '') ?? 0);
}

/// Проверяет, что суммарная длительность шага больше нуля
String? validateStepDurationTotal({required String? minutes, required String? seconds}) {
  return stepDurationSeconds(minutes: minutes, seconds: seconds) > 0 ? null : 'Длительность должна быть больше нуля';
}
