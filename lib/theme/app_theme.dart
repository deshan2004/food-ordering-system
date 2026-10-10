import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Bonchi Brand Colors
  static const Color primaryGreen = Color(0xFF059669); // Bonchi Emerald Green
  static const Color primaryGreenLight = Color(0xFF10B981);
  static const Color accentAmber = Color(0xFFFF9F0A);
  static const Color primaryOrange = Color(0xFFFF9F0A);
  static const Color accentRed = Color(0xFFEF4444);
  static const Color starYellow = Color(0xFFFFB800);

  // Surface & Neutral Colors (Light)
  static const Color lightBackground = Color(0xFFF4F5F7);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE5E7EB);

  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);

  // Surface & Neutral Colors (Dark)
  static const Color darkBackground = Color(0xFF0B0F19); // Obsidian Slate
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkBorder = Color(0xFF334155);

  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF64748B);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightBackground,
    colorScheme: const ColorScheme.light(
      primary: primaryGreen,
      secondary: accentAmber,
      surface: lightSurface,
      error: accentRed,
      onPrimary: Colors.white,
      onSurface: textPrimary,
    ),
    textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.light().textTheme).copyWith(
      headlineLarge: const TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 26),
      headlineMedium: const TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 20),
      titleLarge: const TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
      titleMedium: const TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 15),
      bodyLarge: const TextStyle(color: textPrimary, fontSize: 14),
      bodyMedium: const TextStyle(color: textSecondary, fontSize: 12.5),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: lightBackground,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: textPrimary),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: lightSurface,
      selectedItemColor: primaryGreen,
      unselectedItemColor: textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 10,
    ),
    cardTheme: CardThemeData(
      color: Colors.white.withValues(alpha: 0.92),
      elevation: 0,
      shadowColor: Colors.black.withValues(alpha: 0.04),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.95), width: 1.2),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: primaryGreenLight,
      secondary: accentAmber,
      surface: darkSurface,
      error: accentRed,
      onPrimary: Colors.white,
      onSurface: darkTextPrimary,
    ),
    textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme).copyWith(
      headlineLarge: const TextStyle(color: darkTextPrimary, fontWeight: FontWeight.bold, fontSize: 26),
      headlineMedium: const TextStyle(color: darkTextPrimary, fontWeight: FontWeight.bold, fontSize: 20),
      titleLarge: const TextStyle(color: darkTextPrimary, fontWeight: FontWeight.bold, fontSize: 18),
      titleMedium: const TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w600, fontSize: 15),
      bodyLarge: const TextStyle(color: darkTextPrimary, fontSize: 14),
      bodyMedium: const TextStyle(color: darkTextSecondary, fontSize: 12.5),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkBackground,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: darkTextPrimary),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: darkSurface,
      selectedItemColor: primaryGreenLight,
      unselectedItemColor: darkTextSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 10,
    ),
    cardTheme: CardThemeData(
      color: darkSurface.withValues(alpha: 0.94),
      elevation: 0,
      shadowColor: Colors.black.withValues(alpha: 0.25),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: darkBorder.withValues(alpha: 0.8), width: 1.2),
      ),
    ),
  );

  /// Reusable frosted glass decoration for cards, pills, and panels (Adapts to Dark / Light)
  static BoxDecoration glassDecoration({
    double opacity = 0.90,
    double borderRadius = 20,
    Color? borderColor,
    double borderWidth = 1.2,
    double blurRadius = 14,
    Offset shadowOffset = const Offset(0, 4),
    double shadowOpacity = 0.04,
    Color? baseColor,
    bool isDark = false,
  }) {
    final effectiveBase = baseColor ?? (isDark ? const Color(0xFF1E293B) : Colors.white);
    final effectiveBorder = borderColor ??
        (isDark ? const Color(0xFF334155) : Colors.white.withValues(alpha: 0.95));

    return BoxDecoration(
      color: effectiveBase.withValues(alpha: opacity),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: effectiveBorder,
        width: borderWidth,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? (shadowOpacity * 2.5).clamp(0.08, 0.3) : shadowOpacity),
          blurRadius: blurRadius,
          offset: shadowOffset,
        ),
      ],
    );
  }
}
