import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/complaint_model.dart';
import '../models/team_lead_models.dart';
import 'mock_data.dart';

class TeamLeadRepository {
  final ApiClient apiClient;

  TeamLeadRepository({required this.apiClient});

  Future<List<ComplaintModel>> getAtRiskComplaints() async {
    try {
      final res = await apiClient.dio.get(ApiEndpoints.teamLeadAtRisk);
      final pageData = res.data['data'];
      final List content = pageData is Map && pageData['content'] is List
          ? pageData['content'] as List
          : (pageData is List ? pageData : []);
      return content.map((e) => ComplaintModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return MockData.complaints.where((c) => c.isAtRisk || c.status == 'AT_RISK').toList();
    }
  }

  Future<TeamLeadContextModel> getContext(int complaintId) async {
    try {
      final res = await apiClient.dio.get(ApiEndpoints.teamLeadContext(complaintId));
      final data = res.data['data'] as Map<String, dynamic>;
      return TeamLeadContextModel.fromJson(data);
    } catch (e) {
      final c = MockData.complaints.firstWhere((x) => x.id == complaintId, orElse: () => MockData.complaints.first);
      return TeamLeadContextModel(
        complaint: c,
        slaStatus: 'SLA Breached by 3.5 hours',
        riskFactors: [
          'High student count impacted (Floor 2 corridor)',
          'Repeated inquiry submitted by Room 201 occupants',
          'Inactivity > 24 hours without technician diagnostic notes',
        ],
        affectedStudentsCount: 14,
        aiEscalationDraft:
            'AI Assessment: Wi-Fi access point failure in Block B has breached P1 8-hour target. Immediate secondary network engineer dispatch or switch hardware replacement recommended.',
      );
    }
  }

  Future<void> intervene(int complaintId, InterventionRequest request) async {
    try {
      await apiClient.dio.post(
        ApiEndpoints.intervene(complaintId),
        data: request.toJson(),
      );
    } catch (e) {
      // Mock update
      final c = MockData.complaints.firstWhere((x) => x.id == complaintId, orElse: () => MockData.complaints.first);
      final idx = MockData.complaints.indexOf(c);
      if (idx != -1) {
        MockData.complaints[idx] = ComplaintModel(
          id: c.id,
          caseNumber: c.caseNumber,
          description: c.description,
          status: 'ACTIVE',
          severity: c.severity,
          priority: request.priority ?? c.priority,
          assignedTechnicianId: request.technicianId ?? c.assignedTechnicianId,
          isAtRisk: false,
          createdAt: c.createdAt,
        );
      }
    }
  }
}
