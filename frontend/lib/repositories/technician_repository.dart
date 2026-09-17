import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/complaint_model.dart';
import '../models/checklist_model.dart';
import 'mock_data.dart';

class TechnicianRepository {
  final ApiClient apiClient;

  TechnicianRepository({required this.apiClient});

  Future<List<ComplaintModel>> getAssignedTasks({int technicianId = 1}) async {
    try {
      final response = await apiClient.dio.get(ApiEndpoints.technicianAssigned);
      final pageData = response.data['data'];
      final List content = pageData is Map && pageData['content'] is List
          ? pageData['content'] as List
          : (pageData is List ? pageData : []);
      return content.map((e) => ComplaintModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return MockData.complaints.where((c) => c.status != 'CLOSED').toList();
    }
  }

  Future<ChecklistModel> getChecklist(int complaintId) async {
    try {
      final response = await apiClient.dio.get(ApiEndpoints.checklist(complaintId));
      final data = response.data['data'] as Map<String, dynamic>;
      return ChecklistModel.fromJson(data);
    } catch (e) {
      return MockData.sampleChecklist(complaintId);
    }
  }

  Future<void> recordFinding({
    required int complaintId,
    required int itemId,
    required String findingNotes,
    String status = 'COMPLETED',
  }) async {
    try {
      await apiClient.dio.post(
        ApiEndpoints.checklistFinding(complaintId, itemId),
        data: {
          'findingNotes': findingNotes,
          'status': status,
        },
      );
    } catch (_) {}
  }

  Future<void> recordRepairAction({
    required int complaintId,
    required String actionDescription,
    String? partsReplaced,
    String? notes,
  }) async {
    try {
      await apiClient.dio.post(
        ApiEndpoints.repairActions(complaintId),
        data: {
          'actionDescription': actionDescription,
          'partsReplaced': partsReplaced,
          'notes': notes,
        },
      );
    } catch (e) {
      final c = MockData.complaints.firstWhere((x) => x.id == complaintId, orElse: () => MockData.complaints.first);
      final idx = MockData.complaints.indexOf(c);
      if (idx != -1) {
        MockData.complaints[idx] = ComplaintModel(
          id: c.id,
          caseNumber: c.caseNumber,
          description: c.description,
          status: 'ACTION_TAKEN',
          createdAt: c.createdAt,
        );
      }
    }
  }
}
