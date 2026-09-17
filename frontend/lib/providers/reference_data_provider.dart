import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reference_data_models.dart';
import 'api_providers.dart';

final hostelsProvider = FutureProvider<List<HostelModel>>((ref) async {
  final repo = ref.watch(referenceDataRepositoryProvider);
  return repo.getHostels();
});

final blocksProvider = FutureProvider.family<List<BlockModel>, int>((ref, hostelId) async {
  final repo = ref.watch(referenceDataRepositoryProvider);
  return repo.getBlocks(hostelId);
});

final roomsProvider = FutureProvider.family<List<RoomModel>, int>((ref, blockId) async {
  final repo = ref.watch(referenceDataRepositoryProvider);
  return repo.getRooms(blockId);
});

final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  final repo = ref.watch(referenceDataRepositoryProvider);
  return repo.getCategories();
});

final teamsProvider = FutureProvider<List<TeamModel>>((ref) async {
  final repo = ref.watch(referenceDataRepositoryProvider);
  return repo.getTeams();
});

final techniciansProvider = FutureProvider<List<TechnicianModel>>((ref) async {
  final repo = ref.watch(referenceDataRepositoryProvider);
  return repo.getTechnicians();
});
