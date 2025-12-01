import 'package:flutter/material.dart';

/// رنگ‌های پایه (استخراج‌شده از سبک UI ارسالی)
class AppColors {
  // پس‌زمینه‌ها
  static const Color background = Color(0xFFFFFFFF); // سفید
  static const Color surface = Color(0xFFF5F7FA); // خاکستری خیلی روشن برای کارت‌ها

  // رنگ‌های اصلی
  static const Color primary = Color(0xFF1E2A38); // آبی تیره/سرمه‌ای مدرن برای نوار پایین و دکمه‌های اصلی
  static const Color accent = Color(0xFF4C9AFF); // آبی روشن ملایم برای هایلایت و دکمه‌های فرعی
  static const Color gold = Color(0xFFD4AF37); // طلایی مات لوکس برای برندینگ و CTA خاص

  // تایپوگرافی
  static const Color textPrimary = Color(0xFF2C2C2C); // مشکی نرم برای تیترها
  static const Color textSecondary = Color(0xFFA0A4A8); // خاکستری متوسط برای توضیحات
}

/// اندازه‌ها و شعاع‌ها برای یکدستی کامپوننت‌ها
class AppDims {
  static const double radius = 12.0;
  static const double padding = 24.0;
  static const double buttonHeight = 48.0;
}

/// ThemeData یکپارچه برای اپ
ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    fontFamily: 'Roboto', // اگر بعداً فونت فارسی اضافه کردیم، این را تغییر می‌دهیم
    scaffoldBackgroundColor: AppColors.background,

    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.accent,
      onSecondary: Colors.white,
      background: AppColors.background,
      onBackground: AppColors.textPrimary,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      error: const Color(0xFFB00020),
      onError: Colors.white,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),

    textTheme: const TextTheme(
      headlineSmall: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      titleMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 16,
        color: AppColors.textSecondary,
      ),
      labelLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        minimumSize: Size(double.infinity, AppDims.buttonHeight),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDims.radius),
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: Size(double.infinity, AppDims.buttonHeight),
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        foregroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDims.radius),
        ),
      ),
    ),

    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDims.radius),
      ),
    ),


    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDims.radius),
        borderSide: BorderSide.none,
      ),
      hintStyle: const TextStyle(color: AppColors.textSecondary),
    ),
  );
}

