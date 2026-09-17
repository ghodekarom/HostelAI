import 'package:flutter_test/flutter_test.dart';
import 'package:hfcms_frontend/models/complaint_model.dart';
import 'package:hfcms_frontend/models/complaint_detail_model.dart';
import 'package:hfcms_frontend/models/checklist_model.dart';
import 'package:hfcms_frontend/models/reference_data_models.dart';

void main() {
  group('ComplaintModel Deserialization Tests', () {
    test('parses ComplaintModel from standard backend JSON', () {
      final json = {
        'id': 10,
        'caseNumber': 'HFCMS-2026-ABCDEF',
        'studentName': 'Om Ghodekar',
        'hostelName': 'Aryabhata',
        'blockName': 'A-Block',
        'roomNumber': '101',
        'categoryName': 'Plumbing',
        'description': 'Water leaking from pipe',
        'status': 'REPORTED',
        'severity': 'HIGH',
        'priority': 'P2',
        'createdAt': '2026-09-17T12:00:00Z',
      };

      final model = ComplaintModel.fromJson(json);

      expect(model.id, 10);
      expect(model.caseNumber, 'HFCMS-2026-ABCDEF');
      expect(model.studentName, 'Om Ghodekar');
      expect(model.status, 'REPORTED');
      expect(model.severity, 'HIGH');
      expect(model.priority, 'P2');
      expect(model.locationString, 'Aryabhata • A-Block • Room 101');
    });

    test('parses ComplaintDetailModel with audit timeline and resolution', () {
      final json = {
        'complaint': {
          'id': 1,
          'caseNumber': 'HFCMS-2026-477AC4',
          'description': 'Washbasin tap leak',
          'status': 'RESOLUTION_PROPOSED',
          'createdAt': '2026-09-17T10:00:00Z',
        },
        'statusHistory': [
          {
            'id': 1,
            'previousStatus': null,
            'newStatus': 'REPORTED',
            'changedByName': 'Student',
            'changeReason': 'Initial filing',
            'createdAt': '2026-09-17T10:00:00Z',
          },
          {
            'id': 2,
            'previousStatus': 'REPORTED',
            'newStatus': 'ASSIGNED',
            'changedByName': 'Operator',
            'changeReason': 'Assigned to tech',
            'createdAt': '2026-09-17T10:30:00Z',
          },
        ],
        'resolution': {
          'id': 1,
          'problemDescription': 'Washbasin leak',
          'rootCause': 'Damaged rubber washer',
          'actionTaken': 'Replaced washer gasket',
          'resultSummary': 'Tested leak-free',
        },
        'evidence': [],
        'assignmentHistory': [],
      };

      final detail = ComplaintDetailModel.fromJson(json);

      expect(detail.complaint.caseNumber, 'HFCMS-2026-477AC4');
      expect(detail.statusHistory.length, 2);
      expect(detail.statusHistory.first.newStatus, 'REPORTED');
      expect(detail.statusHistory.last.newStatus, 'ASSIGNED');
      expect(detail.resolution, isNotNull);
      expect(detail.resolution!.rootCause, 'Damaged rubber washer');
    });

    test('parses ChecklistModel with items and statuses', () {
      final json = {
        'id': 5,
        'complaintId': 1,
        'items': [
          {
            'id': 1,
            'itemDescription': 'Inspect tap head',
            'status': 'COMPLETED',
            'findingNotes': 'Calcification found',
          },
          {
            'id': 2,
            'itemDescription': 'Check pressure valve',
            'status': 'PENDING',
          },
        ],
      };

      final checklist = ChecklistModel.fromJson(json);

      expect(checklist.id, 5);
      expect(checklist.complaintId, 1);
      expect(checklist.items.length, 2);
      expect(checklist.items.first.status, 'COMPLETED');
      expect(checklist.items.first.findingNotes, 'Calcification found');
      expect(checklist.items.last.status, 'PENDING');
    });

    test('parses Reference Data models (Hostel, Category, Team)', () {
      final hostel = HostelModel.fromJson({
        'id': 1,
        'name': 'Aryabhata',
        'code': 'HOSTEL-A',
        'totalBlocks': 3,
      });
      final category = CategoryModel.fromJson({
        'id': 1,
        'name': 'Plumbing',
        'code': 'PLUMBING',
        'defaultSlaHours': 24,
      });
      final team = TeamModel.fromJson({
        'id': 1,
        'name': 'Plumbing Maintenance',
        'code': 'TEAM-PLUMB',
      });

      expect(hostel.name, 'Aryabhata');
      expect(category.defaultSlaHours, 24);
      expect(team.code, 'TEAM-PLUMB');
    });
  });
}
