import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/complaint_model.dart';
import '../models/complaint_detail_model.dart';
import 'api_providers.dart';

class MyComplaintsNotifier extends AsyncNotifier<List<ComplaintModel>> {
  @override
  Future<List<ComplaintModel>> build() async {
    final repo = ref.watch(complaintRepositoryProvider);
    return repo.getMyComplaints();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(complaintRepositoryProvider);
      return repo.getMyComplaints();
    });
  }

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
    final repo = ref.read(complaintRepositoryProvider);
    final created = await repo.createComplaint(
      hostelId: hostelId,
      blockId: blockId,
      roomId: roomId,
      categoryId: categoryId,
      subcategory: subcategory,
      description: description,
      severity: severity,
      priority: priority,
    );
    await refresh();
    return created;
  }
}

final myComplaintsProvider = AsyncNotifierProvider<MyComplaintsNotifier, List<ComplaintModel>>(() {
  return MyComplaintsNotifier();
});

final complaintDetailProvider = FutureProvider.family<ComplaintDetailModel, int>((ref, id) async {
  final repo = ref.watch(complaintRepositoryProvider);
  return repo.getComplaintDetails(id);
});
