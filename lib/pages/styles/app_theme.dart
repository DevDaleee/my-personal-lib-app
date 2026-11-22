import 'package:flutter/material.dart';

const String headlineFont = 'Newsreader';
const String bodyFont = 'SourceSans3';
const double smallRadius = 4;
const double mediumRadius = 8;
const double pillRadius = 12;
const double buttonHeight = 48;
const double barHeight = 64;

ThemeData buildAppTheme(ColorScheme scheme) {
  final isDark = scheme.brightness == Brightness.dark;
  final base = ThemeData(useMaterial3: true, colorScheme: scheme, fontFamily: bodyFont);
  final textTheme = _buildTextTheme(base.textTheme, scheme);

  const smallShape = RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(smallRadius)));
  const mediumShape = RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(mediumRadius)));

  const buttonPadding = EdgeInsets.symmetric(horizontal: 16);
  const buttonMinimumSize = Size(64, buttonHeight);

  final inputFill = isDark ? scheme.surfaceContainerLow : scheme.surfaceContainerLowest;
  OutlineInputBorder inputBorder(Color color, [double width = 1]) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(smallRadius),
    borderSide: BorderSide(color: color, width: width),
  );

  final cardSide = isDark ? BorderSide(color: scheme.outlineVariant) : BorderSide.none;

  return base.copyWith(
    scaffoldBackgroundColor: scheme.surface,
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.primary,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      toolbarHeight: barHeight,
      titleSpacing: 16,
      titleTextStyle: TextStyle(fontFamily: headlineFont, fontSize: 21, height: 28 / 21, letterSpacing: -0.525, fontWeight: FontWeight.w400, color: isDark ? scheme.onSurface : scheme.primary),
    ),
    cardTheme: CardThemeData(
      color: scheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: const BorderRadius.all(Radius.circular(mediumRadius)), side: cardSide),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      shape: mediumShape,
      titleTextStyle: textTheme.titleLarge,
      contentTextStyle: textTheme.bodyMedium,
    ),
    dividerTheme: DividerThemeData(color: scheme.outlineVariant, thickness: 1, space: 1),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        minimumSize: buttonMinimumSize,
        shape: smallShape,
        padding: buttonPadding,
        textStyle: textTheme.labelLarge,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 0,
        minimumSize: buttonMinimumSize,
        shape: smallShape,
        padding: buttonPadding,
        textStyle: textTheme.labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: scheme.onSurface,
        side: BorderSide(color: scheme.outline),
        minimumSize: buttonMinimumSize,
        shape: smallShape,
        padding: buttonPadding,
        textStyle: textTheme.labelLarge,
      ),
    ),
    // Links de texto ("Criar conta", "Esqueceu?"): sem preenchimento extra.
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: scheme.primary,
        shape: smallShape,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: textTheme.labelMedium,
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(foregroundColor: scheme.secondary, shape: smallShape),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: scheme.primary, foregroundColor: scheme.onPrimary, elevation: 0, shape: smallShape),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: inputFill,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: inputBorder(scheme.outlineVariant),
      enabledBorder: inputBorder(scheme.outlineVariant),
      focusedBorder: inputBorder(scheme.primary, 1.5),
      errorBorder: inputBorder(scheme.error),
      focusedErrorBorder: inputBorder(scheme.error, 1.5),
      hintStyle: textTheme.bodyLarge?.copyWith(color: scheme.outline),
      errorStyle: textTheme.bodyMedium?.copyWith(color: scheme.error, fontWeight: FontWeight.w500),
      prefixIconColor: scheme.secondary,
      suffixIconColor: scheme.secondary,
    ),
    // Barras de progresso: 4px, cantos arredondados, trilho discreto.
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: scheme.primary,
      linearTrackColor: scheme.surfaceContainerHighest,
      linearMinHeight: 4,
      borderRadius: const BorderRadius.all(Radius.circular(pillRadius)),
    ),
    // Barra inferior: sem "pílula"; item selecionado na cor primária.
    navigationBarTheme: NavigationBarThemeData(
      height: barHeight,
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      indicatorColor: Colors.transparent,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(size: 20, color: states.contains(WidgetState.selected) ? scheme.primary : scheme.secondary)),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => textTheme.labelSmall?.copyWith(letterSpacing: 0.275, color: states.contains(WidgetState.selected) ? scheme.primary : scheme.secondary),
      ),
    ),
    // Filtro por status: trilho em surfaceContainer, opção selecionada destacada.
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        backgroundColor: scheme.surfaceContainer,
        foregroundColor: scheme.secondary,
        selectedBackgroundColor: isDark ? scheme.surfaceContainerHigh : scheme.surface,
        selectedForegroundColor: scheme.primary,
        side: BorderSide(color: isDark ? scheme.surfaceContainerHigh : scheme.surfaceContainer),
        shape: smallShape,
        textStyle: textTheme.labelMedium,
        visualDensity: VisualDensity.compact,
      ),
    ),
    // Selos de status ("Lendo", "Quero ler", "Lido").
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: scheme.secondaryContainer,
      labelStyle: textTheme.bodySmall?.copyWith(color: scheme.onSecondaryContainer),
      side: BorderSide.none,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(2))),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: scheme.inverseSurface,
      contentTextStyle: textTheme.bodyMedium?.copyWith(color: scheme.onInverseSurface),
      shape: smallShape,
    ),
  );
}

TextTheme _buildTextTheme(TextTheme base, ColorScheme scheme) {
  TextStyle serif(double size, double lineHeight, {FontWeight weight = FontWeight.w400, double letterSpacing = 0}) =>
      TextStyle(fontFamily: headlineFont, fontSize: size, height: lineHeight / size, fontWeight: weight, letterSpacing: letterSpacing);

  TextStyle sans(double size, double lineHeight, {FontWeight weight = FontWeight.w400, double letterSpacing = 0}) =>
      TextStyle(fontFamily: bodyFont, fontSize: size, height: lineHeight / size, fontWeight: weight, letterSpacing: letterSpacing);

  return base
      .copyWith(
        displaySmall: serif(34, 34, letterSpacing: -0.85),
        headlineMedium: serif(28, 36, letterSpacing: -0.7),
        headlineSmall: serif(22, 30, letterSpacing: -0.55),
        titleLarge: serif(18, 24, weight: FontWeight.w500),
        titleMedium: sans(15, 22, weight: FontWeight.w500),
        titleSmall: sans(14, 20, weight: FontWeight.w600, letterSpacing: 0.14),
        bodyLarge: sans(15, 22),
        bodyMedium: sans(13, 18),
        bodySmall: sans(11, 16.5),
        labelLarge: sans(14, 20, weight: FontWeight.w600, letterSpacing: 0.14),
        labelMedium: sans(12, 16, weight: FontWeight.w500, letterSpacing: 0.24),
        labelSmall: sans(11, 14, weight: FontWeight.w600, letterSpacing: 1.1),
      )
      .apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);
}
