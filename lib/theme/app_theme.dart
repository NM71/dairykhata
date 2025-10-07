import 'package:flutter/material.dart';

// Custom Color Scheme for the app
class AppColors {
  // Primary brand colors
  static const Color primaryBlue = Color(0xFF0e2a62);
  static const Color primaryBlueLight = Color(0xFF113370);
  static const Color primaryBlueDark = Color(0xFF0a1f4a);

  // Accent colors
  static const Color accentGreen = Color(0xFF4CAF50);
  static const Color accentGreenLight = Color(0xFF81C784);
  static const Color accentGreenDark = Color(0xFF388E3C);

  static const Color accentOrange = Color(0xFFFF9800);
  static const Color accentOrangeLight = Color(0xFFFFB74D);
  static const Color accentOrangeDark = Color(0xFFF57C00);

  static const Color accentPurple = Color(0xFF9C27B0);
  static const Color accentPurpleLight = Color(0xFFBA68C8);
  static const Color accentPurpleDark = Color(0xFF7B1FA2);

  // Neutral colors
  static const Color surfaceLight = Color(0xFFFAFAFA);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF121212);

  // Text colors
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
}

// Light Theme Configuration
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Outfit',
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryBlue,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primaryBlueLight,
        onPrimaryContainer: Colors.white,
        secondary: AppColors.accentGreen,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.accentGreenLight,
        onSecondaryContainer: AppColors.textPrimaryLight,
        tertiary: AppColors.accentOrange,
        onTertiary: Colors.white,
        tertiaryContainer: AppColors.accentOrangeLight,
        onTertiaryContainer: AppColors.textPrimaryLight,
        error: Colors.red,
        onError: Colors.white,
        errorContainer: Color(0xFFFFDAD6),
        onErrorContainer: Color(0xFF410002),
        surface: AppColors.surfaceLight,
        onSurface: AppColors.textPrimaryLight,
        surfaceContainerHighest: Colors.white,
        onSurfaceVariant: AppColors.textSecondaryLight,
        outline: AppColors.textSecondaryLight,
        outlineVariant: Color(0xFFD0D0D0),
        scrim: Colors.black26,
      ),
      scaffoldBackgroundColor: AppColors.backgroundLight,
      cardColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.textSecondaryLight,
        elevation: 8,
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: const TextStyle(color: AppColors.textSecondaryLight),
        hintStyle: const TextStyle(color: AppColors.textSecondaryLight),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.textSecondaryLight),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
    );
  }

  // Dark Theme Configuration
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Outfit',
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryBlueLight,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primaryBlueDark,
        onPrimaryContainer: Colors.white,
        secondary: AppColors.accentGreenLight,
        onSecondary: Colors.black,
        secondaryContainer: AppColors.accentGreenDark,
        onSecondaryContainer: Colors.white,
        tertiary: AppColors.accentOrangeLight,
        onTertiary: Colors.black,
        tertiaryContainer: AppColors.accentOrangeDark,
        onTertiaryContainer: Colors.white,
        error: Color(0xFFFFB4AB),
        onError: Color(0xFF690005),
        errorContainer: Color(0xFF93000A),
        onErrorContainer: Color(0xFFFFDAD6),
        surface: AppColors.surfaceDark,
        onSurface: AppColors.textPrimaryDark,
        surfaceContainerHighest: AppColors.surfaceDark,
        onSurfaceVariant: AppColors.textSecondaryDark,
        outline: AppColors.textSecondaryDark,
        outlineVariant: Color(0xFF444444),
        scrim: Colors.black54,
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
      cardColor: AppColors.surfaceDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryBlueDark,
        foregroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        selectedItemColor: AppColors.primaryBlueLight,
        unselectedItemColor: AppColors.textSecondaryDark,
        elevation: 8,
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: const TextStyle(color: AppColors.textSecondaryDark),
        hintStyle: const TextStyle(color: AppColors.textSecondaryDark),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.textSecondaryDark),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primaryBlueLight, width: 2),
        ),
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlueLight,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryBlueLight,
        foregroundColor: Colors.white,
      ),
      expansionTileTheme: const ExpansionTileThemeData(
        textColor: Colors.white,
        collapsedTextColor: Colors.white,
        iconColor: Colors.white,
        collapsedIconColor: AppColors.textSecondaryDark,
      ),
      listTileTheme: const ListTileThemeData(
        textColor: Colors.white,
        iconColor: Colors.white,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.surfaceDark,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}
