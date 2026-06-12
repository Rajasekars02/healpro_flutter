import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Brand Palette ────────────────────────────────────────────────────────
  static const Color primaryColor   = Color(0xFF1E88E5); // Medical Blue
  static const Color secondaryColor = Color(0xFF00C2CB); // Teal accent
  static const Color accentColor    = Color(0xFFFF5E7E); // Coral-pink

  // Light surface palette
  static const Color lightBackground = Color(0xFFF4F6FC);
  static const Color lightSurface    = Color(0xFFFFFFFF);
  static const Color lightCard       = Color(0xFFFFFFFF);

  // Dark surface palette
  static const Color darkBackground = Color(0xFF0F0E1A);
  static const Color darkSurface    = Color(0xFF1A1830);
  static const Color darkCard       = Color(0xFF221F38);
  static const Color textLight      = Color(0xFFE8E8F4);

  // Risk semantic colors
  static const Color riskLow      = Color(0xFF22C55E);
  static const Color riskModerate = Color(0xFFF97316);
  static const Color riskHigh     = Color(0xFFEF4444);

  // ── Shared helpers ────────────────────────────────────────────────────────
  static TextTheme _buildTextTheme(TextTheme base) =>
      GoogleFonts.outfitTextTheme(base);

  static InputDecorationTheme _inputTheme(ColorScheme cs) =>
      InputDecorationTheme(
        filled: true,
        fillColor: cs.surfaceVariant.withOpacity(0.5),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: cs.outline.withOpacity(0.4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: cs.outline.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: cs.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: cs.error),
        ),
        labelStyle: TextStyle(color: cs.onSurface.withOpacity(0.7)),
      );

  static ElevatedButtonThemeData _elevatedBtnTheme(ColorScheme cs) =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle:
              const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      );

  static CardTheme _cardTheme(Color cardColor) => CardTheme(
        color: cardColor,
        elevation: 2,
        shadowColor: primaryColor.withOpacity(0.08),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(vertical: 6),
      );

  // ── Light Theme ────────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    final cs = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
      surface: lightSurface,
      surfaceVariant: const Color(0xFFEEEDF8),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: lightBackground,
      textTheme: _buildTextTheme(ThemeData.light().textTheme),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: lightBackground,
        foregroundColor: darkBackground,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: darkBackground,
        ),
      ),
      tabBarTheme: TabBarTheme(
        labelColor: primaryColor,
        unselectedLabelColor: Colors.grey[500],
        indicatorSize: TabBarIndicatorSize.label,
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: primaryColor, width: 3),
          borderRadius: BorderRadius.all(Radius.circular(2)),
        ),
        labelStyle:
            const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      ),
      cardTheme: _cardTheme(lightCard),
      inputDecorationTheme: _inputTheme(cs),
      elevatedButtonTheme: _elevatedBtnTheme(cs),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith(
            (s) => s.contains(MaterialState.selected) ? primaryColor : Colors.grey[400]),
        trackColor: MaterialStateProperty.resolveWith(
            (s) => s.contains(MaterialState.selected) ? primaryColor.withOpacity(0.3) : Colors.grey[200]),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide(color: primaryColor.withOpacity(0.3)),
        labelStyle: const TextStyle(fontSize: 13),
      ),
      dividerTheme: const DividerThemeData(space: 0, thickness: 0.8),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: lightSurface,
        indicatorColor: primaryColor.withOpacity(0.12),
        labelTextStyle: MaterialStateProperty.resolveWith(
          (s) => TextStyle(
            fontSize: 11,
            fontWeight: s.contains(MaterialState.selected) ? FontWeight.w700 : FontWeight.w500,
            color: s.contains(MaterialState.selected) ? primaryColor : Colors.grey[500],
          ),
        ),
        iconTheme: MaterialStateProperty.resolveWith(
          (s) => IconThemeData(
            color: s.contains(MaterialState.selected) ? primaryColor : Colors.grey[500],
            size: 22,
          ),
        ),
      ),
    );
  }

  // ── Dark Theme ────────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    final cs = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
      primary: const Color(0xFF64B5F6),
      secondary: secondaryColor,
      tertiary: accentColor,
      surface: darkSurface,
      surfaceVariant: const Color(0xFF2A2640),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: darkBackground,
      textTheme: _buildTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: textLight,
        displayColor: textLight,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 2,
        backgroundColor: darkBackground,
        foregroundColor: textLight,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textLight,
        ),
      ),
      tabBarTheme: TabBarTheme(
        labelColor: const Color(0xFF64B5F6),
        unselectedLabelColor: Colors.grey[600],
        indicatorSize: TabBarIndicatorSize.label,
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: Color(0xFF64B5F6), width: 3),
          borderRadius: BorderRadius.all(Radius.circular(2)),
        ),
        labelStyle:
            const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      ),
      cardTheme: _cardTheme(darkCard),
      inputDecorationTheme: _inputTheme(cs),
      elevatedButtonTheme: _elevatedBtnTheme(cs),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith(
            (s) => s.contains(MaterialState.selected) ? const Color(0xFF64B5F6) : Colors.grey[600]),
        trackColor: MaterialStateProperty.resolveWith(
            (s) => s.contains(MaterialState.selected) ? const Color(0xFF64B5F6).withOpacity(0.4) : Colors.grey[800]),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: const BorderSide(color: Color(0xFF64B5F6), width: 0.5),
        labelStyle: const TextStyle(fontSize: 13),
      ),
      dividerTheme: DividerThemeData(space: 0, thickness: 0.8, color: Colors.white.withOpacity(0.08)),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: darkSurface,
        indicatorColor: const Color(0xFF64B5F6).withOpacity(0.18),
        labelTextStyle: MaterialStateProperty.resolveWith(
          (s) => TextStyle(
            fontSize: 11,
            fontWeight: s.contains(MaterialState.selected) ? FontWeight.w700 : FontWeight.w500,
            color: s.contains(MaterialState.selected) ? const Color(0xFF64B5F6) : Colors.grey[600],
          ),
        ),
        iconTheme: MaterialStateProperty.resolveWith(
          (s) => IconThemeData(
            color: s.contains(MaterialState.selected) ? const Color(0xFF64B5F6) : Colors.grey[600],
            size: 22,
          ),
        ),
      ),
    );
  }
}
