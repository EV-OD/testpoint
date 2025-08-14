import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF3F51B5),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFC5CAE9),
    onPrimaryContainer: Color(0xFF1A237E),
    secondary: Color(0xFFFF9800),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFFFCC80),
    onSecondaryContainer: Color(0xFFE65100),
    tertiary: Color(0xFFFF9800),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFFFCC80),
    onTertiaryContainer: Color(0xFFE65100),
    error: Color(0xFFBA1A1A),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),
    surface: Color(0xFFF0F0F0),
    onSurface: Color(0xFF1A1C19),
    surfaceContainerHighest: Color(0xFFDEE5D9),
    onSurfaceVariant: Color(0xFF424940),
    outline: Color(0xFF727970),
    outlineVariant: Color(0xFFC2C8BC),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFF2F312D),
    onInverseSurface: Color(0xFFF0F1EB),
    inversePrimary: Color(0xFF9FA8DA),
  );

  static const _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF9FA8DA),
    onPrimary: Color(0xFF1A237E),
    primaryContainer: Color(0xFF3F51B5),
    onPrimaryContainer: Color(0xFFC5CAE9),
    secondary: Color(0xFFFFB74D),
    onSecondary: Color(0xFF424242),
    secondaryContainer: Color(0xFFFF9800),
    onSecondaryContainer: Color(0xFFFFCC80),
    tertiary: Color(0xFFFFB74D),
    onTertiary: Color(0xFF424242),
    tertiaryContainer: Color(0xFFFF9800),
    onTertiaryContainer: Color(0xFFFFCC80),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFB4AB),
    surface: Color(0xFF1A1C19),
    onSurface: Color(0xFFE2E3DD),
    surfaceContainerHighest: Color(0xFF424940),
    onSurfaceVariant: Color(0xFFC2C8BC),
    outline: Color(0xFF8C9388),
    outlineVariant: Color(0xFF424940),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFFE2E3DD),
    onInverseSurface: Color(0xFF2F312D),
    inversePrimary: Color(0xFF3F51B5),
  );

  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: _lightColorScheme,
      textTheme: GoogleFonts.latoTextTheme(),
      useMaterial3: true,
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: TextStyle(
          color: _lightColorScheme.onSurface,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _lightColorScheme.surface.withOpacity(0.5),
        hintStyle: TextStyle(
          color: _lightColorScheme.onSurfaceVariant,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      colorScheme: _darkColorScheme,
      textTheme: GoogleFonts.latoTextTheme(),
      useMaterial3: true,
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: TextStyle(
          color: _darkColorScheme.onSurface,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkColorScheme.surfaceContainerHighest.withOpacity(0.3),
        hintStyle: TextStyle(
          color: _darkColorScheme.onSurfaceVariant,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
