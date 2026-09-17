import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_client.dart';
import '../core/storage/secure_storage.dart';
import '../repositories/auth_repository.dart';
import '../repositories/complaint_repository.dart';
import '../repositories/operator_repository.dart';
import '../repositories/technician_repository.dart';
import '../repositories/reference_data_repository.dart';
import '../repositories/team_lead_repository.dart';
import '../repositories/analytics_repository.dart';
import '../repositories/notification_repository.dart';
import 'role_provider.dart';

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final activeRole = ref.watch(roleProvider);
  final storage = ref.watch(secureStorageProvider);
  return ApiClient(
    userId: activeRole.userId,
    technicianId: activeRole.technicianId,
    storage: storage,
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  final storage = ref.watch(secureStorageProvider);
  return AuthRepository(apiClient: client, storage: storage);
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

final teamLeadRepositoryProvider = Provider<TeamLeadRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return TeamLeadRepository(apiClient: client);
});

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return AnalyticsRepository(apiClient: client);
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return NotificationRepository(apiClient: client);
});
