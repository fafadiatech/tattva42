import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

ThemeData buildAppTheme({bool dark = false, AppColors colors = const AppColors()}) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: colors.seed,
    brightness: dark ? Brightness.dark : Brightness.light,
  );

  // Build the base M3 theme, then layer fonts and the +2pt size bump on top.
  const double fontSizeDelta = 2;
  final baseTheme = ThemeData(useMaterial3: true, colorScheme: colorScheme);

  // 1. Apply Inter as the base font for the entire text theme.
  // 2. Overlay Manrope on the heading slots (display*, headline*, title*).
  // 3. Bump all explicit sizes by fontSizeDelta.
  final textTheme = _applyFonts(baseTheme.textTheme);
  final primaryTextTheme = _applyFonts(baseTheme.primaryTextTheme);

  return baseTheme.copyWith(
    textTheme: _bumpTextTheme(textTheme, fontSizeDelta),
    primaryTextTheme: _bumpTextTheme(primaryTextTheme, fontSizeDelta),
    extensions: [colors],
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      titleSpacing: 16,
      toolbarHeight: kToolbarHeight,
    ),
    navigationBarTheme: NavigationBarThemeData(
      indicatorColor: colorScheme.secondaryContainer,
      labelTextStyle: WidgetStateProperty.all(
        AppTextStyles.metaLabel.copyWith(fontWeight: FontWeight.w500),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant.withAlpha(128)),
      ),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  );
}

/// Applies Inter to all text theme slots, then overlays Manrope on the
/// heading slots (display*, headline*, title*).
///
/// Each call preserves the existing size, weight, color and other attributes
/// from [theme] — only the font family changes.
TextTheme _applyFonts(TextTheme theme) {
  // Inter for the full theme first.
  final inter = GoogleFonts.interTextTheme(theme);

  // Then replace heading slots with Manrope, keeping all other attributes.
  return inter.copyWith(
    displayLarge:  GoogleFonts.manrope(textStyle: inter.displayLarge),
    displayMedium: GoogleFonts.manrope(textStyle: inter.displayMedium),
    displaySmall:  GoogleFonts.manrope(textStyle: inter.displaySmall),
    headlineLarge:  GoogleFonts.manrope(textStyle: inter.headlineLarge),
    headlineMedium: GoogleFonts.manrope(textStyle: inter.headlineMedium),
    headlineSmall:  GoogleFonts.manrope(textStyle: inter.headlineSmall),
    titleLarge:  GoogleFonts.manrope(textStyle: inter.titleLarge),
    titleMedium: GoogleFonts.manrope(textStyle: inter.titleMedium),
    titleSmall:  GoogleFonts.manrope(textStyle: inter.titleSmall),
  );
}

/// Adds [delta] to every [TextStyle] in [theme] that already has an explicit
/// [fontSize]. Styles with `fontSize == null` are left untouched — they rely
/// on ambient inheritance and must not have a delta forced onto them
/// (doing so via [TextTheme.apply] triggers an assertion).
TextTheme _bumpTextTheme(TextTheme theme, double delta) {
  TextStyle? bump(TextStyle? s) =>
      s?.fontSize != null ? s!.copyWith(fontSize: s.fontSize! + delta) : s;

  return theme.copyWith(
    displayLarge:  bump(theme.displayLarge),
    displayMedium: bump(theme.displayMedium),
    displaySmall:  bump(theme.displaySmall),
    headlineLarge:  bump(theme.headlineLarge),
    headlineMedium: bump(theme.headlineMedium),
    headlineSmall:  bump(theme.headlineSmall),
    titleLarge:  bump(theme.titleLarge),
    titleMedium: bump(theme.titleMedium),
    titleSmall:  bump(theme.titleSmall),
    bodyLarge:  bump(theme.bodyLarge),
    bodyMedium: bump(theme.bodyMedium),
    bodySmall:  bump(theme.bodySmall),
    labelLarge:  bump(theme.labelLarge),
    labelMedium: bump(theme.labelMedium),
    labelSmall:  bump(theme.labelSmall),
  );
}
