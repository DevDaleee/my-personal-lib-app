import 'package:flutter/material.dart';
import 'package:my_personal_lib_app/pages/styles/app_theme.dart';

// Paleta "Biblioteca Pessoal" (tema claro): verde-floresta sobre papel.
class LightColors {
  LightColors._();

  static const primary = Color(0xFF1B3B2B);
  static const secondary = Color(0xFF8C857B);
  static const tertiary = Color(0xFF4A2929);
  static const neutral = Color(0xFF2A2825);

  static const surface = Color(0xFFF6F1E7);
  static const surfaceContainerLowest = Color(0xFFFBF8F2);
  static const surfaceContainerLow = Color(0xFFF0EBE2);
  static const surfaceContainer = Color(0xFFEAE5DC);
  static const surfaceContainerHigh = Color(0xFFE4DED4);
  static const surfaceContainerHighest = Color(0xFFDDD7CC);
}

final ColorScheme lightColorScheme = ColorScheme.fromSeed(
  seedColor: LightColors.primary,
  brightness: Brightness.light,
  dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
  primary: LightColors.primary,
  onPrimary: Colors.white,
  secondary: LightColors.secondary,
  onSecondary: Colors.white,
  secondaryContainer: const Color(0xFFE4E0D9),
  onSecondaryContainer: LightColors.neutral,
  tertiary: LightColors.tertiary,
  onTertiary: Colors.white,
  error: const Color(0xFFB3261E),
  onError: Colors.white,
  surface: LightColors.surface,
  onSurface: LightColors.neutral,
  onSurfaceVariant: const Color(0xFF5C5750),
  surfaceContainerLowest: LightColors.surfaceContainerLowest,
  surfaceContainerLow: LightColors.surfaceContainerLow,
  surfaceContainer: LightColors.surfaceContainer,
  surfaceContainerHigh: LightColors.surfaceContainerHigh,
  surfaceContainerHighest: LightColors.surfaceContainerHighest,
  outline: LightColors.secondary,
  outlineVariant: const Color(0xFFD6D0C6),
  inverseSurface: LightColors.neutral,
  onInverseSurface: LightColors.surface,
  inversePrimary: const Color(0xFF8FD4AE),
);

final ThemeData lightTheme = buildAppTheme(lightColorScheme);
