import 'package:flutter/material.dart';
import '../../features/layout/bottom_navegation_bar.dart';

/// Global ScaffoldMessenger key so snackbars can be shown
/// above modal bottom sheets and any navigator route.
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

/// Global key for the bottom navigation bar — use to switch tabs
/// programmatically from anywhere (e.g. "Go to Cart" → tab index 2).
final GlobalKey<CBottomNavigationBarState> bottomNavKey =
    GlobalKey<CBottomNavigationBarState>();
