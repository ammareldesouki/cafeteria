import 'package:flutter/material.dart';
import '../../domain/entities/order_entity.dart';

/// Animated success page shown after placing an order.
/// Auto-navigates to the orders tab after the animation.
class OrderSuccessPage extends StatefulWidget {
  final OrderEntity order;

  const OrderSuccessPage({super.key, required this.order});

  @override
  State<OrderSuccessPage> createState() => _OrderSuccessPageState();
}

class _OrderSuccessPageState extends State<OrderSuccessPage>
    with TickerProviderStateMixin {
  late AnimationController _iconController;
  late AnimationController _textController;
  late AnimationController _dotsController;

  late Animation<double> _iconScale;
  late Animation<double> _iconOpacity;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();

    // Icon pop-in animation
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _iconScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.elasticOut),
    );
    _iconOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.easeIn),
    );

    // Text slide-up animation
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(_textController);
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutCubic,
    ));

    // Dots loading animation
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    // Start sequence
    _iconController.forward().then((_) {
      _textController.forward();
    });

    // Auto-navigate after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _iconController.dispose();
    _textController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── Animated icon ──
              AnimatedBuilder(
                animation: _iconController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _iconOpacity.value,
                    child: Transform.scale(
                      scale: _iconScale.value,
                      child: child,
                    ),
                  );
                },
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0E8DC),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Icon(
                    Icons.takeout_dining_outlined,
                    size: 56,
                    color: Color(0xFF3B1A08),
                  ),
                ),
              ),

              const SizedBox(height: 36),

              // ── Animated text ──
              SlideTransition(
                position: _textSlide,
                child: FadeTransition(
                  opacity: _textOpacity,
                  child: Column(
                    children: [
                      const Text(
                        'Preparing Your\nOrder',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3B1A08),
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ── Animated dots ──
                      AnimatedBuilder(
                        animation: _dotsController,
                        builder: (context, _) {
                          final dotCount =
                              (_dotsController.value * 4).floor() % 4;
                          return Text(
                            '•' * dotCount,
                            style: const TextStyle(
                              fontSize: 24,
                              color: Color(0xFF3B1A08),
                              letterSpacing: 4,
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 16),
                      const Text(
                        'Your drinks will be ready soon',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF8B7355),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
