import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (status.toUpperCase()) {
      case AppConstants.statusReported:
        bg = Colors.blue.shade50;
        fg = Colors.blue.shade800;
        break;
      case AppConstants.statusUnderstood:
      case AppConstants.statusRelatedCasesChecked:
        bg = Colors.purple.shade50;
        fg = Colors.purple.shade800;
        break;
      case AppConstants.statusOperatorReview:
        bg = Colors.indigo.shade50;
        fg = Colors.indigo.shade800;
        break;
      case AppConstants.statusAssigned:
      case AppConstants.statusActive:
        bg = Colors.amber.shade50;
        fg = Colors.amber.shade900;
        break;
      case AppConstants.statusWaitingForInformation:
        bg = Colors.orange.shade50;
        fg = Colors.orange.shade800;
        break;
      case AppConstants.statusAtRisk:
        bg = Colors.red.shade50;
        fg = Colors.red.shade800;
        break;
      case AppConstants.statusResolutionProposed:
        bg = Colors.teal.shade50;
        fg = Colors.teal.shade800;
        break;
      case AppConstants.statusConfirmed:
      case AppConstants.statusClosed:
        bg = Colors.green.shade50;
        fg = Colors.green.shade800;
        break;
      case AppConstants.statusReopened:
        bg = Colors.deepOrange.shade50;
        fg = Colors.deepOrange.shade800;
        break;
      default:
        bg = Colors.grey.shade100;
        fg = Colors.grey.shade800;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fg.withOpacity(0.3)),
      ),
      child: Text(
        status.replaceAll('_', ' '),
        style: TextStyle(
          color: fg,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
