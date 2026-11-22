import 'package:flutter/material.dart';
import 'package:my_personal_lib_app/pages/styles/app_theme.dart';

// Paleta "Nocturne Folio" (tema escuro): verde-menta sobre tinta.
// Valores extraídos do Figma (frames escuros, fundo #101412).
class DarkColors {
  DarkColors._();
  // Botões, links, filtro selecionado e barra de progresso.
  static const primary = Color(0xFF8CD6AE);
  static const onPrimary = Color(0xFF003823);
  // Verde médio (botão "Entrar", ícones e rótulos de destaque).
  static const primaryContainer = Color(0xFF5BA37E);
  static const onPrimaryContainer = Color(0xFF003521);
  // Selo de status ("Lendo").
  static const primaryFixed = Color(0xFF1B201D);
  static const onPrimaryFixed = Color(0xFF8CD6AE);
  static const onPrimaryFixedVariant = Color(0xFF8CD6AE);
  // Textos de apoio: autor, rótulos em caixa alta, ícones.
  static const secondary = Color(0xFFCBC6BE);
  static const onSecondary = Color(0xFF2A2825);
  static const secondaryContainer = Color(0xFF4A4640);
  static const onSecondaryContainer = Color(0xFFE8E3DC);
  static const tertiary = Color(0xFFD17D81);
  // Texto principal e subtítulos.
  static const neutral = Color(0xFFE0E3DF);
  static const onSurfaceVariant = Color(0xFFBFC9C0);
  // Placeholder dos campos e bordas.
  static const outline = Color(0xFF89938B);
  static const outlineVariant = Color(0xFF2B332E);
  // Fundo das telas e superfícies, do mais escuro ao mais claro.
  static const surface = Color(0xFF101412);
  static const surfaceContainerLowest = Color(0xFF0B0F0D);
  // cards e campos
  static const surfaceContainerLow = Color(0xFF181C1A);
  // formulário de progresso
  static const surfaceContainer = Color(0xFF1C201E);
  // capas sem imagem, filtro selecionado
  static const surfaceContainerHigh = Color(0xFF272B29);
  // trilho da barra de progresso
  static const surfaceContainerHighest = Color(0xFF323633);
  // Card discreto (ex.: "Sem distrações" no login).
  static const background = surfaceContainerLow;

  static const error = Color(0xFFFFB4AB);
  static const onError = Color(0xFF690005);
  static const errorContainer = Color(0xFF2D1416);
  static const onErrorContainer = Color(0xFFF08C8C);
}

final ColorScheme darkColorScheme = ColorScheme.fromSeed(
  seedColor: DarkColors.primaryContainer,
  brightness: Brightness.dark,
  dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
  primary: DarkColors.primary,
  onPrimary: DarkColors.onPrimary,
  primaryContainer: DarkColors.primaryContainer,
  onPrimaryContainer: DarkColors.onPrimaryContainer,
  primaryFixed: DarkColors.primaryFixed,
  onPrimaryFixed: DarkColors.onPrimaryFixed,
  onPrimaryFixedVariant: DarkColors.onPrimaryFixedVariant,
  secondary: DarkColors.secondary,
  onSecondary: DarkColors.onSecondary,
  secondaryContainer: DarkColors.secondaryContainer,
  onSecondaryContainer: DarkColors.onSecondaryContainer,
  tertiary: DarkColors.tertiary,
  onTertiary: const Color(0xFF2B0E10),
  error: DarkColors.error,
  onError: DarkColors.onError,
  errorContainer: DarkColors.errorContainer,
  onErrorContainer: DarkColors.onErrorContainer,
  surface: DarkColors.surface,
  onSurface: DarkColors.neutral,
  onSurfaceVariant: DarkColors.onSurfaceVariant,
  surfaceContainerLowest: DarkColors.surfaceContainerLowest,
  surfaceContainerLow: DarkColors.surfaceContainerLow,
  surfaceContainer: DarkColors.surfaceContainer,
  surfaceContainerHigh: DarkColors.surfaceContainerHigh,
  surfaceContainerHighest: DarkColors.surfaceContainerHighest,
  outline: DarkColors.outline,
  outlineVariant: DarkColors.outlineVariant,
  inverseSurface: DarkColors.neutral,
  onInverseSurface: const Color(0xFF2A2825),
  inversePrimary: const Color(0xFF042217),
);

final ThemeData darkTheme = buildAppTheme(darkColorScheme);
