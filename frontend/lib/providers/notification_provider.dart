import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_models.dart';
import 'api_providers.dart';

class NotificationNotifier extends AsyncNotifier<List<NotificationModel>> {
  @override
  Future<List<NotificationModel>> build() async {
    final repo = ref.watch(notificationRepositoryProvider);
    return repo.getNotifications();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(notificationRepositoryProvider);
      return repo.getNotifications();
    });
  }

  Future<void> markAsRead(int id) async {
    final repo = ref.read(notificationRepositoryProvider);
    await repo.markAsRead(id);
    await refresh();
  }
}

final notificationsProvider = AsyncNotifierProvider<NotificationNotifier, List<NotificationModel>>(() {
  return NotificationNotifier();
});

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notifsAsync = ref.watch(notificationsProvider);
  return notifsAsync.maybeWhen(
    data: (list) => list.where((n) => !n.isRead).length,
    orElse: () => 0,
  );
});
