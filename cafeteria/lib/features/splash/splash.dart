// import 'package:flutter/material.dart';
//
// import '../../core/constants/image_strings.dart';
// import '../../core/route/route_name.dart';
//
// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});
//
//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     Future.delayed(Duration(seconds: 3), () {
//       Navigator.pushReplacementNamed(context,  RouteNames.roleSelection);
//     });
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Image(image: AssetImage(TImages.SplashScreen)),
//     );
//   }
// }


import 'package:flutter/material.dart';

import '../../core/constants/image_strings.dart';

class RunningSplashScreen extends StatefulWidget {
  const RunningSplashScreen({super.key});

  @override
  State<RunningSplashScreen> createState() => _RunningSplashScreenState();
}

class _RunningSplashScreenState extends State<RunningSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )
      ..repeat(reverse: true);

    // Creates the "running" vertical bounce
    _bounceAnimation = Tween<double>(begin: 0, end: -15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Entrance slide from the left
    _slideAnimation = Tween<double>(begin: -100, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _bounceAnimation.value),
                  child: Column(
                    children: [
                      // The Image (Man + Order)
                      Image.asset(
                        TImages.SplashScreen,
                        width: 180,
                      ),
                      const SizedBox(height: 10),
                      // The Text "OnTheWay"
                      // const Text(
                      //   "OnTheWay",
                      //   style: TextStyle(
                      //     fontSize: 28,
                      //     fontWeight: FontWeight.bold,
                      //     color: Color(0xFF3D2616), // Dark brown from your logo
                      //     fontStyle: FontStyle.italic,
                      //   ),
                      // ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
