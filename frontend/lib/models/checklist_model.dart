class ChecklistItemModel {
  final int id;
  final String itemDescription;
  final String status;
  final String? findingNotes;
  final DateTime? verifiedAt;

  ChecklistItemModel({
    required this.id,
    required this.itemDescription,
    required this.status,
    this.findingNotes,
    this.verifiedAt,
  });

  factory ChecklistItemModel.fromJson(Map<String, dynamic> json) {
    return ChecklistItemModel(
      id: json['id'] is num ? (json['id'] as num).toInt() : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      itemDescription: json['itemDescription']?.toString() ?? '',
      status: json['status']?.toString() ?? 'PENDING',
      findingNotes: json['findingNotes']?.toString(),
      verifiedAt: json['verifiedAt'] != null ? DateTime.tryParse(json['verifiedAt'].toString()) : null,
    );
  }
}

class ChecklistModel {
  final int id;
  final int complaintId;
  final List<ChecklistItemModel> items;

  ChecklistModel({
    required this.id,
    required this.complaintId,
    required this.items,
  });

  factory ChecklistModel.fromJson(Map<String, dynamic> json) {
    return ChecklistModel(
      id: json['id'] is num ? (json['id'] as num).toInt() : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      complaintId: json['complaintId'] is num
          ? (json['complaintId'] as num).toInt()
          : int.tryParse(json['complaintId']?.toString() ?? '0') ?? 0,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => ChecklistItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
