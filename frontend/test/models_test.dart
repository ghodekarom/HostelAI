import 'package:flutter_test/flutter_test.dart';
import 'package:hfcms_frontend/models/complaint_model.dart';
import 'package:hfcms_frontend/models/complaint_detail_model.dart';
import 'package:hfcms_frontend/models/checklist_model.dart';
import 'package:hfcms_frontend/models/reference_data_models.dart';
import 'package:hfcms_frontend/models/auth_models.dart';
import 'package:hfcms_frontend/models/team_lead_models.dart';
import 'package:hfcms_frontend/models/analytics_models.dart';
import 'package:hfcms_frontend/models/notification_models.dart';

void main() {
  group('SRS Domain Model Deserialization Tests', () {
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

    test('parses AuthResponse model', () {
      final auth = AuthResponse.fromJson({
        'accessToken': 'jwt_access_token_123',
        'refreshToken': 'jwt_refresh_token_456',
        'email': 'student@hostel.edu',
        'fullName': 'Rahul Sharma',
        'role': 'STUDENT',
      });

      expect(auth.accessToken, 'jwt_access_token_123');
      expect(auth.email, 'student@hostel.edu');
      expect(auth.role, 'STUDENT');
    });

    test('parses TeamLeadContextModel and InterventionRequest', () {
      final ctx = TeamLeadContextModel.fromJson({
        'complaint': {
          'id': 3,
          'caseNumber': 'HFCMS-2026-92F01A',
          'description': 'Wi-Fi down',
          'status': 'AT_RISK',
          'createdAt': '2026-09-17T08:00:00Z',
        },
        'slaStatus': 'SLA Breached by 4 hours',
        'affectedStudentsCount': 12,
        'riskFactors': ['SLA target exceeded', 'Repeated follow-ups'],
      });

      expect(ctx.complaint.caseNumber, 'HFCMS-2026-92F01A');
      expect(ctx.affectedStudentsCount, 12);
      expect(ctx.riskFactors.length, 2);

      final req = InterventionRequest(
        action: 'BOOST_PRIORITY',
        priority: 'P1',
        notes: 'Accelerating due to exams',
      );
      expect(req.toJson()['action'], 'BOOST_PRIORITY');
      expect(req.toJson()['priority'], 'P1');
    });

    test('parses Analytics models', () {
      final summary = AnalyticsSummaryModel.fromJson({
        'totalComplaints': 300,
        'activeComplaints': 25,
        'averageMttrHours': 10.5,
        'averageMttaHours': 1.1,
        'slaComplianceRate': 96.4,
        'chronicHotspotsCount': 5,
      });

      expect(summary.totalComplaints, 300);
      expect(summary.slaComplianceRate, 96.4);

      final hotspot = HotspotItemModel.fromJson({
        'location': 'Block A Floor 1',
        'categoryName': 'Plumbing',
        'complaintCount': 15,
        'riskLevel': 'HIGH',
      });
      expect(hotspot.location, 'Block A Floor 1');
      expect(hotspot.riskLevel, 'HIGH');
    });

    test('parses NotificationModel', () {
      final notif = NotificationModel.fromJson({
        'id': 1,
        'title': 'Clarification Requested',
        'message': 'Please provide room number',
        'type': 'ACTION_REQUIRED',
        'referenceId': 4,
        'isRead': false,
        'createdAt': '2026-09-17T11:00:00Z',
      });

      expect(notif.id, 1);
      expect(notif.type, 'ACTION_REQUIRED');
      expect(notif.isRead, false);
    });
  });
}
