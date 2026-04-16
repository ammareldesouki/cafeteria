import 'package:cafeteria/core/constants/image_strings.dart';
import 'package:cafeteria/core/route/route_name.dart';
import 'package:flutter/material.dart';

enum UserRole { cafeteriaStaff, collegeStaff }

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  void _onRoleSelected(BuildContext context, UserRole role) {
    if (role == UserRole.cafeteriaStaff) {
      Navigator.pushNamed(context, RouteNames.signIn);
      return;
    }

    Navigator.pushNamed(
      context,
      RouteNames.signUp,
      arguments: role,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo
                Image.asset(
                 TImages.logoRemove,
                  height: 90,
                  errorBuilder: (_, __, ___) => Column(
                    children: const [
                      Image(image:AssetImage(TImages.logoRemove),
                          color: Color(0xFF3B1A08)),
                      SizedBox(height: 8),
                      Text(
                        'OnTheWay',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3B1A08),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Role cards
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _RoleCard(
                      label: 'Cafeteria Staff',
                      image: TImages.cafeteriaLogo,
                      onTap: () =>
                          _onRoleSelected(context, UserRole.cafeteriaStaff),
                    ),
                    _RoleCard(
                      label: 'College Staff',
                      image:TImages.employeeLogo,
                      onTap: () =>
                          _onRoleSelected(context, UserRole.collegeStaff),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                const Text(
                  'Select Your Panel',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String label;
  final String image;
  final VoidCallback onTap;

  const _RoleCard({
    required this.label,
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF5EDE8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Image(image:AssetImage(image),  color: const Color(0xFF3B1A08)),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }
}
