import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

class PriorityBadge extends StatelessWidget {
  final String priority;

  const PriorityBadge({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (priority.toUpperCase()) {
      case AppConstants.priorityP1:
        color = AppColors.priorityCritical;
        break;
      case AppConstants.priorityP2:
        color = AppColors.priorityHigh;
        break;
      case AppConstants.priorityP3:
        color = AppColors.priorityMedium;
        break;
      case AppConstants.priorityP4:
      default:
        color = AppColors.priorityLow;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        priority.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class SeverityBadge extends StatelessWidget {
  final String severity;

  const SeverityBadge({super.key, required this.severity});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (severity.toUpperCase()) {
      case AppConstants.severityCritical:
        color = AppColors.priorityCritical;
        break;
      case AppConstants.severityHigh:
        color = AppColors.priorityHigh;
        break;
      case AppConstants.severityMedium:
        color = AppColors.priorityMedium;
        break;
      case AppConstants.severityLow:
      default:
        color = AppColors.priorityLow;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          severity.toUpperCase(),
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
