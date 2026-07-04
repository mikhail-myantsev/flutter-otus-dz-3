import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Тема приложения, собранная из цветовой схемы [AppColors]
abstract final class AppTheme {
  /// Светлая тема
  static ThemeData get light => ThemeData(
    fontFamily: 'Roboto',
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.accent,
    ),
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.text,
      surfaceTintColor: Colors.transparent,
      shadowColor: AppColors.shadow,
      elevation: 2,
      scrolledUnderElevation: 2,
      centerTitle: true,
      // Явный `titleTextStyle` не наследует `fontFamily` из темы, поэтому семейство продублировано
      titleTextStyle: TextStyle(fontFamily: 'Roboto', color: AppColors.text, fontSize: 24, fontWeight: FontWeight.w500),
    ),
  );
}
