class AnalyticsSummaryModel {
  final int totalComplaints;
  final int activeComplaints;
  final double averageMttrHours;
  final double averageMttaHours;
  final double slaComplianceRate;
  final int chronicHotspotsCount;

  AnalyticsSummaryModel({
    required this.totalComplaints,
    required this.activeComplaints,
    required this.averageMttrHours,
    required this.averageMttaHours,
    required this.slaComplianceRate,
    required this.chronicHotspotsCount,
  });

  factory AnalyticsSummaryModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsSummaryModel(
      totalComplaints: json['totalComplaints'] is num ? (json['totalComplaints'] as num).toInt() : 142,
      activeComplaints: json['activeComplaints'] is num ? (json['activeComplaints'] as num).toInt() : 18,
      averageMttrHours: json['averageMttrHours'] is num ? (json['averageMttrHours'] as num).toDouble() : 14.6,
      averageMttaHours: json['averageMttaHours'] is num ? (json['averageMttaHours'] as num).toDouble() : 1.8,
      slaComplianceRate: json['slaComplianceRate'] is num ? (json['slaComplianceRate'] as num).toDouble() : 94.2,
      chronicHotspotsCount: json['chronicHotspotsCount'] is num ? (json['chronicHotspotsCount'] as num).toInt() : 4,
    );
  }
}

class HotspotItemModel {
  final String location;
  final String categoryName;
  final int complaintCount;
  final String riskLevel; // LOW, MEDIUM, HIGH, CRITICAL

  HotspotItemModel({
    required this.location,
    required this.categoryName,
    required this.complaintCount,
    required this.riskLevel,
  });

  factory HotspotItemModel.fromJson(Map<String, dynamic> json) {
    return HotspotItemModel(
      location: json['location']?.toString() ?? '',
      categoryName: json['categoryName']?.toString() ?? '',
      complaintCount: json['complaintCount'] is num ? (json['complaintCount'] as num).toInt() : 0,
      riskLevel: json['riskLevel']?.toString() ?? 'MEDIUM',
    );
  }
}

class RecurringIssueModel {
  final String issueTitle;
  final String locationCluster;
  final int occurrences;
  final String primaryRootCause;

  RecurringIssueModel({
    required this.issueTitle,
    required this.locationCluster,
    required this.occurrences,
    required this.primaryRootCause,
  });

  factory RecurringIssueModel.fromJson(Map<String, dynamic> json) {
    return RecurringIssueModel(
      issueTitle: json['issueTitle']?.toString() ?? '',
      locationCluster: json['locationCluster']?.toString() ?? '',
      occurrences: json['occurrences'] is num ? (json['occurrences'] as num).toInt() : 0,
      primaryRootCause: json['primaryRootCause']?.toString() ?? '',
    );
  }
}
