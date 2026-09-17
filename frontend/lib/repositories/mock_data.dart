import '../models/complaint_model.dart';
import '../models/complaint_detail_model.dart';
import '../models/checklist_model.dart';
import '../models/reference_data_models.dart';

class MockData {
  static List<HostelModel> get hostels => [
        HostelModel(id: 1, name: 'Aryabhata Hall of Residence', code: 'HOSTEL-A', totalBlocks: 3),
        HostelModel(id: 2, name: 'Bhaskara Hall of Residence', code: 'HOSTEL-B', totalBlocks: 2),
      ];

  static List<BlockModel> get blocks => [
        BlockModel(id: 1, hostelId: 1, name: 'A-Block', blockCode: 'BLK-A', totalFloors: 4),
        BlockModel(id: 2, hostelId: 1, name: 'B-Block', blockCode: 'BLK-B', totalFloors: 4),
      ];

  static List<RoomModel> get rooms => [
        RoomModel(id: 1, blockId: 1, roomNumber: '101', floorNumber: 1, capacity: 2),
        RoomModel(id: 2, blockId: 1, roomNumber: '102', floorNumber: 1, capacity: 2),
        RoomModel(id: 3, blockId: 1, roomNumber: '201', floorNumber: 2, capacity: 3),
      ];

  static List<CategoryModel> get categories => [
        CategoryModel(id: 1, name: 'Plumbing & Water Supply', code: 'PLUMBING', defaultSlaHours: 24),
        CategoryModel(id: 2, name: 'Electrical & Power', code: 'ELECTRICAL', defaultSlaHours: 12),
        CategoryModel(id: 3, name: 'Carpentry & Furniture', code: 'CARPENTRY', defaultSlaHours: 48),
        CategoryModel(id: 4, name: 'Internet & Wi-Fi', code: 'NETWORK', defaultSlaHours: 8),
        CategoryModel(id: 5, name: 'Housekeeping & Cleanliness', code: 'CLEANLINESS', defaultSlaHours: 12),
      ];

  static List<TeamModel> get teams => [
        TeamModel(id: 1, name: 'Plumbing Maintenance', code: 'TEAM-PLUMB'),
        TeamModel(id: 2, name: 'Electrical Maintenance', code: 'TEAM-ELEC'),
        TeamModel(id: 3, name: 'IT Infrastructure', code: 'TEAM-IT'),
        TeamModel(id: 4, name: 'Carpentry Works', code: 'TEAM-CARP'),
      ];

  static List<TechnicianModel> get technicians => [
        TechnicianModel(id: 1, name: 'Suresh Kumar', phone: '+91 98765 43210', teamId: 1, teamName: 'Plumbing Maintenance', status: 'AVAILABLE'),
        TechnicianModel(id: 2, name: 'Ramesh Verma', phone: '+91 98765 43211', teamId: 2, teamName: 'Electrical Maintenance', status: 'AVAILABLE'),
        TechnicianModel(id: 3, name: 'Amit Patil', phone: '+91 98765 43212', teamId: 3, teamName: 'IT Infrastructure', status: 'AVAILABLE'),
      ];

  static List<ComplaintModel> get complaints => [
        ComplaintModel(
          id: 1,
          caseNumber: 'HFCMS-2026-477AC4',
          studentId: 1,
          studentName: 'Rahul Sharma',
          studentEmail: 'rahul.sharma@hostel.edu',
          hostelId: 1,
          hostelName: 'Aryabhata Hall of Residence',
          blockId: 1,
          blockName: 'A-Block',
          roomId: 1,
          roomNumber: '101',
          categoryId: 1,
          categoryName: 'Plumbing & Water Supply',
          subcategory: 'Tap Leakage',
          description: 'Bathroom washbasin tap has a severe continuous leak, causing water accumulation on the floor.',
          status: 'ACTION_TAKEN',
          severity: 'HIGH',
          priority: 'P2',
          assignedTeamId: 1,
          assignedTeamName: 'Plumbing Maintenance',
          assignedTechnicianId: 1,
          assignedTechnicianName: 'Suresh Kumar',
          aiStatus: 'COMPLETED',
          aiSummary: 'High-severity water leakage reported in Room 101 washbasin. Assigned to Suresh Kumar.',
          slaDeadline: DateTime.now().add(const Duration(hours: 18)),
          isAtRisk: false,
          createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        ),
        ComplaintModel(
          id: 2,
          caseNumber: 'HFCMS-2026-B8123C',
          studentId: 1,
          studentName: 'Rahul Sharma',
          studentEmail: 'rahul.sharma@hostel.edu',
          hostelId: 1,
          hostelName: 'Aryabhata Hall of Residence',
          blockId: 1,
          blockName: 'A-Block',
          roomId: 1,
          roomNumber: '101',
          categoryId: 2,
          categoryName: 'Electrical & Power',
          subcategory: 'Ceiling Fan',
          description: 'Ceiling fan makes loud grinding sound and operates at very slow speed even at setting 5.',
          status: 'OPERATOR_REVIEW',
          severity: 'MEDIUM',
          priority: 'P3',
          assignedTeamId: 2,
          assignedTeamName: 'Electrical Maintenance',
          aiStatus: 'COMPLETED',
          aiSummary: 'Ceiling fan bearing failure suspected. Recommend electrical inspection.',
          slaDeadline: DateTime.now().add(const Duration(hours: 36)),
          isAtRisk: false,
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        ComplaintModel(
          id: 3,
          caseNumber: 'HFCMS-2026-92F01A',
          studentId: 2,
          studentName: 'Priya Patel',
          studentEmail: 'priya.patel@hostel.edu',
          hostelId: 1,
          hostelName: 'Aryabhata Hall of Residence',
          blockId: 2,
          blockName: 'B-Block',
          roomId: 3,
          roomNumber: '201',
          categoryId: 4,
          categoryName: 'Internet & Wi-Fi',
          subcategory: 'Access Point Down',
          description: 'Wi-Fi access point in 2nd floor corridor has been flashing red with no internet access for 2 days.',
          status: 'AT_RISK',
          severity: 'HIGH',
          priority: 'P1',
          assignedTeamId: 3,
          assignedTeamName: 'IT Infrastructure',
          assignedTechnicianId: 3,
          assignedTechnicianName: 'Amit Patil',
          aiStatus: 'COMPLETED',
          aiSummary: 'Critical access point outage affecting multiple rooms. Overdue for resolution.',
          slaDeadline: DateTime.now().subtract(const Duration(hours: 4)),
          isAtRisk: true,
          riskReasons: '{"reasons":["SLA deadline breached","High affected student count"]}',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ];

  static ComplaintDetailModel sampleDetail(int id) {
    final base = complaints.firstWhere((c) => c.id == id, orElse: () => complaints.first);
    return ComplaintDetailModel(
      complaint: base,
      evidence: [
        EvidenceDetailModel(
          id: 1,
          fileUrl: 'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?auto=format&fit=crop&w=800&q=80',
          fileType: 'image/jpeg',
          fileSizeBytes: 245000,
          uploaderName: base.studentName,
          evidenceStage: 'INTAKE',
          createdAt: base.createdAt,
        ),
      ],
      assignmentHistory: [
        AssignmentHistoryModel(
          id: 1,
          newTechnicianName: base.assignedTechnicianName ?? 'Suresh Kumar',
          newTeamName: base.assignedTeamName ?? 'Plumbing Maintenance',
          assignedByName: 'Operator Sunita',
          assignmentReason: 'Initial assignment based on category and availability',
          createdAt: base.createdAt.add(const Duration(minutes: 45)),
        ),
      ],
      statusHistory: [
        StatusHistoryModel(
          id: 1,
          newStatus: 'REPORTED',
          changedByName: base.studentName,
          changeReason: 'Complaint filed by student',
          createdAt: base.createdAt,
        ),
        StatusHistoryModel(
          id: 2,
          previousStatus: 'REPORTED',
          newStatus: 'OPERATOR_REVIEW',
          changedByName: 'Operator Sunita',
          changeReason: 'Operator reviewed AI triage suggestions',
          createdAt: base.createdAt.add(const Duration(minutes: 30)),
        ),
        StatusHistoryModel(
          id: 3,
          previousStatus: 'OPERATOR_REVIEW',
          newStatus: 'ASSIGNED',
          changedByName: 'Operator Sunita',
          changeReason: 'Assigned to field technician',
          createdAt: base.createdAt.add(const Duration(minutes: 45)),
        ),
        StatusHistoryModel(
          id: 4,
          previousStatus: 'ASSIGNED',
          newStatus: 'INVESTIGATED',
          changedByName: base.assignedTechnicianName ?? 'Suresh Kumar',
          changeReason: 'Checklist inspection findings logged',
          createdAt: base.createdAt.add(const Duration(hours: 2)),
        ),
        StatusHistoryModel(
          id: 5,
          previousStatus: 'INVESTIGATED',
          newStatus: 'ACTION_TAKEN',
          changedByName: base.assignedTechnicianName ?? 'Suresh Kumar',
          changeReason: 'Replaced worn-out rubber washer and re-sealed spindle',
          createdAt: base.createdAt.add(const Duration(hours: 4)),
        ),
      ],
      resolution: base.status == 'RESOLUTION_PROPOSED' || base.status == 'CLOSED'
          ? ResolutionDetailModel(
              id: 1,
              proposedByName: 'Operator Sunita',
              problemDescription: 'Severe continuous leak from washbasin tap',
              rootCause: 'Degraded rubber washer gasket causing loose seal under water pressure',
              actionTaken: 'Replaced washer gasket with heavy-duty brass-compatible seal and tested flow',
              resultSummary: 'Leak completely resolved, water pressure normalized',
              proposedAt: base.createdAt.add(const Duration(hours: 4, minutes: 30)),
            )
          : null,
    );
  }

  static ChecklistModel sampleChecklist(int complaintId) {
    return ChecklistModel(
      id: 1,
      complaintId: complaintId,
      items: [
        ChecklistItemModel(
          id: 1,
          itemDescription: 'Inspect tap spindle, handle alignment, and aerator for calcification',
          status: 'COMPLETED',
          findingNotes: 'Spindle intact, heavy lime scale deposit found inside aerator',
          verifiedAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        ChecklistItemModel(
          id: 2,
          itemDescription: 'Verify main supply pressure and shutoff valve seal',
          status: 'COMPLETED',
          findingNotes: 'Angle cock functioning properly, rubber washer damaged',
          verifiedAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        ChecklistItemModel(
          id: 3,
          itemDescription: 'Pressure test post-repair for minimum 5 minutes continuous flow',
          status: 'PENDING',
        ),
      ],
    );
  }
}
