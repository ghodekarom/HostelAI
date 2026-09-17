import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/priority_badge.dart';
import '../../core/widgets/ui_components.dart';
import '../../models/complaint_model.dart';
import '../../providers/student_complaints_provider.dart';

class StudentDashboardScreen extends ConsumerWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final complaintsAsync = ref.watch(myComplaintsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: complaintsAsync.when(
        loading: () => const LoadingView(message: 'Loading complaints...'),
        error: (err, stack) => ErrorView(
          message: err.toString(),
          onRetry: () => ref.read(myComplaintsProvider.notifier).refresh(),
        ),
        data: (complaints) {
          final activeCount = complaints.where((c) => c.status != 'CLOSED').length;
          final waitingInfoCount = complaints.where((c) => c.status == 'WAITING_FOR_INFORMATION').length;
          final resolvedCount = complaints.where((c) => c.status == 'CLOSED').length;

          return RefreshIndicator(
            onRefresh: () => ref.read(myComplaintsProvider.notifier).refresh(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row with Filing Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'My Complaints',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Track facility issues, view updates, and verify repairs',
                            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () => context.go('/student/new'),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('File Complaint'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // KPI Cards
                  Row(
                    children: [
                      _kpiCard('Active Cases', activeCount.toString(), Icons.pending_actions, AppColors.roleStudent),
                      const SizedBox(width: 16),
                      _kpiCard('Needs My Info', waitingInfoCount.toString(), Icons.notification_important, AppColors.priorityHigh),
                      const SizedBox(width: 16),
                      _kpiCard('Resolved', resolvedCount.toString(), Icons.task_alt, AppColors.verifiedGreen),
                    ],
                  ),
                  const SizedBox(height: 28),

                  const SectionHeader(
                    title: 'Complaint History',
                    subtitle: 'Select any case to view real-time audit timeline and actions',
                  ),
                  const SizedBox(height: 16),

                  if (complaints.isEmpty)
                    EmptyStateView(
                      icon: Icons.assignment_outlined,
                      title: 'No complaints filed yet',
                      subtitle: 'If you have an issue with plumbing, electricity, internet or furniture, report it below.',
                      action: ElevatedButton.icon(
                        onPressed: () => context.go('/student/new'),
                        icon: const Icon(Icons.add),
                        label: const Text('Report New Complaint'),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: complaints.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = complaints[index];
                        return _buildComplaintCard(context, item);
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _kpiCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComplaintCard(BuildContext context, ComplaintModel item) {
    return InkWell(
      onTap: () => context.go('/student/complaints/${item.id}'),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: item.status == 'WAITING_FOR_INFORMATION'
                ? AppColors.priorityHigh
                : (item.isAtRisk ? AppColors.priorityCritical : AppColors.border),
            width: item.status == 'WAITING_FOR_INFORMATION' || item.isAtRisk ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  item.caseNumber,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                StatusBadge(status: item.status, compact: true),
                const Spacer(),
                if (item.priority != null) PriorityBadge(priority: item.priority!),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              item.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  item.locationString,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(width: 16),
                Icon(Icons.category_outlined, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  item.categoryName ?? 'General',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const Spacer(),
                const Text(
                  'Details',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const Icon(Icons.chevron_right, size: 16, color: AppColors.primary),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
