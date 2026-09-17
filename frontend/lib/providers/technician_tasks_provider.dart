import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/complaint_model.dart';
import '../models/checklist_model.dart';
import 'api_providers.dart';

class TechnicianTasksNotifier extends AsyncNotifier<List<ComplaintModel>> {
  @override
  Future<List<ComplaintModel>> build() async {
    final repo = ref.watch(technicianRepositoryProvider);
    return repo.getAssignedTasks();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(technicianRepositoryProvider);
      return repo.getAssignedTasks();
    });
  }

  Future<void> logRepair(int id, {
    required String actionDescription,
    String? partsReplaced,
    String? notes,
  }) async {
    final repo = ref.read(technicianRepositoryProvider);
    await repo.recordRepairAction(
      complaintId: id,
      actionDescription: actionDescription,
      partsReplaced: partsReplaced,
      notes: notes,
    );
    await refresh();
  }
}

final technicianTasksProvider = AsyncNotifierProvider<TechnicianTasksNotifier, List<ComplaintModel>>(() {
  return TechnicianTasksNotifier();
});

final checklistProvider = FutureProvider.family<ChecklistModel, int>((ref, complaintId) async {
  final repo = ref.watch(technicianRepositoryProvider);
  return repo.getChecklist(complaintId);
});
