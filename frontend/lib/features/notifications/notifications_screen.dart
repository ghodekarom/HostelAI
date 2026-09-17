import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/ui_components.dart';
import '../../models/notification_models.dart';
import '../../providers/notification_provider.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  bool _filterUnreadOnly = false;

  @override
  Widget build(BuildContext context) {
    final notifsAsync = ref.watch(notificationsProvider);
    final dateFormat = DateFormat('MMM d, h:mm a');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: notifsAsync.when(
        loading: () => const LoadingView(message: 'Loading notifications feed...'),
        error: (err, stack) => ErrorView(
          message: err.toString(),
          onRetry: () => ref.read(notificationsProvider.notifier).refresh(),
        ),
        data: (notifications) {
          final list = _filterUnreadOnly ? notifications.where((n) => !n.isRead).toList() : notifications;

          return RefreshIndicator(
            onRefresh: () => ref.read(notificationsProvider.notifier).refresh(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Notifications & Activity Feed',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Real-time alerts, action requests, assignments, and resolution proposals',
                                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                          FilterChip(
                            label: const Text('Unread Only'),
                            selected: _filterUnreadOnly,
                            onSelected: (val) => setState(() => _filterUnreadOnly = val),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      if (list.isEmpty)
                        const EmptyStateView(
                          icon: Icons.notifications_off_outlined,
                          title: 'No notifications',
                          subtitle: 'You are completely caught up on all complaint notifications.',
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: list.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final item = list[index];
                            return _buildNotificationItem(context, item, dateFormat);
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationItem(BuildContext context, NotificationModel item, DateFormat dateFormat) {
    IconData icon = Icons.notifications_outlined;
    Color color = AppColors.primary;

    if (item.type == 'ACTION_REQUIRED') {
      icon = Icons.help_outline;
      color = AppColors.priorityHigh;
    } else if (item.type == 'ASSIGNED') {
      icon = Icons.person_pin_outlined;
      color = AppColors.roleTechnician;
    } else if (item.type == 'RESOLUTION_PROPOSED') {
      icon = Icons.assignment_turned_in_outlined;
      color = AppColors.verifiedGreen;
    }

    return InkWell(
      onTap: () {
        if (!item.isRead) {
          ref.read(notificationsProvider.notifier).markAsRead(item.id);
        }
        if (item.referenceId != null) {
          context.go('/student/complaints/${item.referenceId}');
        }
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: item.isRead ? Colors.white : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: item.isRead ? AppColors.border : AppColors.primaryLight.withOpacity(0.5),
            width: item.isRead ? 1.0 : 1.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: item.isRead ? FontWeight.w600 : FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        dateFormat.format(item.createdAt),
                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.message,
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                  ),
                  if (item.referenceId != null) ...[
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Text('View Case Details', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward, size: 12, color: AppColors.primary),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
