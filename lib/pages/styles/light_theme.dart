import 'package:flutter/material.dart';
import 'package:my_personal_lib_app/pages/styles/app_theme.dart';

// Paleta "Biblioteca Pessoal" (tema claro): verde-floresta sobre papel.
// Valores extraídos do Figma (frames claros, fundo #FEF8F3).
class LightColors {
  LightColors._();

  // Botões, links, título das telas e barra de progresso.
  static const primary = Color(0xFF042217);
  // Destaques em verde médio (botão secundário, fita marcadora).
  static const primaryContainer = Color(0xFF1B382B);
  // Selo de status ("Lendo").
  static const primaryFixed = Color(0xFFC9EAD7);
  static const onPrimaryFixed = Color(0xFF022015);
  static const onPrimaryFixedVariant = Color(0xFF304D3F);
  // Textos de apoio: autor, rótulos em caixa alta, abas não selecionadas.
  static const secondary = Color(0xFF645E54);
  static const secondaryContainer = Color(0xFFEAE1D5);
  static const onSecondaryContainer = Color(0xFF6A645A);
  static const tertiary = Color(0xFF4A2929);
  // Texto principal e subtítulos.
  static const neutral = Color(0xFF1D1B19);
  static const onSurfaceVariant = Color(0xFF424844);
  // Placeholder dos campos e bordas.
  static const outline = Color(0xFF727974);
  static const outlineVariant = Color(0xFFE7E1DD);
  // Fundo das telas e superfícies, do mais claro ao mais escuro.
  static const surface = Color(0xFFFEF8F3);
  // campos
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  // cards
  static const surfaceContainerLow = Color(0xFFF8F3ED);
  // filtros, formulário de progresso
  static const surfaceContainer = Color(0xFFF3EDE8);
  // capas sem imagem
  static const surfaceContainerHigh = Color(0xFFEDE7E2);
  // trilho da barra de progresso
  static const surfaceContainerHighest = Color(0xFFE7E1DD);
  // Card discreto (ex.: "Sem distrações" no login).
  static const background = surfaceContainerLow;
  static const error = Color(0xFFBA1A1A);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF93000A);
}

final ColorScheme lightColorScheme = ColorScheme.fromSeed(
  seedColor: LightColors.primaryContainer,
  brightness: Brightness.light,
  dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
  primary: LightColors.primary,
  onPrimary: Colors.white,
  primaryContainer: LightColors.primaryContainer,
  onPrimaryContainer: Colors.white,
  primaryFixed: LightColors.primaryFixed,
  onPrimaryFixed: LightColors.onPrimaryFixed,
  onPrimaryFixedVariant: LightColors.onPrimaryFixedVariant,
  secondary: LightColors.secondary,
  onSecondary: Colors.white,
  secondaryContainer: LightColors.secondaryContainer,
  onSecondaryContainer: LightColors.onSecondaryContainer,
  tertiary: LightColors.tertiary,
  onTertiary: Colors.white,
  error: LightColors.error,
  onError: Colors.white,
  errorContainer: LightColors.errorContainer,
  onErrorContainer: LightColors.onErrorContainer,
  surface: LightColors.surface,
  onSurface: LightColors.neutral,
  onSurfaceVariant: LightColors.onSurfaceVariant,
  surfaceContainerLowest: LightColors.surfaceContainerLowest,
  surfaceContainerLow: LightColors.surfaceContainerLow,
  surfaceContainer: LightColors.surfaceContainer,
  surfaceContainerHigh: LightColors.surfaceContainerHigh,
  surfaceContainerHighest: LightColors.surfaceContainerHighest,
  outline: LightColors.outline,
  outlineVariant: LightColors.outlineVariant,
  inverseSurface: LightColors.neutral,
  onInverseSurface: LightColors.surface,
  inversePrimary: const Color(0xFF8CD6AE),
);

final ThemeData lightTheme = buildAppTheme(lightColorScheme);
