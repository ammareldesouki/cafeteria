import 'package:flutter/material.dart';
import '../../core/network/dio_handler.dart';

import '../../core/constants/image_strings.dart';
import '../../core/route/route_name.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      final isLoggedIn = NetworkDioHandler().hasToken();
      
      
      if (isLoggedIn) {
        final role = NetworkDioHandler().currentRole;
        if (role == 'admin') {
          Navigator.pushNamedAndRemoveUntil(
              context, RouteNames.cafeteriaPanel, (route) => false);
        } else {
          Navigator.pushNamedAndRemoveUntil(
              context, RouteNames.layout, (route) => false);
        }
      } else {
        Navigator.pushNamedAndRemoveUntil(
            context, RouteNames.roleSelection, (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Replace with your actual logo asset
            Image.asset(
              TImages.SplashScreen,

              errorBuilder: (_, __, ___) => Column(
                children: const [
                  Icon(Icons.delivery_dining, size: 80, color: Color(0xFF3B1A08)),
                  SizedBox(height: 12),
                  Text(
                    'OnTheWay',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3B1A08),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
