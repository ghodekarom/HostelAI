class NotificationModel {
  final int id;
  final int? userId;
  final String title;
  final String message;
  final String type;
  final int? referenceId;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.referenceId,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] is num ? (json['id'] as num).toInt() : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      userId: json['userId'] != null ? (json['userId'] as num).toInt() : null,
      title: json['title']?.toString() ?? 'Notification',
      message: json['message']?.toString() ?? '',
      type: json['type']?.toString() ?? 'SYSTEM',
      referenceId: json['referenceId'] != null ? (json['referenceId'] as num).toInt() : null,
      isRead: json['isRead'] == true,
      createdAt: json['createdAt'] != null
          ? (DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now())
          : DateTime.now(),
    );
  }
}
