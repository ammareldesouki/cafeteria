import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

class WelcomeBanner extends StatelessWidget {
  final String userName;
  const WelcomeBanner({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF4EC), Color(0xFFFFE5CC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Stack(
        children: [
          // Decorative ghost cups
          Positioned(
            right: 10,
            top: -4,
            child: Opacity(
              opacity: 0.18,
              child: Icon(Icons.coffee_rounded,
                  size: 60, color: const Color(0xFF3B1A08)),
            ),
          ),
          Positioned(
            left: 6,
            bottom: -6,
            child: Opacity(
              opacity: 0.10,
              child: Icon(Icons.local_cafe_rounded,
                  size: 44, color: const Color(0xFF3B1A08)),
            ),
          ),
          // Content
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.65),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.coffee_rounded,
                    color: Color(0xFF3B1A08), size: 24),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.welcome,
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFF3B1A08).withOpacity(0.65),
                    ),
                  ),
                  Text(
                    '$userName',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3B1A08),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppLocalizations.of(context)!.readyToOrder,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7A4D28),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
