import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool compact;

  const StatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    IconData icon;

    switch (status.toUpperCase()) {
      case AppConstants.statusReported:
        bg = const Color(0xFFEFF6FF); // Blue 50
        fg = const Color(0xFF1D4ED8); // Blue 700
        icon = Icons.flag_outlined;
        break;
      case AppConstants.statusUnderstood:
      case AppConstants.statusRelatedCasesChecked:
        bg = const Color(0xFFF5F3FF); // Purple 50
        fg = const Color(0xFF6D28D9); // Purple 700
        icon = Icons.auto_awesome;
        break;
      case AppConstants.statusOperatorReview:
        bg = const Color(0xFFEEF2FF); // Indigo 50
        fg = const Color(0xFF4338CA); // Indigo 700
        icon = Icons.rate_review_outlined;
        break;
      case AppConstants.statusAssigned:
        bg = const Color(0xFFFEF3C7); // Amber 100
        fg = const Color(0xFFB45309); // Amber 700
        icon = Icons.person_add_alt_1_outlined;
        break;
      case AppConstants.statusWaitingForInformation:
        bg = const Color(0xFFFFEDD5); // Orange 100
        fg = const Color(0xFFC2410C); // Orange 700
        icon = Icons.help_outline;
        break;
      case AppConstants.statusActive:
        bg = const Color(0xFFFEF9C3); // Yellow 100
        fg = const Color(0xFFA16207); // Yellow 700
        icon = Icons.engineering_outlined;
        break;
      case AppConstants.statusInvestigated:
        bg = const Color(0xFFE0F2FE); // Sky 100
        fg = const Color(0xFF0369A1); // Sky 700
        icon = Icons.fact_check_outlined;
        break;
      case AppConstants.statusActionTaken:
        bg = const Color(0xFFCCFBF1); // Teal 100
        fg = const Color(0xFF0F766E); // Teal 700
        icon = Icons.build_circle_outlined;
        break;
      case AppConstants.statusAtRisk:
        bg = const Color(0xFFFEE2E2); // Red 100
        fg = const Color(0xFFB91C1C); // Red 700
        icon = Icons.warning_amber_rounded;
        break;
      case AppConstants.statusResolutionProposed:
        bg = const Color(0xFFF0FDFA); // Mint 50
        fg = const Color(0xFF0D9488); // Teal 600
        icon = Icons.assignment_turned_in_outlined;
        break;
      case AppConstants.statusConfirmed:
      case AppConstants.statusClosed:
        bg = const Color(0xFFECFDF5); // Emerald 50
        fg = const Color(0xFF047857); // Emerald 700
        icon = Icons.check_circle_outline;
        break;
      case AppConstants.statusReopened:
        bg = const Color(0xFFFFF1F2); // Rose 50
        fg = const Color(0xFFBE123C); // Rose 700
        icon = Icons.replay;
        break;
      default:
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF475569);
        icon = Icons.info_outline;
    }

    final formattedLabel = status.replaceAll('_', ' ');

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(compact ? 8 : 12),
        border: Border.all(color: fg.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 12 : 14, color: fg),
          const SizedBox(width: 4),
          Text(
            formattedLabel,
            style: TextStyle(
              color: fg,
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
