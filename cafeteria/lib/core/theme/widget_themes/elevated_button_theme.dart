import 'package:flutter/material.dart';

import '../../constants/colors.dart';

class TElevatedButtonTheme {





  static final lightElevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      backgroundColor: Color(0xFF0D47A1),

      padding: const EdgeInsets.symmetric(vertical: 18),
      textStyle:  TextStyle(
        fontSize: 16,
        color: Colors.white,
        fontWeight: FontWeight.w700,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

  static final darkElevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      backgroundColor: TColors.primarIconColor,

      padding: const EdgeInsets.symmetric(vertical: 18),
      textStyle: TextStyle(fontSize: 20, color: Colors.white),

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
