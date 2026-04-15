import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';

/// Visual order status tracker: Received → Preparing → Delivered
class OrderStatusTracker extends StatelessWidget {
  final String status;
  const OrderStatusTracker({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (status == 'cancelled') {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cancel_rounded,
              color: Color(0xFFE57373),
              size: 18,
            ),
            const SizedBox(width: 6)Text(
              l10n.orderCancelled,
              style: const TextStyle(
                color: Color(0xFFE57373),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    // Steps: pending/processing/completed/delivered
    final int currentStep = switch (status) {
      'pending' => 0,
      'processing' => 1,
      'completed' => 2,
      'delivered' => 3,
      _ => 0,
    };

    return Row(
      children: [
        _StepCircle(
          label: l10n.orderConfirmed,
          icon: Icons.schedule_rounded,
          isActive: currentStep >= 0,
          isComplete: currentStep > 0,
        ),
        _StepLine(isActive: currentStep > 0),
        _StepCircle(
          label: l10n.orderPreparing,
          icon: Icons.local_fire_department_rounded,
          isActive: currentStep >= 1,
          isComplete: currentStep > 1,
        ),
        _StepLine(isActive: currentStep > 1),
        _StepCircle(
          label: l10n.orderDelivered,
          icon: Icons.check_circle_rounded,
          isActive: currentStep >= 2,
          isComplete: currentStep > 2,
        ),
      ],
    );
  }
}

class _StepCircle extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final bool isComplete;

  const _StepCircle({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.isComplete,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? _activeColor : const Color(0xFFD9C7B8);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? color : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Icon(
            icon,
            size: 16,
            color: isActive ? Colors.white : color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            color: isActive ? const Color(0xFF3B1A08) : const Color(0xFF8B7355),
          ),
        ),
      ],
    );
  }

  Color get _activeColor {
    if (isComplete) return const Color(0xFF4CAF50);
    return const Color(0xFFC07722);
  }
}

class _StepLine extends StatelessWidget {
  final bool isActive;
  const _StepLine({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 3,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF4CAF50) : const Color(0xFFD9C7B8),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}