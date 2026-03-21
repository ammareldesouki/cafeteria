import 'package:flutter/material.dart';

class ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius borderRadius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
    _anim = Tween<double>(begin: -2, end: 2).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius,
          gradient: LinearGradient(
            begin: Alignment(_anim.value - 1, 0),
            end: Alignment(_anim.value, 0),
            colors: const [
              Color(0xFFEDE7E0),
              Color(0xFFF7F2EE),
              Color(0xFFEDE7E0),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Welcome banner skeleton
        ShimmerBox(
          width: double.infinity,
          height: 100,
          borderRadius: BorderRadius.circular(22),
        ),
        const SizedBox(height: 20),
        // Search bar skeleton
        ShimmerBox(
          width: double.infinity,
          height: 52,
          borderRadius: BorderRadius.circular(16),
        ),
        const SizedBox(height: 28),
        // Section title
        ShimmerBox(
          width: 140,
          height: 18,
          borderRadius: BorderRadius.circular(8),
        ),
        const SizedBox(height: 16),
        // Category cards
        for (int i = 0; i < 3; i++) ...[
          ShimmerBox(
            width: double.infinity,
            height: 112,
            borderRadius: BorderRadius.circular(22),
          ),
          const SizedBox(height: 14),
        ],
      ],
    );
  }
}
