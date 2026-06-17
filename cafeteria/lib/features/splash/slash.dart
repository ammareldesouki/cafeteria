import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import '../../core/network/dio_handler.dart';
import '../../core/services/fcm_service.dart';

import '../../core/constants/image_strings.dart';
import '../../core/route/route_name.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  static const Color _brown = Color(0xFF3B1A08);

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
        final handler = NetworkDioHandler();
        final role = handler.currentRole;
        if (role == 'admin') {
          FcmService.instance.registerToken();
          Navigator.pushNamedAndRemoveUntil(
              context, RouteNames.cafeteriaPanel, (route) => false);
        } else {
          Navigator.pushNamedAndRemoveUntil(
            context,
            RouteNames.layout,
            (route) => false,
            arguments: {
              'role': role ?? 'user',
              'userName': handler.currentUserName ?? 'User',
              'userId': handler.currentUserId ?? '',
            },
          );
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFF5EDE4)],
          ),
        ),
        child: Stack(
          children: [
            // ── Logo + app name (center) ──
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Soft circular glow behind the logo, fading in.
                  ZoomIn(
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOutBack,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _brown.withValues(alpha: 0.12),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        TImages.logoRemove,
                        width: 130,
                        height: 130,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.delivery_dining_rounded,
                          size: 90,
                          color: _brown,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  FadeInUp(
                    delay: const Duration(milliseconds: 500),
                    duration: const Duration(milliseconds: 700),
                    from: 24,
                    child: const Text(
                      'OnTheWay',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: _brown,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FadeInUp(
                    delay: const Duration(milliseconds: 800),
                    duration: const Duration(milliseconds: 700),
                    from: 16,
                    child: Text(
                      'CIC Cafeteria',
                      style: TextStyle(
                        fontSize: 14,
                        letterSpacing: 2,
                        color: _brown.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Loading indicator (bottom) ──
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 56),
                child: FadeIn(
                  delay: const Duration(milliseconds: 1200),
                  child: const SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      valueColor: AlwaysStoppedAnimation(_brown),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
