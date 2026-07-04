/// Рецепт от сервера
class Recipe {
  const Recipe({required this.id, required this.name, required this.duration, required this.photo});

  /// Уникальный идентификатор рецепта
  final int id;

  /// Название рецепта
  final String name;

  /// Время приготовления в минутах
  final int duration;

  /// Изображение рецепта
  final String photo;
}
