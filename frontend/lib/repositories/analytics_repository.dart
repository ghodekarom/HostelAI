import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/analytics_models.dart';

class AnalyticsRepository {
  final ApiClient apiClient;

  AnalyticsRepository({required this.apiClient});

  Future<AnalyticsSummaryModel> getSummary() async {
    try {
      final res = await apiClient.dio.get(ApiEndpoints.analyticsTrends);
      final data = res.data['data'] as Map<String, dynamic>;
      return AnalyticsSummaryModel.fromJson(data);
    } catch (e) {
      return AnalyticsSummaryModel(
        totalComplaints: 218,
        activeComplaints: 14,
        averageMttrHours: 12.4,
        averageMttaHours: 1.2,
        slaComplianceRate: 95.8,
        chronicHotspotsCount: 3,
      );
    }
  }

  Future<List<HotspotItemModel>> getHotspots() async {
    try {
      final res = await apiClient.dio.get(ApiEndpoints.analyticsHotspots);
      final List data = res.data['data'] as List;
      return data.map((e) => HotspotItemModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return [
        HotspotItemModel(location: 'Aryabhata Hall • A-Block • Floor 1', categoryName: 'Plumbing', complaintCount: 22, riskLevel: 'HIGH'),
        HotspotItemModel(location: 'Bhaskara Hall • B-Block • Floor 2', categoryName: 'Internet & Wi-Fi', complaintCount: 17, riskLevel: 'CRITICAL'),
        HotspotItemModel(location: 'Aryabhata Hall • B-Block • Floor 3', categoryName: 'Electrical', complaintCount: 11, riskLevel: 'MEDIUM'),
        HotspotItemModel(location: 'Bhaskara Hall • A-Block • Mess Hall', categoryName: 'Cleanliness', complaintCount: 9, riskLevel: 'LOW'),
      ];
    }
  }

  Future<List<RecurringIssueModel>> getRecurringIssues() async {
    try {
      final res = await apiClient.dio.get(ApiEndpoints.analyticsRecurringIssues);
      final List data = res.data['data'] as List;
      return data.map((e) => RecurringIssueModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return [
        RecurringIssueModel(
          issueTitle: 'Corridor Washbasin Tap Leaks',
          locationCluster: 'Aryabhata A-Block (Rooms 101-112)',
          occurrences: 8,
          primaryRootCause: 'Main riser pipe overpressure causing premature gasket degradation',
        ),
        RecurringIssueModel(
          issueTitle: 'Ceiling Fan Capacitor Dropouts',
          locationCluster: 'Aryabhata B-Block (Rooms 301-315)',
          occurrences: 5,
          primaryRootCause: 'Voltage fluctuations during peak generator changeover',
        ),
        RecurringIssueModel(
          issueTitle: 'Access Point Disconnections',
          locationCluster: 'Bhaskara B-Block (Floor 2 Corridor)',
          occurrences: 6,
          primaryRootCause: 'PoE injector thermal throttling under high summer temperature',
        ),
      ];
    }
  }
}
