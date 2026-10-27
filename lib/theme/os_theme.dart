import 'package:flutter/material.dart';

class PersonalOSTheme {
  // Deep OLED & Slate colors matching the 6 uploaded reference screenshots
  static const Color bgDark = Color(0xFF0B0D14);
  static const Color surfaceCard = Color(0xFF151824);
  static const Color surfaceElevated = Color(0xFF1E2233);
  static const Color borderSubtle = Color(0xFF282D42);

  // Signature Accents from screenshots
  static const Color primaryPurple = Color(0xFF8B5CF6); // Screenshot 1, 2, 5
  static const Color electricViolet = Color(0xFFA855F7);
  static const Color neonLime = Color(0xFF7CE785); // Screenshot 6 finance green
  static const Color neonYellow = Color(0xFFD9F99D);
  static const Color coralRed = Color(0xFFF43F5E); // Past due / expense alert
  static const Color amberWarning = Color(0xFFF59E0B);
  static const Color skyBlue = Color(0xFF38BDF8);

  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgDark,
      primaryColor: primaryPurple,
      colorScheme: const ColorScheme.dark(
        primary: primaryPurple,
        secondary: neonLime,
        surface: surfaceCard,
        error: coralRed,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: bgDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: borderSubtle, width: 1),
        ),
      ),
    );
  }
}
