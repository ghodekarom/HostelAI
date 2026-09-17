/// Centralized REST API endpoints for HFCMS Backend
class ApiEndpoints {
  // Auth
  static const String signup = '/auth/signup';
  static const String verify = '/auth/verify';
  static const String resendCode = '/auth/resend-code';
  static const String signin = '/auth/signin';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String passwordResetRequest = '/auth/password-reset/request';
  static const String passwordResetConfirm = '/auth/password-reset/confirm';

  // Complaints
  static const String complaints = '/complaints';
  static const String myComplaints = '/complaints/mine';
  static String complaintDetails(String id) => '/complaints/$id';
  static String complaintEvidence(String id) => '/complaints/$id/evidence';
  static String respondMissingInfo(String id) => '/complaints/$id/missing-info/respond';
  static String resolutionDecision(String id) => '/complaints/$id/resolution/decision';

  // Operator
  static const String operatorQueue = '/operator/queue';
  static String operatorReview(String id) => '/complaints/$id/review';
  static String relatedCases(String id) => '/complaints/$id/related-cases';
  static String relatedCaseDecision(String id, String relatedId) =>
      '/complaints/$id/related-cases/$relatedId/decision';
  static String assignComplaint(String id) => '/complaints/$id/assign';
  static String requestMissingInfo(String id) => '/complaints/$id/missing-info/request';
  static String proposeResolution(String id) => '/complaints/$id/resolution';

  // Technician
  static const String technicianAssigned = '/technician/assigned';
  static String checklist(String id) => '/complaints/$id/checklist';
  static String checklistFinding(String id, String itemId) =>
      '/complaints/$id/checklist/$itemId/finding';
  static String repairActions(String id) => '/complaints/$id/repair-actions';

  // Team Lead
  static const String teamLeadAtRisk = '/team-lead/at-risk';
  static String teamLeadContext(String id) => '/complaints/$id/context';
  static String intervene(String id) => '/complaints/$id/intervene';

  // Manager & Analytics
  static const String analyticsTrends = '/analytics/trends';
  static const String analyticsHotspots = '/analytics/hotspots';
  static const String analyticsResolutionTime = '/analytics/resolution-time';
  static const String analyticsRecurringIssues = '/analytics/recurring-issues';

  // Notifications
  static const String notifications = '/notifications';
  static String markNotificationRead(String id) => '/notifications/$id/read';
}
