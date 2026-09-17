import 'package:flutter/material.dart';

class AiBadge extends StatelessWidget {
  final String label;
  final bool isConfirmed;

  const AiBadge({
    super.key,
    this.label = 'AI Suggested',
    this.isConfirmed = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isConfirmed) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.green.shade600),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 13, color: Colors.green.shade700),
            const SizedBox(width: 4),
            Text(
              'Verified',
              style: TextStyle(
                color: Colors.green.shade800,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E8FF), // Purple tint
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFC084FC)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_awesome, size: 13, color: Color(0xFF9333EA)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF6B21A8),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
