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
      elevation: 12,
      scrolledUnderElevation: 12,
      centerTitle: true,
      // Явный `titleTextStyle` не наследует `fontFamily` из темы, поэтому семейство продублировано
      titleTextStyle: TextStyle(fontFamily: 'Roboto', color: AppColors.text, fontSize: 24, fontWeight: FontWeight.w500),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: AppColors.field,
      labelStyle: TextStyle(color: AppColors.primary),
      floatingLabelStyle: TextStyle(color: AppColors.primary),
      hintStyle: TextStyle(color: AppColors.placeholder, fontSize: 20, fontWeight: FontWeight.w500),
      border: UnderlineInputBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(2)),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      enabledBorder: UnderlineInputBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(2)),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      focusedBorder: UnderlineInputBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(2)),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: UnderlineInputBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(2)),
        borderSide: BorderSide(color: Colors.red, width: 2),
      ),
      focusedErrorBorder: UnderlineInputBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(2)),
        borderSide: BorderSide(color: Colors.red, width: 2),
      ),
    ),
  );
}
