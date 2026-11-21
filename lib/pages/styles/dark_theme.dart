import 'package:flutter/material.dart';
import 'package:my_personal_lib_app/pages/styles/app_theme.dart';

// Paleta "Nocturne Folio" (tema escuro): verde-menta sobre tinta.
class DarkColors {
  DarkColors._();

  static const primary = Color(0xFF5BA37E);
  static const secondary = Color(0xFFD4CEC6);
  static const tertiary = Color(0xFFD17D81);
  static const neutral = Color(0xFF121614);

  static const surface = neutral;
  static const surfaceContainerLowest = Color(0xFF0D100F);
  static const surfaceContainerLow = Color(0xFF181C1A);
  static const surfaceContainer = Color(0xFF1C211F);
  static const surfaceContainerHigh = Color(0xFF232826);
  static const surfaceContainerHighest = Color(0xFF2B302E);
}

final ColorScheme darkColorScheme = ColorScheme.fromSeed(
  seedColor: DarkColors.primary,
  brightness: Brightness.dark,
  dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
  primary: DarkColors.primary,
  onPrimary: const Color(0xFF0B1F15),
  secondary: DarkColors.secondary,
  onSecondary: const Color(0xFF2A2825),
  secondaryContainer: const Color(0xFF2E3330),
  onSecondaryContainer: DarkColors.secondary,
  tertiary: DarkColors.tertiary,
  onTertiary: const Color(0xFF2B0E10),
  error: const Color(0xFFF2B8B5),
  onError: const Color(0xFF601410),
  surface: DarkColors.surface,
  onSurface: const Color(0xFFE3E2DE),
  onSurfaceVariant: const Color(0xFFB4BAB6),
  surfaceContainerLowest: DarkColors.surfaceContainerLowest,
  surfaceContainerLow: DarkColors.surfaceContainerLow,
  surfaceContainer: DarkColors.surfaceContainer,
  surfaceContainerHigh: DarkColors.surfaceContainerHigh,
  surfaceContainerHighest: DarkColors.surfaceContainerHighest,
  outline: const Color(0xFF8A908C),
  outlineVariant: const Color(0xFF3A403D),
  inverseSurface: const Color(0xFFE3E2DE),
  onInverseSurface: const Color(0xFF2A2825),
  inversePrimary: const Color(0xFF1B3B2B),
);

final ThemeData darkTheme = buildAppTheme(darkColorScheme);
