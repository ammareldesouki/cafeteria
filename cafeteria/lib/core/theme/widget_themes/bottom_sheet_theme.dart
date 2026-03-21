import 'package:flutter/material.dart';

import '../../constants/colors.dart';

class BottomNavTheme {
  static BottomNavigationBarThemeData dark = BottomNavigationBarThemeData(
    backgroundColor: TColors.dark,
    selectedItemColor: Color(0xff85A9C9),
    unselectedItemColor: Colors.white,
    selectedIconTheme: IconThemeData(size: 28),
    unselectedIconTheme: IconThemeData(size: 22),
    showUnselectedLabels: false,
    type: BottomNavigationBarType.fixed,
    elevation: 5,
  );
}
