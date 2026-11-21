import 'package:flutter/material.dart';

// Famílias registradas no pubspec.yaml (arquivos em assets/fonts).
const String headlineFont = 'Newsreader';
const String bodyFont = 'SourceSans3';

// Arredondamentos do tema: pequenos, estilo "caderno de papel".
const double _smallRadius = 4;
const double _mediumRadius = 8;
const double _largeRadius = 12;

/// Monta o ThemeData comum aos temas claro e escuro.
/// Cada tema só define o próprio ColorScheme; o resto sai daqui.
ThemeData buildAppTheme(ColorScheme scheme) {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: bodyFont,
  );

  const smallShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(_smallRadius)),
  );
  const mediumShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(_mediumRadius)),
  );
  const largeShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(_largeRadius)),
  );

  const buttonPadding = EdgeInsets.symmetric(horizontal: 20, vertical: 14);
  const buttonTextStyle = TextStyle(
    fontFamily: bodyFont,
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );

  final inputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(_smallRadius),
    borderSide: BorderSide(color: scheme.outlineVariant),
  );

  return base.copyWith(
    scaffoldBackgroundColor: scheme.surface,
    textTheme: _buildTextTheme(base.textTheme, scheme),
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: headlineFont,
        fontSize: 24,
        fontWeight: FontWeight.w500,
        color: scheme.onSurface,
      ),
    ),
    cardTheme: CardThemeData(
      color: scheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: largeShape,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      shape: largeShape,
      titleTextStyle: TextStyle(
        fontFamily: headlineFont,
        fontSize: 22,
        fontWeight: FontWeight.w500,
        color: scheme.onSurface,
      ),
    ),
    dividerTheme: DividerThemeData(
      color: scheme.outlineVariant,
      thickness: 1,
      space: 1,
    ),
    // Botões: cantos quase retos, como no guia de estilo.
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: smallShape,
        padding: buttonPadding,
        textStyle: buttonTextStyle,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 0,
        shape: smallShape,
        padding: buttonPadding,
        textStyle: buttonTextStyle,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: scheme.onSurface,
        side: BorderSide(color: scheme.outline),
        shape: smallShape,
        padding: buttonPadding,
        textStyle: buttonTextStyle,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: scheme.primary,
        shape: smallShape,
        textStyle: buttonTextStyle,
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(shape: smallShape),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
      elevation: 0,
      shape: mediumShape,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainer,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: inputBorder,
      enabledBorder: inputBorder,
      focusedBorder: inputBorder.copyWith(
        borderSide: BorderSide(color: scheme.primary, width: 1.5),
      ),
      errorBorder: inputBorder.copyWith(
        borderSide: BorderSide(color: scheme.error),
      ),
      focusedErrorBorder: inputBorder.copyWith(
        borderSide: BorderSide(color: scheme.error, width: 1.5),
      ),
      hintStyle: TextStyle(color: scheme.onSurfaceVariant),
      prefixIconColor: scheme.onSurfaceVariant,
    ),
    // Barras de progresso finas, sem anel gigante.
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: scheme.primary,
      linearTrackColor: scheme.surfaceContainerHighest,
      linearMinHeight: 6,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surfaceContainer,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      indicatorColor: scheme.primary,
      indicatorShape: smallShape,
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? scheme.onPrimary
              : scheme.onSurfaceVariant,
        ),
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        shape: smallShape,
        selectedBackgroundColor: scheme.primary,
        selectedForegroundColor: scheme.onPrimary,
        side: BorderSide(color: scheme.outlineVariant),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(shape: smallShape),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: scheme.inverseSurface,
      contentTextStyle: TextStyle(
        fontFamily: bodyFont,
        color: scheme.onInverseSurface,
      ),
      shape: mediumShape,
    ),
  );
}

/// Serifada (Newsreader) em display, headline e titleLarge;
/// sem serifa (Source Sans 3) no resto.
TextTheme _buildTextTheme(TextTheme base, ColorScheme scheme) {
  final body = base.apply(
    fontFamily: bodyFont,
    bodyColor: scheme.onSurface,
    displayColor: scheme.onSurface,
  );

  TextStyle? serif(TextStyle? style, {FontWeight weight = FontWeight.w400}) =>
      style?.copyWith(fontFamily: headlineFont, fontWeight: weight);

  return body.copyWith(
    displayLarge: serif(body.displayLarge),
    displayMedium: serif(body.displayMedium),
    displaySmall: serif(body.displaySmall),
    headlineLarge: serif(body.headlineLarge),
    headlineMedium: serif(body.headlineMedium),
    headlineSmall: serif(body.headlineSmall, weight: FontWeight.w500),
    titleLarge: serif(body.titleLarge, weight: FontWeight.w500),
    labelLarge: body.labelLarge?.copyWith(fontWeight: FontWeight.w600),
  );
}
