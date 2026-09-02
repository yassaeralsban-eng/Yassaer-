import 'package:flutter/material.dart';

/// Design tokens per UX/UI spec section 24.
const kPrimary = Color(0xFF009688);
const kPrimaryDark = Color(0xFF006B62);
const kBackground = Color(0xFFF8FAFC);
const kSurface = Color(0xFFFFFFFF);
const kBorder = Color(0xFFDCE1E4);
const kSuccess = Color(0xFF1FA65A);
const kWarning = Color(0xFFED9414);
const kError = Color(0xFFC72E2E);
const kTextPrimary = Color(0xFF172B2B);
const kTextSecondary = Color(0xFF667085);
const kTextMuted = Color(0xFF98A2B3);

/// App theme with RTL support (UX-003).
ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    fontFamily: 'Arial',
    scaffoldBackgroundColor: kBackground,
    colorScheme: ColorScheme.fromSeed(
      seedColor: kPrimary,
      primary: kPrimary,
      surface: kSurface,
      error: kError,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: kBackground,
      foregroundColor: kTextPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        side: const BorderSide(color: kBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: _inputBorder(kBorder),
      enabledBorder: _inputBorder(kBorder),
      focusedBorder: _inputBorder(kPrimary, 1.6),
      errorBorder: _inputBorder(kError),
      labelStyle: const TextStyle(color: kTextSecondary),
      hintStyle: const TextStyle(color: kTextMuted),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 72,
      indicatorColor: const Color(0xFFDDF4F1),
      backgroundColor: kSurface,
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: kBorder),
      ),
      selectedColor: const Color(0xFFEAF8F6),
      labelStyle: const TextStyle(fontWeight: FontWeight.w700),
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );

  return base;
}

OutlineInputBorder _inputBorder(Color color, [double width = 1]) =>
    OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(color: color, width: width),
    );
