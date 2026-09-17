class CategoryModel {
  final int id;
  final String name;
  final String code;
  final String? description;
  final int? defaultSlaHours;
  final bool isActive;

  CategoryModel({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    this.defaultSlaHours,
    this.isActive = true,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] is num ? (json['id'] as num).toInt() : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      description: json['description']?.toString(),
      defaultSlaHours: json['defaultSlaHours'] != null ? (json['defaultSlaHours'] as num).toInt() : null,
      isActive: json['isActive'] != false,
    );
  }
}

class TeamModel {
  final int id;
  final String name;
  final String code;
  final String? description;
  final int? leadUserId;

  TeamModel({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    this.leadUserId,
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    return TeamModel(
      id: json['id'] is num ? (json['id'] as num).toInt() : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      description: json['description']?.toString(),
      leadUserId: json['leadUserId'] != null ? (json['leadUserId'] as num).toInt() : null,
    );
  }
}

class HostelModel {
  final int id;
  final String name;
  final String code;
  final int? totalBlocks;

  HostelModel({
    required this.id,
    required this.name,
    required this.code,
    this.totalBlocks,
  });

  factory HostelModel.fromJson(Map<String, dynamic> json) {
    return HostelModel(
      id: json['id'] is num ? (json['id'] as num).toInt() : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      totalBlocks: json['totalBlocks'] != null ? (json['totalBlocks'] as num).toInt() : null,
    );
  }
}

class BlockModel {
  final int id;
  final int? hostelId;
  final String name;
  final String blockCode;
  final int? totalFloors;

  BlockModel({
    required this.id,
    this.hostelId,
    required this.name,
    required this.blockCode,
    this.totalFloors,
  });

  factory BlockModel.fromJson(Map<String, dynamic> json) {
    return BlockModel(
      id: json['id'] is num ? (json['id'] as num).toInt() : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      hostelId: json['hostelId'] != null ? (json['hostelId'] as num).toInt() : null,
      name: json['name']?.toString() ?? '',
      blockCode: json['blockCode']?.toString() ?? '',
      totalFloors: json['totalFloors'] != null ? (json['totalFloors'] as num).toInt() : null,
    );
  }
}

class RoomModel {
  final int id;
  final int? blockId;
  final String roomNumber;
  final int? floorNumber;
  final int? capacity;

  RoomModel({
    required this.id,
    this.blockId,
    required this.roomNumber,
    this.floorNumber,
    this.capacity,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'] is num ? (json['id'] as num).toInt() : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      blockId: json['blockId'] != null ? (json['blockId'] as num).toInt() : null,
      roomNumber: json['roomNumber']?.toString() ?? '',
      floorNumber: json['floorNumber'] != null ? (json['floorNumber'] as num).toInt() : null,
      capacity: json['capacity'] != null ? (json['capacity'] as num).toInt() : null,
    );
  }
}

class TechnicianModel {
  final int id;
  final String name;
  final String? phone;
  final int? teamId;
  final String? teamName;
  final String? status;

  TechnicianModel({
    required this.id,
    required this.name,
    this.phone,
    this.teamId,
    this.teamName,
    this.status,
  });

  factory TechnicianModel.fromJson(Map<String, dynamic> json) {
    return TechnicianModel(
      id: json['id'] is num ? (json['id'] as num).toInt() : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString(),
      teamId: json['teamId'] != null ? (json['teamId'] as num).toInt() : null,
      teamName: json['teamName']?.toString(),
      status: json['status']?.toString() ?? 'AVAILABLE',
    );
  }
}
