import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/notification_models.dart';

class NotificationRepository {
  final ApiClient apiClient;

  NotificationRepository({required this.apiClient});

  static final List<NotificationModel> _mockNotifications = [
    NotificationModel(
      id: 1,
      title: 'Action Required: Clarification Requested',
      message: 'Operator requested clarification on your complaint HFCMS-2026-477AC4.',
      type: 'ACTION_REQUIRED',
      referenceId: 'HFCMS-2026-477AC4',
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    NotificationModel(
      id: 2,
      title: 'Technician Assigned',
      message: 'Technician Suresh Kumar has been dispatched for your complaint HFCMS-2026-477AC4.',
      type: 'ASSIGNED',
      referenceId: 'HFCMS-2026-477AC4',
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    NotificationModel(
      id: 3,
      title: 'Complaint Registered',
      message: 'Your complaint HFCMS-2026-477AC4 has been filed and queued for review.',
      type: 'COMPLAINT_FILED',
      referenceId: 'HFCMS-2026-477AC4',
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
    ),
  ];

  Future<List<NotificationModel>> getNotifications() async {
    try {
      final res = await apiClient.dio.get(ApiEndpoints.notifications);
      final pageData = res.data['data'];
      final List content = pageData is Map && pageData['content'] is List
          ? pageData['content'] as List
          : (pageData is List ? pageData : []);
      return content.map((e) => NotificationModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return _mockNotifications;
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final res = await apiClient.dio.get('/notifications/unread-count');
      if (res.data != null && res.data['data'] != null) {
        final data = res.data['data'];
        if (data is Map && data['unreadCount'] != null) {
          return (data['unreadCount'] as num).toInt();
        }
      }
      return _mockNotifications.where((n) => !n.isRead).length;
    } catch (_) {
      return _mockNotifications.where((n) => !n.isRead).length;
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      await apiClient.dio.post(ApiEndpoints.markNotificationRead(id));
    } catch (_) {}
    final idx = _mockNotifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      final n = _mockNotifications[idx];
      _mockNotifications[idx] = NotificationModel(
        id: n.id,
        title: n.title,
        message: n.message,
        type: n.type,
        referenceId: n.referenceId,
        isRead: true,
        createdAt: n.createdAt,
      );
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await apiClient.dio.post('/notifications/read-all');
    } catch (_) {}
    for (int i = 0; i < _mockNotifications.length; i++) {
      final n = _mockNotifications[i];
      _mockNotifications[i] = NotificationModel(
        id: n.id,
        title: n.title,
        message: n.message,
        type: n.type,
        referenceId: n.referenceId,
        isRead: true,
        createdAt: n.createdAt,
      );
    }
  }
}
