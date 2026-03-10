import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppPalette {
  const AppPalette._();

  static const Color darkAccent = Color(0xFF5F7CFF);
  static const Color lightAccent = Color(0xFF2B4FE0);
  static const Color success = Color(0xFF25996B);
  static const Color danger = Color(0xFFE5596F);
  static const Color darkText = Color(0xFFE6EEFF);
  static const Color lightText = Color(0xFF1F2742);
}

class AppTheme {
  const AppTheme._();

  static const Gradient darkGradient = RadialGradient(
    center: Alignment(-0.3, -0.6),
    radius: 1.25,
    colors: [Color(0xFF141624), Color(0xFF07070C)],
  );

  static const Gradient lightGradient = RadialGradient(
    center: Alignment(-0.25, -0.45),
    radius: 1.25,
    colors: [Color(0xFFF0F5FF), Color(0xFFE6ECFC)],
  );

  static ThemeData get darkTheme {
    final ThemeData base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: Colors.transparent,
      colorScheme: base.colorScheme.copyWith(
        primary: AppPalette.darkAccent,
        secondary: const Color(0xFF8A70F0),
        surface: const Color(0xD91A1C28),
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        headlineLarge: _heading(32, FontWeight.w800, Colors.white),
        headlineMedium: _heading(28, FontWeight.w700, Colors.white),
        titleLarge: _heading(24, FontWeight.w700, Colors.white),
        bodyLarge: _body(16, FontWeight.w500, AppPalette.darkText),
        bodyMedium: _body(14, FontWeight.w400, const Color(0xFFD6DDF4)),
        labelLarge: _body(12, FontWeight.w600, const Color(0xFF9DA6C0)),
      ),
      inputDecorationTheme: _inputDecoration(
        const Color(0xB31A1C28),
        const Color(0x33FFFFFF),
      ),
    );
  }

  static ThemeData get lightTheme {
    final ThemeData base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: Colors.transparent,
      colorScheme: base.colorScheme.copyWith(
        primary: AppPalette.lightAccent,
        secondary: const Color(0xFF6A4FE0),
        surface: const Color(0xE6FFFFFF),
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        headlineLarge: _heading(32, FontWeight.w800, const Color(0xFF10162C)),
        headlineMedium: _heading(28, FontWeight.w700, const Color(0xFF10162C)),
        titleLarge: _heading(24, FontWeight.w700, const Color(0xFF10162C)),
        bodyLarge: _body(16, FontWeight.w500, AppPalette.lightText),
        bodyMedium: _body(14, FontWeight.w400, const Color(0xFF2D3655)),
        labelLarge: _body(12, FontWeight.w600, const Color(0xFF4A5675)),
      ),
      inputDecorationTheme: _inputDecoration(
        const Color(0xEEFFFFFF),
        const Color(0x33001428),
      ),
    );
  }

  static TextStyle _heading(double size, FontWeight weight, Color color) {
    return GoogleFonts.inter(fontSize: size, fontWeight: weight, color: color);
  }

  static TextStyle _body(double size, FontWeight weight, Color color) {
    return GoogleFonts.inter(fontSize: size, fontWeight: weight, color: color);
  }

  static InputDecorationTheme _inputDecoration(Color fill, Color borderColor) {
    return InputDecorationTheme(
      filled: true,
      fillColor: fill,
      hintStyle: const TextStyle(color: Color(0xFF8C94AF)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(36),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(36),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(36),
        borderSide: const BorderSide(color: Color(0xFF5F7CFF), width: 1.2),
      ),
    );
  }
}
