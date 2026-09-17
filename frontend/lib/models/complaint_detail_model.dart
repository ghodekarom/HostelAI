import 'complaint_model.dart';

class EvidenceDetailModel {
  final int id;
  final String fileUrl;
  final String? fileType;
  final int? fileSizeBytes;
  final int? uploaderId;
  final String? uploaderName;
  final String? evidenceStage;
  final DateTime createdAt;

  EvidenceDetailModel({
    required this.id,
    required this.fileUrl,
    this.fileType,
    this.fileSizeBytes,
    this.uploaderId,
    this.uploaderName,
    this.evidenceStage,
    required this.createdAt,
  });

  factory EvidenceDetailModel.fromJson(Map<String, dynamic> json) {
    return EvidenceDetailModel(
      id: json['id'] is num ? (json['id'] as num).toInt() : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      fileUrl: json['fileUrl']?.toString() ?? '',
      fileType: json['fileType']?.toString(),
      fileSizeBytes: json['fileSizeBytes'] != null ? (json['fileSizeBytes'] as num).toInt() : null,
      uploaderId: json['uploaderId'] != null ? (json['uploaderId'] as num).toInt() : null,
      uploaderName: json['uploaderName']?.toString(),
      evidenceStage: json['evidenceStage']?.toString(),
      createdAt: json['createdAt'] != null
          ? (DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now())
          : DateTime.now(),
    );
  }
}

class AssignmentHistoryModel {
  final int id;
  final String? previousTechnicianName;
  final String? newTechnicianName;
  final String? previousTeamName;
  final String? newTeamName;
  final String? assignedByName;
  final String? assignmentReason;
  final DateTime createdAt;

  AssignmentHistoryModel({
    required this.id,
    this.previousTechnicianName,
    this.newTechnicianName,
    this.previousTeamName,
    this.newTeamName,
    this.assignedByName,
    this.assignmentReason,
    required this.createdAt,
  });

  factory AssignmentHistoryModel.fromJson(Map<String, dynamic> json) {
    return AssignmentHistoryModel(
      id: json['id'] is num ? (json['id'] as num).toInt() : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      previousTechnicianName: json['previousTechnicianName']?.toString(),
      newTechnicianName: json['newTechnicianName']?.toString(),
      previousTeamName: json['previousTeamName']?.toString(),
      newTeamName: json['newTeamName']?.toString(),
      assignedByName: json['assignedByName']?.toString(),
      assignmentReason: json['assignmentReason']?.toString(),
      createdAt: json['createdAt'] != null
          ? (DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now())
          : DateTime.now(),
    );
  }
}

class StatusHistoryModel {
  final int id;
  final String? previousStatus;
  final String newStatus;
  final String? changedByName;
  final String? changeReason;
  final DateTime createdAt;

  StatusHistoryModel({
    required this.id,
    this.previousStatus,
    required this.newStatus,
    this.changedByName,
    this.changeReason,
    required this.createdAt,
  });

  factory StatusHistoryModel.fromJson(Map<String, dynamic> json) {
    return StatusHistoryModel(
      id: json['id'] is num ? (json['id'] as num).toInt() : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      previousStatus: json['previousStatus']?.toString(),
      newStatus: json['newStatus']?.toString() ?? '',
      changedByName: json['changedByName']?.toString(),
      changeReason: json['changeReason']?.toString(),
      createdAt: json['createdAt'] != null
          ? (DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now())
          : DateTime.now(),
    );
  }
}

class ResolutionDetailModel {
  final int id;
  final String? proposedByName;
  final String problemDescription;
  final String rootCause;
  final String actionTaken;
  final String? resultSummary;
  final String? studentDecision;
  final String? studentFeedback;
  final DateTime? proposedAt;
  final DateTime? decidedAt;

  ResolutionDetailModel({
    required this.id,
    this.proposedByName,
    required this.problemDescription,
    required this.rootCause,
    required this.actionTaken,
    this.resultSummary,
    this.studentDecision,
    this.studentFeedback,
    this.proposedAt,
    this.decidedAt,
  });

  factory ResolutionDetailModel.fromJson(Map<String, dynamic> json) {
    return ResolutionDetailModel(
      id: json['id'] is num ? (json['id'] as num).toInt() : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      proposedByName: json['proposedByName']?.toString(),
      problemDescription: json['problemDescription']?.toString() ?? '',
      rootCause: json['rootCause']?.toString() ?? '',
      actionTaken: json['actionTaken']?.toString() ?? '',
      resultSummary: json['resultSummary']?.toString(),
      studentDecision: json['studentDecision']?.toString(),
      studentFeedback: json['studentFeedback']?.toString(),
      proposedAt: json['proposedAt'] != null ? DateTime.tryParse(json['proposedAt'].toString()) : null,
      decidedAt: json['decidedAt'] != null ? DateTime.tryParse(json['decidedAt'].toString()) : null,
    );
  }
}

class ComplaintDetailModel {
  final ComplaintModel complaint;
  final List<EvidenceDetailModel> evidence;
  final List<AssignmentHistoryModel> assignmentHistory;
  final List<StatusHistoryModel> statusHistory;
  final ResolutionDetailModel? resolution;

  ComplaintDetailModel({
    required this.complaint,
    required this.evidence,
    required this.assignmentHistory,
    required this.statusHistory,
    this.resolution,
  });

  factory ComplaintDetailModel.fromJson(Map<String, dynamic> json) {
    return ComplaintDetailModel(
      complaint: ComplaintModel.fromJson(
        json['complaint'] as Map<String, dynamic>? ?? json,
      ),
      evidence: (json['evidence'] as List<dynamic>?)
              ?.map((e) => EvidenceDetailModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      assignmentHistory: (json['assignmentHistory'] as List<dynamic>?)
              ?.map((e) => AssignmentHistoryModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      statusHistory: (json['statusHistory'] as List<dynamic>?)
              ?.map((e) => StatusHistoryModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      resolution: json['resolution'] != null
          ? ResolutionDetailModel.fromJson(json['resolution'] as Map<String, dynamic>)
          : null,
    );
  }
}
