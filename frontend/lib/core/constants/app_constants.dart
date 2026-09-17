/// Application Constants & Enums for HFCMS Client
class AppConstants {
  static const String appTitle = 'HFCMS — AI Case Manager';

  // Complaint Statuses (Aligned with SRS Section 7.1)
  static const String statusReported = 'REPORTED';
  static const String statusUnderstood = 'UNDERSTOOD';
  static const String statusRelatedCasesChecked = 'RELATED_CASES_CHECKED';
  static const String statusOperatorReview = 'OPERATOR_REVIEW';
  static const String statusAssigned = 'ASSIGNED';
  static const String statusWaitingForInformation = 'WAITING_FOR_INFORMATION';
  static const String statusActive = 'ACTIVE';
  static const String statusInvestigated = 'INVESTIGATED';
  static const String statusActionTaken = 'ACTION_TAKEN';
  static const String statusAtRisk = 'AT_RISK';
  static const String statusResolutionProposed = 'RESOLUTION_PROPOSED';
  static const String statusConfirmed = 'CONFIRMED';
  static const String statusClosed = 'CLOSED';
  static const String statusReopened = 'REOPENED';

  // Severity Levels
  static const String severityLow = 'LOW';
  static const String severityMedium = 'MEDIUM';
  static const String severityHigh = 'HIGH';
  static const String severityCritical = 'CRITICAL';

  // Priorities
  static const String priorityP1 = 'P1';
  static const String priorityP2 = 'P2';
  static const String priorityP3 = 'P3';
  static const String priorityP4 = 'P4';
}
