import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/reference_data_models.dart';
import 'mock_data.dart';

class ReferenceDataRepository {
  final ApiClient apiClient;

  ReferenceDataRepository({required this.apiClient});

  Future<List<HostelModel>> getHostels() async {
    try {
      final response = await apiClient.dio.get(ApiEndpoints.adminHostels);
      final List data = response.data['data'] as List;
      return data.map((e) => HostelModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return MockData.hostels;
    }
  }

  Future<HostelModel> createHostel(String name, String code, int? totalBlocks) async {
    try {
      final response = await apiClient.dio.post(
        ApiEndpoints.adminHostels,
        data: {'name': name, 'code': code, 'totalBlocks': totalBlocks},
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return HostelModel.fromJson(data);
    } catch (e) {
      final h = HostelModel(id: MockData.hostels.length + 1, name: name, code: code, totalBlocks: totalBlocks);
      MockData.hostels.add(h);
      return h;
    }
  }

  Future<List<BlockModel>> getBlocks(int hostelId) async {
    try {
      final response = await apiClient.dio.get(ApiEndpoints.adminBlocksByHostel(hostelId));
      final List data = response.data['data'] as List;
      return data.map((e) => BlockModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return MockData.blocks.where((b) => b.hostelId == hostelId).toList();
    }
  }

  Future<BlockModel> createBlock(int hostelId, String name, String blockCode, int? totalFloors) async {
    try {
      final response = await apiClient.dio.post(
        ApiEndpoints.adminBlocks,
        data: {'hostelId': hostelId, 'name': name, 'blockCode': blockCode, 'totalFloors': totalFloors},
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return BlockModel.fromJson(data);
    } catch (e) {
      final b = BlockModel(id: MockData.blocks.length + 1, hostelId: hostelId, name: name, blockCode: blockCode, totalFloors: totalFloors);
      MockData.blocks.add(b);
      return b;
    }
  }

  Future<List<RoomModel>> getRooms(int blockId) async {
    try {
      final response = await apiClient.dio.get(ApiEndpoints.adminRoomsByBlock(blockId));
      final List data = response.data['data'] as List;
      return data.map((e) => RoomModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return MockData.rooms.where((r) => r.blockId == blockId).toList();
    }
  }

  Future<RoomModel> createRoom(int blockId, String roomNumber, int? floorNumber, int? capacity) async {
    try {
      final response = await apiClient.dio.post(
        ApiEndpoints.adminRooms,
        data: {'blockId': blockId, 'roomNumber': roomNumber, 'floorNumber': floorNumber, 'capacity': capacity},
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return RoomModel.fromJson(data);
    } catch (e) {
      final r = RoomModel(id: MockData.rooms.length + 1, blockId: blockId, roomNumber: roomNumber, floorNumber: floorNumber, capacity: capacity);
      MockData.rooms.add(r);
      return r;
    }
  }

  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await apiClient.dio.get(ApiEndpoints.adminCategories);
      final List data = response.data['data'] as List;
      return data.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return MockData.categories;
    }
  }

  Future<CategoryModel> createCategory(String name, String code, String? description, int? defaultSlaHours) async {
    try {
      final response = await apiClient.dio.post(
        ApiEndpoints.adminCategories,
        data: {'name': name, 'code': code, 'description': description, 'defaultSlaHours': defaultSlaHours},
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return CategoryModel.fromJson(data);
    } catch (e) {
      final c = CategoryModel(id: MockData.categories.length + 1, name: name, code: code, description: description, defaultSlaHours: defaultSlaHours);
      MockData.categories.add(c);
      return c;
    }
  }

  Future<List<TeamModel>> getTeams() async {
    try {
      final response = await apiClient.dio.get(ApiEndpoints.adminTeams);
      final List data = response.data['data'] as List;
      return data.map((e) => TeamModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return MockData.teams;
    }
  }

  Future<List<TechnicianModel>> getTechnicians() async {
    return MockData.technicians;
  }
}
