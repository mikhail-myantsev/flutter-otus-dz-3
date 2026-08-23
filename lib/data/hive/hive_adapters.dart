import 'package:hive_ce/hive.dart';

import '../../models/comment.dart';
import '../../models/ingredient.dart';
import '../../models/measure_unit.dart';
import '../../models/recipe.dart';
import '../../models/recipe_ingredient.dart';
import '../../models/recipe_step.dart';

@GenerateAdapters([
  AdapterSpec<Recipe>(),
  AdapterSpec<RecipeIngredient>(),
  AdapterSpec<Ingredient>(),
  AdapterSpec<MeasureUnit>(),
  AdapterSpec<RecipeStep>(),
  AdapterSpec<Comment>(),
])
part 'hive_adapters.g.dart';
