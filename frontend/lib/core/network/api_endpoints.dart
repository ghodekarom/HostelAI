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
  static String complaintDetails(dynamic id) => '/complaints/$id';
  static String complaintEvidence(dynamic id) => '/complaints/$id/evidence';
  static String respondMissingInfo(dynamic id) => '/complaints/$id/missing-info/respond';
  static String resolutionDecision(dynamic id) => '/complaints/$id/resolution/decision';

  // Operator
  static const String operatorQueue = '/operator/queue';
  static String operatorReview(dynamic id) => '/complaints/$id/review';
  static String relatedCases(dynamic id) => '/complaints/$id/related-cases';
  static String relatedCaseDecision(dynamic id, dynamic relatedId) =>
      '/complaints/$id/related-cases/$relatedId/decision';
  static String assignComplaint(dynamic id) => '/complaints/$id/assign';
  static String requestMissingInfo(dynamic id) => '/complaints/$id/missing-info/request';
  static String proposeResolution(dynamic id) => '/complaints/$id/resolution';

  // Technician
  static const String technicianAssigned = '/technician/assigned';
  static String checklist(dynamic id) => '/complaints/$id/checklist';
  static String checklistFinding(dynamic id, dynamic itemId) =>
      '/complaints/$id/checklist/$itemId/finding';
  static String repairActions(dynamic id) => '/complaints/$id/repair-actions';

  // Admin & Reference Data
  static const String adminCategories = '/admin/categories';
  static const String adminTeams = '/admin/teams';
  static const String adminHostels = '/admin/hostels';
  static String adminBlocksByHostel(dynamic hostelId) => '/admin/hostels/$hostelId/blocks';
  static const String adminBlocks = '/admin/blocks';
  static String adminRoomsByBlock(dynamic blockId) => '/admin/blocks/$blockId/rooms';
  static const String adminRooms = '/admin/rooms';

  // Team Lead
  static const String teamLeadAtRisk = '/team-lead/at-risk';
  static String teamLeadContext(dynamic id) => '/complaints/$id/context';
  static String intervene(dynamic id) => '/complaints/$id/intervene';

  // Manager & Analytics
  static const String analyticsTrends = '/analytics/trends';
  static const String analyticsHotspots = '/analytics/hotspots';
  static const String analyticsResolutionTime = '/analytics/resolution-time';
  static const String analyticsRecurringIssues = '/analytics/recurring-issues';

  // Notifications
  static const String notifications = '/notifications';
  static String markNotificationRead(dynamic id) => '/notifications/$id/read';
}
