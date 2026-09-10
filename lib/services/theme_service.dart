import 'package:flutter/material.dart';

class ThemeService {
  static final ValueNotifier<ThemeMode> themeModeNotifier =
      ValueNotifier<ThemeMode>(ThemeMode.light);

  static bool get isDarkMode => themeModeNotifier.value == ThemeMode.dark;

  static void setDarkMode(bool enableDark) {
    themeModeNotifier.value = enableDark ? ThemeMode.dark : ThemeMode.light;
  }

  static void toggleTheme() {
    setDarkMode(!isDarkMode);
  }

  // ─── FITUR TEKS LEBIH BESAR ─────────────────────────────────────────────────
  // textScaleNotifier menyimpan skala font yang digunakan di seluruh aplikasi.
  // Nilai normal = 1.0, nilai besar = 1.2 (20% lebih besar dari default).
  static final ValueNotifier<double> textScaleNotifier =
      ValueNotifier<double>(1.0);

  static bool get isLargeText => textScaleNotifier.value > 1.0;

  static void setLargeText(bool enable) {
    textScaleNotifier.value = enable ? 1.2 : 1.0;
  }

  // Tema Terang (Light Mode)
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2563EB),
        primary: const Color(0xFF24487A),
        surface: Colors.white,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF1E293B),
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE2E8F0),
        thickness: 1,
      ),
    );
  }

  // Tema Gelap (Dark Mode)
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF3B82F6),
        primary: const Color(0xFF60A5FA),
        surface: const Color(0xFF1E293B),
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF0F172A),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E293B),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1E293B),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF334155)),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF334155),
        thickness: 1,
      ),
    );
  }
}
