import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Color palette matching design/home.png and SKILL.md
  static const Color background = Color(0xff000000);
  static const Color cardBg = Color(0xff111622);
  static const Color accent = Color(0xffE5C07B); // Geo Gold
  static const Color textPrimary = Color(0xffFFFFFF);
  static const Color textMuted = Color(0xffA0AAB5);
  static const Color borderSubtle = Color(0x1fffffff);
  static const Color surfaceElevated = Color(0xff1c2436);

  // Spacing system (4pt grid from SKILL.md)
  static const double space1 = 4.0;
  static const double space2 = 8.0;
  static const double space3 = 12.0;
  static const double space4 = 16.0;
  static const double space6 = 24.0;
  static const double space8 = 32.0;
  static const double space12 = 48.0;
  static const double space16 = 64.0;

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: accent,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        secondary: accent,
        surface: cardBg,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(
        ThemeData.dark().textTheme,
      ).copyWith(
        titleLarge: GoogleFonts.plusJakartaSans(
          color: textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
        bodyLarge: GoogleFonts.plusJakartaSans(
          color: textPrimary,
          fontSize: 16,
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          color: textMuted,
          fontSize: 14,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
    );
  }
}
