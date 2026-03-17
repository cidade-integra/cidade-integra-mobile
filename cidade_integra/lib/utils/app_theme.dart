import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Cores da marca — extraídas de tailwind.config.js
  static const verde = Color(0xFF5BC561);
  static const verdeEscuro = Color(0xFF3B8C4B);
  static const azul = Color(0xFF112B3C);
  static const vermelho = Color(0xFFA92C2C);
  static const cinza = Color(0xFFCED8E2);

  // Neutras
  static const branco = Color(0xFFFFFFFF);
  static const preto = Color(0xFF0A0A0A);
  static const fundo = Color(0xFFF8F9FA);
  static const bordas = Color(0xFFE5E5E5);
  static const textoSecundario = Color(0xFF737373);
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: AppColors.verde,
        onPrimary: AppColors.branco,
        primaryContainer: AppColors.verde.withValues(alpha: 0.15),
        secondary: AppColors.azul,
        onSecondary: AppColors.branco,
        error: AppColors.vermelho,
        onError: AppColors.branco,
        surface: AppColors.branco,
        onSurface: AppColors.preto,
        outline: AppColors.bordas,
      ),
      scaffoldBackgroundColor: AppColors.fundo,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.branco,
        foregroundColor: AppColors.azul,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.azul,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.verde,
          foregroundColor: AppColors.branco,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.verde,
          side: const BorderSide(color: AppColors.verde),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.verde,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.branco,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.branco,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.bordas),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.bordas),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.verde, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.vermelho),
        ),
        hintStyle: const TextStyle(color: AppColors.textoSecundario),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.cinza.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.bordas,
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
