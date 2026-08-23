import 'package:recipes/data/recipes_manager.dart';

import 'fakes.dart';
import 'fixtures.dart';

/// Менеджер с уже загруженными данными
Future<RecipesManager> createTestManager({FakeFoodApi? api, InMemoryRecipesStore? store}) async {
  final manager = RecipesManager(
    api: api ?? FakeFoodApi(data: fixtureData()),
    store: store ?? InMemoryRecipesStore(comments: fixtureComments()),
  );
  await manager.init();
  return manager;
}
