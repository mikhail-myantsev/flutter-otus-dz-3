import '../models/recipe.dart';

// TODO: Заменить константный список данными с сервера
/// Точка доступа к рецептам
class RecipesManager {
  const RecipesManager();

  /// Возвращает **все** доступные рецепты
  List<Recipe> getRecipes() => _recipes;

  /// Тестовый набор данных **до подключения сервера**
  static const List<Recipe> _recipes = [
    Recipe(id: 0, name: 'Лосось в соусе терияки', duration: 45, photo: 'assets/images/recipe_0.jpg'),
    Recipe(id: 1, name: 'Поке боул с сыром тофу', duration: 30, photo: 'assets/images/recipe_1.jpg'),
    Recipe(
      id: 2,
      name: 'Стейк из говядины по-грузински с кукурузой',
      duration: 75,
      photo: 'assets/images/recipe_2.jpg',
    ),
    Recipe(id: 3, name: 'Тосты с голубикой и бананом', duration: 45, photo: 'assets/images/recipe_3.jpg'),
    Recipe(id: 4, name: 'Паста с морепродуктами', duration: 25, photo: 'assets/images/recipe_4.jpg'),
    Recipe(id: 5, name: 'Бургер с двумя котлетами', duration: 60, photo: 'assets/images/recipe_5.jpg'),
    Recipe(id: 6, name: 'Пицца Маргарита домашняя', duration: 25, photo: 'assets/images/recipe_6.jpg'),
  ];
}
