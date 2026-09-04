import 'package:flutter/material.dart';

/// Paleta de colores pastel para Monitor de Salones.
///
/// Se centraliza aquí para que TODAS las pantallas y widgets usen los
/// mismos tonos (fondo, semáforo de estado, isla de navegación, etc.)
/// y para poder ajustar la paleta completa desde un solo lugar.
class AppColors {
  AppColors._();

  // Fondo general de la app
  static const Color background = Color(0xFFF7F5FB); // lavanda muy claro
  static const Color surface = Color(0xFFFFFFFF);

  // Marca / navegación
  static const Color primary = Color(0xFFB8C6F0); // azul pastel
  static const Color primaryDark = Color(0xFF7C93D9); // azul pastel más oscuro (botones)
  static const Color accent = Color(0xFFD9C9F0); // lila pastel

  // Semáforo de estado de los equipos (pastel, no colores saturados)
  static const Color operativo = Color(0xFF6FCF97); // verde menta pastel (Disponible)
  static const Color operativoBg = Color(0xFFE3F7EA);
  static const Color falla = Color(0xFFE8828C); // coral pastel (Dañado)
  static const Color fallaBg = Color(0xFFFBE7E9);
  static const Color enUso = Color(0xFF6FA8DC); // azul pastel (En uso)
  static const Color enUsoBg = Color(0xFFE6F1FB);
  static const Color mantenimiento = Color(0xFFE0A458); // ámbar pastel (Mantenimiento)
  static const Color mantenimientoBg = Color(0xFFFBF0E1);

  // Textos
  static const Color textPrimary = Color(0xFF3A3A4A);
  static const Color textSecondary = Color(0xFF8A8A9A);

  // Isla de navegación flotante
  static const Color islandBg = Color(0xFFFFFFFF);
  static const Color islandShadow = Color(0x1A3A3A4A);
}

/// Tema global de Material 3 construido sobre la paleta pastel.
ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primaryDark,
      secondary: AppColors.accent,
      surface: AppColors.surface,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 19,
        fontWeight: FontWeight.bold,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52), // >= 44px, táctil
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.primaryDark),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.operativo
            : AppColors.textSecondary,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.operativoBg
            : const Color(0xFFE7E7EF),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.all(16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.4)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: AppColors.primaryDark, width: 2),
      ),
    ),
  );
}
