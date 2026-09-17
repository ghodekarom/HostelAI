import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/complaint_model.dart';
import '../models/complaint_detail_model.dart';
import 'mock_data.dart';

class ComplaintRepository {
  final ApiClient apiClient;

  ComplaintRepository({required this.apiClient});

  Future<ComplaintModel> createComplaint({
    required int hostelId,
    required int blockId,
    required int roomId,
    required int categoryId,
    String? subcategory,
    required String description,
    String severity = 'MEDIUM',
    String priority = 'P3',
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiEndpoints.complaints,
        data: {
          'hostelId': hostelId,
          'blockId': blockId,
          'roomId': roomId,
          'categoryId': categoryId,
          'subcategory': subcategory,
          'description': description,
          'severity': severity,
          'priority': priority,
        },
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return ComplaintModel.fromJson(data);
    } catch (e) {
      // Fallback for offline demo
      final newComplaint = ComplaintModel(
        id: DateTime.now().millisecondsSinceEpoch % 100000,
        caseNumber: 'HFCMS-${DateTime.now().year}-${DateTime.now().millisecondsSinceEpoch.toRadixString(16).toUpperCase().substring(0, 6)}',
        hostelId: hostelId,
        hostelName: MockData.hostels.firstWhere((h) => h.id == hostelId, orElse: () => MockData.hostels.first).name,
        blockId: blockId,
        blockName: MockData.blocks.firstWhere((b) => b.id == blockId, orElse: () => MockData.blocks.first).name,
        roomId: roomId,
        roomNumber: MockData.rooms.firstWhere((r) => r.id == roomId, orElse: () => MockData.rooms.first).roomNumber,
        categoryId: categoryId,
        categoryName: MockData.categories.firstWhere((c) => c.id == categoryId, orElse: () => MockData.categories.first).name,
        subcategory: subcategory,
        description: description,
        status: 'REPORTED',
        severity: severity,
        priority: priority,
        createdAt: DateTime.now(),
      );
      MockData.complaints.insert(0, newComplaint);
      return newComplaint;
    }
  }

  Future<List<ComplaintModel>> getMyComplaints() async {
    try {
      final response = await apiClient.dio.get(ApiEndpoints.myComplaints);
      final pageData = response.data['data'];
      final List content = pageData is Map && pageData['content'] is List
          ? pageData['content'] as List
          : (pageData is List ? pageData : []);
      return content.map((e) => ComplaintModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return MockData.complaints;
    }
  }

  Future<ComplaintDetailModel> getComplaintDetails(int id) async {
    try {
      final response = await apiClient.dio.get(ApiEndpoints.complaintDetails(id));
      final data = response.data['data'] as Map<String, dynamic>;
      return ComplaintDetailModel.fromJson(data);
    } catch (e) {
      return MockData.sampleDetail(id);
    }
  }

  Future<void> respondMissingInfo(int id, String responseText) async {
    try {
      await apiClient.dio.post(
        ApiEndpoints.respondMissingInfo(id),
        data: {'response': responseText},
      );
    } catch (e) {
      // Mock update
      final c = MockData.complaints.firstWhere((x) => x.id == id, orElse: () => MockData.complaints.first);
      final idx = MockData.complaints.indexOf(c);
      if (idx != -1) {
        MockData.complaints[idx] = ComplaintModel(
          id: c.id,
          caseNumber: c.caseNumber,
          description: c.description,
          status: 'ACTIVE',
          hostelName: c.hostelName,
          blockName: c.blockName,
          roomNumber: c.roomNumber,
          categoryName: c.categoryName,
          severity: c.severity,
          priority: c.priority,
          createdAt: c.createdAt,
        );
      }
    }
  }

  Future<void> decideResolution(int id, String decision, String? feedback) async {
    try {
      await apiClient.dio.post(
        ApiEndpoints.resolutionDecision(id),
        data: {
          'decision': decision, // CONFIRMED or REJECTED
          'feedback': feedback,
        },
      );
    } catch (e) {
      // Mock update
      final c = MockData.complaints.firstWhere((x) => x.id == id, orElse: () => MockData.complaints.first);
      final idx = MockData.complaints.indexOf(c);
      if (idx != -1) {
        MockData.complaints[idx] = ComplaintModel(
          id: c.id,
          caseNumber: c.caseNumber,
          description: c.description,
          status: decision == 'CONFIRMED' ? 'CLOSED' : 'REOPENED',
          hostelName: c.hostelName,
          blockName: c.blockName,
          roomNumber: c.roomNumber,
          categoryName: c.categoryName,
          severity: c.severity,
          priority: c.priority,
          createdAt: c.createdAt,
        );
      }
    }
  }
}
