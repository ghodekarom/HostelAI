import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/complaint_model.dart';
import 'mock_data.dart';

class OperatorRepository {
  final ApiClient apiClient;

  OperatorRepository({required this.apiClient});

  Future<List<ComplaintModel>> getOperatorQueue({List<String>? statuses}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (statuses != null && statuses.isNotEmpty) {
        queryParams['status'] = statuses.join(',');
      }
      final response = await apiClient.dio.get(
        ApiEndpoints.operatorQueue,
        queryParameters: queryParams,
      );
      final pageData = response.data['data'];
      final List content = pageData is Map && pageData['content'] is List
          ? pageData['content'] as List
          : (pageData is List ? pageData : []);
      return content.map((e) => ComplaintModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      if (statuses == null || statuses.isEmpty) return MockData.complaints;
      return MockData.complaints.where((c) => statuses.contains(c.status)).toList();
    }
  }

  Future<ComplaintModel> reviewComplaint({
    required int id,
    required String severity,
    required String priority,
    required int categoryId,
    int? teamId,
    String? operatorNotes,
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiEndpoints.operatorReview(id),
        data: {
          'severity': severity,
          'priority': priority,
          'categoryId': categoryId,
          'teamId': teamId,
          'operatorNotes': operatorNotes,
        },
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return ComplaintModel.fromJson(data);
    } catch (e) {
      final c = MockData.complaints.firstWhere((x) => x.id == id, orElse: () => MockData.complaints.first);
      final updated = ComplaintModel(
        id: c.id,
        caseNumber: c.caseNumber,
        description: c.description,
        status: 'OPERATOR_REVIEW',
        severity: severity,
        priority: priority,
        categoryId: categoryId,
        assignedTeamId: teamId,
        createdAt: c.createdAt,
      );
      final idx = MockData.complaints.indexOf(c);
      if (idx != -1) MockData.complaints[idx] = updated;
      return updated;
    }
  }

  Future<List<ComplaintModel>> getRelatedCases(int id) async {
    try {
      final response = await apiClient.dio.get(ApiEndpoints.relatedCases(id));
      final List data = response.data['data'] as List;
      return data.map((e) => ComplaintModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return MockData.complaints.where((c) => c.id != id).toList();
    }
  }

  Future<void> decideRelatedCase({
    required int id,
    required int relatedId,
    required String decision, // LINKED, DUPLICATE, SEPARATE, IGNORED
  }) async {
    try {
      await apiClient.dio.post(
        ApiEndpoints.relatedCaseDecision(id, relatedId),
        data: {'decision': decision},
      );
    } catch (_) {}
  }

  Future<ComplaintModel> assignComplaint({
    required int id,
    required int teamId,
    required int technicianId,
    String? assignmentReason,
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiEndpoints.assignComplaint(id),
        data: {
          'teamId': teamId,
          'technicianId': technicianId,
          'assignmentReason': assignmentReason,
        },
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return ComplaintModel.fromJson(data);
    } catch (e) {
      final c = MockData.complaints.firstWhere((x) => x.id == id, orElse: () => MockData.complaints.first);
      final updated = ComplaintModel(
        id: c.id,
        caseNumber: c.caseNumber,
        description: c.description,
        status: 'ASSIGNED',
        severity: c.severity,
        priority: c.priority,
        assignedTeamId: teamId,
        assignedTechnicianId: technicianId,
        createdAt: c.createdAt,
      );
      final idx = MockData.complaints.indexOf(c);
      if (idx != -1) MockData.complaints[idx] = updated;
      return updated;
    }
  }

  Future<void> requestMissingInfo({
    required int id,
    required String questions,
  }) async {
    try {
      await apiClient.dio.post(
        ApiEndpoints.requestMissingInfo(id),
        data: {'questions': questions},
      );
    } catch (e) {
      final c = MockData.complaints.firstWhere((x) => x.id == id, orElse: () => MockData.complaints.first);
      final idx = MockData.complaints.indexOf(c);
      if (idx != -1) {
        MockData.complaints[idx] = ComplaintModel(
          id: c.id,
          caseNumber: c.caseNumber,
          description: c.description,
          status: 'WAITING_FOR_INFORMATION',
          createdAt: c.createdAt,
        );
      }
    }
  }

  Future<void> proposeResolution({
    required int id,
    required String problemDescription,
    required String rootCause,
    required String actionTaken,
    String? resultSummary,
  }) async {
    try {
      await apiClient.dio.post(
        ApiEndpoints.proposeResolution(id),
        data: {
          'problemDescription': problemDescription,
          'rootCause': rootCause,
          'actionTaken': actionTaken,
          'resultSummary': resultSummary,
        },
      );
    } catch (e) {
      final c = MockData.complaints.firstWhere((x) => x.id == id, orElse: () => MockData.complaints.first);
      final idx = MockData.complaints.indexOf(c);
      if (idx != -1) {
        MockData.complaints[idx] = ComplaintModel(
          id: c.id,
          caseNumber: c.caseNumber,
          description: c.description,
          status: 'RESOLUTION_PROPOSED',
          createdAt: c.createdAt,
        );
      }
    }
  }
}
