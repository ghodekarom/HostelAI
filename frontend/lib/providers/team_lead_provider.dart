import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/complaint_model.dart';
import '../models/team_lead_models.dart';
import 'api_providers.dart';

class TeamLeadNotifier extends AsyncNotifier<List<ComplaintModel>> {
  @override
  Future<List<ComplaintModel>> build() async {
    final repo = ref.watch(teamLeadRepositoryProvider);
    return repo.getAtRiskComplaints();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(teamLeadRepositoryProvider);
      return repo.getAtRiskComplaints();
    });
  }

  Future<void> intervene(int complaintId, InterventionRequest request) async {
    final repo = ref.read(teamLeadRepositoryProvider);
    await repo.intervene(complaintId, request);
    await refresh();
  }
}

final teamLeadAtRiskProvider = AsyncNotifierProvider<TeamLeadNotifier, List<ComplaintModel>>(() {
  return TeamLeadNotifier();
});

final teamLeadContextProvider = FutureProvider.family<TeamLeadContextModel, int>((ref, complaintId) async {
  final repo = ref.watch(teamLeadRepositoryProvider);
  return repo.getContext(complaintId);
});
