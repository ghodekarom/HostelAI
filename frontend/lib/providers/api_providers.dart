import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_client.dart';
import '../repositories/complaint_repository.dart';
import '../repositories/operator_repository.dart';
import '../repositories/technician_repository.dart';
import '../repositories/reference_data_repository.dart';
import 'role_provider.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  final activeRole = ref.watch(roleProvider);
  return ApiClient(
    userId: activeRole.userId,
    technicianId: activeRole.technicianId,
  );
});

final complaintRepositoryProvider = Provider<ComplaintRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return ComplaintRepository(apiClient: client);
});

final operatorRepositoryProvider = Provider<OperatorRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return OperatorRepository(apiClient: client);
});

final technicianRepositoryProvider = Provider<TechnicianRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return TechnicianRepository(apiClient: client);
});

final referenceDataRepositoryProvider = Provider<ReferenceDataRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return ReferenceDataRepository(apiClient: client);
});
