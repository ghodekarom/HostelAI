import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/complaint_model.dart';
import 'api_providers.dart';

final operatorQueueFilterProvider = StateProvider<List<String>?>((ref) => null);
final operatorSearchQueryProvider = StateProvider<String>((ref) => '');

class OperatorQueueNotifier extends AsyncNotifier<List<ComplaintModel>> {
  @override
  Future<List<ComplaintModel>> build() async {
    final repo = ref.watch(operatorRepositoryProvider);
    final filter = ref.watch(operatorQueueFilterProvider);
    return repo.getOperatorQueue(statuses: filter);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(operatorRepositoryProvider);
      final filter = ref.read(operatorQueueFilterProvider);
      return repo.getOperatorQueue(statuses: filter);
    });
  }

  Future<void> reviewCase(int id, {
    required String severity,
    required String priority,
    required int categoryId,
    int? teamId,
    String? operatorNotes,
  }) async {
    final repo = ref.read(operatorRepositoryProvider);
    await repo.reviewComplaint(
      id: id,
      severity: severity,
      priority: priority,
      categoryId: categoryId,
      teamId: teamId,
      operatorNotes: operatorNotes,
    );
    await refresh();
  }

  Future<void> assignCase(int id, {
    required int teamId,
    required int technicianId,
    String? assignmentReason,
  }) async {
    final repo = ref.read(operatorRepositoryProvider);
    await repo.assignComplaint(
      id: id,
      teamId: teamId,
      technicianId: technicianId,
      assignmentReason: assignmentReason,
    );
    await refresh();
  }
}

final operatorQueueProvider = AsyncNotifierProvider<OperatorQueueNotifier, List<ComplaintModel>>(() {
  return OperatorQueueNotifier();
});

final relatedCasesProvider = FutureProvider.family<List<ComplaintModel>, int>((ref, id) async {
  final repo = ref.watch(operatorRepositoryProvider);
  return repo.getRelatedCases(id);
});
