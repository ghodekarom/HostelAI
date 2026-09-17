import 'complaint_model.dart';

class TeamLeadContextModel {
  final ComplaintModel complaint;
  final String slaStatus;
  final List<String> riskFactors;
  final int affectedStudentsCount;
  final String aiEscalationDraft;

  TeamLeadContextModel({
    required this.complaint,
    required this.slaStatus,
    required this.riskFactors,
    required this.affectedStudentsCount,
    required this.aiEscalationDraft,
  });

  factory TeamLeadContextModel.fromJson(Map<String, dynamic> json) {
    return TeamLeadContextModel(
      complaint: ComplaintModel.fromJson(json['complaint'] as Map<String, dynamic>? ?? json),
      slaStatus: json['slaStatus']?.toString() ?? 'SLA Near Breach (< 20% remaining)',
      riskFactors: (json['riskFactors'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          ['Inactivity for > 24 hours without technician finding update', 'Repeated student follow-ups logged'],
      affectedStudentsCount: json['affectedStudentsCount'] is num
          ? (json['affectedStudentsCount'] as num).toInt()
          : 8,
      aiEscalationDraft: json['aiEscalationDraft']?.toString() ??
          'AI Assessment: Complaint has exceeded typical MTTR for its category. Recommend priority boost or secondary technician reassignment.',
    );
  }
}

class InterventionRequest {
  final String action; // REASSIGN_TECHNICIAN, BOOST_PRIORITY, ADD_RESOURCES, ESCALATE
  final int? technicianId;
  final String? priority;
  final String notes;

  InterventionRequest({
    required this.action,
    this.technicianId,
    this.priority,
    required this.notes,
  });

  Map<String, dynamic> toJson() => {
        'action': action,
        'technicianId': technicianId,
        'priority': priority,
        'notes': notes,
      };
}
