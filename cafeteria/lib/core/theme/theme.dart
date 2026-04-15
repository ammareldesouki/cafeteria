import 'package:cafeteria/core/theme/widget_themes/elevated_button_theme.dart';
import 'package:cafeteria/core/theme/widget_themes/text_field_theme.dart';
import 'package:cafeteria/core/theme/widget_themes/text_theme.dart';
import 'package:flutter/material.dart';

import '../constants/colors.dart';

class AppTheme {
  // ── Brand colours ────────────────────────────────────────────────────────

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: TColors.background,

      // ── AppBar ────────────────────────────────────────────────────────
      appBarTheme: const AppBarTheme(
        backgroundColor: TColors.background,
        foregroundColor: TColors.primary,
        elevation: 0,
        centerTitle: false,
      ),

      // ── ElevatedButton ────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: TColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── OutlinedButton ────────────────────────────────────────────────/ ── InputDecoration ───────────────────────────────────────────────
      inputDecorationTheme: TTextFormFieldTheme.lightInputDecorationTheme,

      /// ── Text ──────────────────────────────────────────────────────────
      textTheme: TTextTheme.lightTextTheme,
    );
  }


  static ThemeData get dark {
    const Color darkBackground = Color(0xFF121212);
    const Color darkSurface = Color(0xFF1E1E1E);
    const Color darkCard = Color(0xFF2A2A2A);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,


      // ── AppBar ─────────────────────────────────────────
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),

      // ── ElevatedButton ────────────────────────────────levatedButtonTheme: TElevatedButtonTheme.darkElevatedButtonTheme,

      /// ── InputDecoration ───────────────────────────────nputDecorationTheme: TTextFormFieldTheme.darkInputDecorationTheme,

      /// ── Text ──────────────────────────────────────────extTheme: TTextTheme.darkTextTheme,

      // ── Card / Surface ────────────────────────────────
      // cardColor: darkCard,
      // dividerColor: Colors.white12,
    );
  }

}
