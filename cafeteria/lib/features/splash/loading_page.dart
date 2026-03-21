import 'package:flutter/material.dart';

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
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.pushReplacementNamed(context, RouteNames.roleSelection);
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
              'assets/icons/logo.png',
              width: 140,
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
