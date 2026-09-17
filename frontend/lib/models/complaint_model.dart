class ComplaintModel {
  final int id;
  final String caseNumber;
  final int? studentId;
  final String? studentName;
  final String? studentEmail;
  final int? hostelId;
  final String? hostelName;
  final int? blockId;
  final String? blockName;
  final int? roomId;
  final String? roomNumber;
  final int? categoryId;
  final String? categoryName;
  final String? subcategory;
  final String description;
  final String status;
  final String? severity;
  final String? priority;
  final int? assignedTeamId;
  final String? assignedTeamName;
  final int? assignedTechnicianId;
  final String? assignedTechnicianName;
  final String? aiStatus;
  final String? aiSummary;
  final DateTime? slaDeadline;
  final bool isAtRisk;
  final String? riskReasons;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ComplaintModel({
    required this.id,
    required this.caseNumber,
    this.studentId,
    this.studentName,
    this.studentEmail,
    this.hostelId,
    this.hostelName,
    this.blockId,
    this.blockName,
    this.roomId,
    this.roomNumber,
    this.categoryId,
    this.categoryName,
    this.subcategory,
    required this.description,
    required this.status,
    this.severity,
    this.priority,
    this.assignedTeamId,
    this.assignedTeamName,
    this.assignedTechnicianId,
    this.assignedTechnicianName,
    this.aiStatus,
    this.aiSummary,
    this.slaDeadline,
    this.isAtRisk = false,
    this.riskReasons,
    required this.createdAt,
    this.updatedAt,
  });

  factory ComplaintModel.fromJson(Map<String, dynamic> json) {
    return ComplaintModel(
      id: json['id'] is num ? (json['id'] as num).toInt() : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      caseNumber: json['caseNumber']?.toString() ?? '',
      studentId: json['studentId'] != null ? (json['studentId'] as num).toInt() : null,
      studentName: json['studentName']?.toString(),
      studentEmail: json['studentEmail']?.toString(),
      hostelId: json['hostelId'] != null ? (json['hostelId'] as num).toInt() : null,
      hostelName: json['hostelName']?.toString(),
      blockId: json['blockId'] != null ? (json['blockId'] as num).toInt() : null,
      blockName: json['blockName']?.toString(),
      roomId: json['roomId'] != null ? (json['roomId'] as num).toInt() : null,
      roomNumber: json['roomNumber']?.toString(),
      categoryId: json['categoryId'] != null ? (json['categoryId'] as num).toInt() : null,
      categoryName: json['categoryName']?.toString(),
      subcategory: json['subcategory']?.toString(),
      description: json['description']?.toString() ?? '',
      status: json['status']?.toString() ?? 'REPORTED',
      severity: json['severity']?.toString(),
      priority: json['priority']?.toString(),
      assignedTeamId: json['assignedTeamId'] != null ? (json['assignedTeamId'] as num).toInt() : null,
      assignedTeamName: json['assignedTeamName']?.toString(),
      assignedTechnicianId: json['assignedTechnicianId'] != null ? (json['assignedTechnicianId'] as num).toInt() : null,
      assignedTechnicianName: json['assignedTechnicianName']?.toString(),
      aiStatus: json['aiStatus']?.toString(),
      aiSummary: json['aiSummary']?.toString(),
      slaDeadline: json['slaDeadline'] != null ? DateTime.tryParse(json['slaDeadline'].toString()) : null,
      isAtRisk: json['isAtRisk'] == true,
      riskReasons: json['riskReasons']?.toString(),
      createdAt: json['createdAt'] != null
          ? (DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now())
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'].toString()) : null,
    );
  }

  String get locationString {
    final parts = [hostelName, blockName, roomNumber != null ? 'Room $roomNumber' : null]
        .where((e) => e != null && e.isNotEmpty)
        .toList();
    return parts.isEmpty ? 'Campus' : parts.join(' • ');
  }
}
