import 'package:flutter/material.dart';

import '../../data/po_models.dart';

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class PoStatusBadge extends StatelessWidget {
  const PoStatusBadge({super.key, required this.status});

  final PoStatus status;

  @override
  Widget build(BuildContext context) =>
      _Badge(label: status.label, color: status.color);
}

class PaymentStatusBadge extends StatelessWidget {
  const PaymentStatusBadge({super.key, required this.status});

  final PaymentStatus status;

  @override
  Widget build(BuildContext context) =>
      _Badge(label: status.label, color: status.color);
}
