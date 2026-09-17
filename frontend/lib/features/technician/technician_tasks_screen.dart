import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/priority_badge.dart';
import '../../core/widgets/ui_components.dart';
import '../../models/complaint_model.dart';
import '../../providers/technician_tasks_provider.dart';

class TechnicianTasksScreen extends ConsumerWidget {
  const TechnicianTasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(technicianTasksProvider);
    final dateFormat = DateFormat('MMM d, h:mm a');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: tasksAsync.when(
        loading: () => const LoadingView(message: 'Loading assigned work orders...'),
        error: (err, stack) => ErrorView(
          message: err.toString(),
          onRetry: () => ref.read(technicianTasksProvider.notifier).refresh(),
        ),
        data: (tasks) {
          return RefreshIndicator(
            onRefresh: () => ref.read(technicianTasksProvider.notifier).refresh(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24.0),
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
                            'Field Technician Console',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Execute diagnostic checklists, log repair actions, and record parts replaced',
                            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () => ref.read(technicianTasksProvider.notifier).refresh(),
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Refresh Tasks'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  if (tasks.isEmpty)
                    const EmptyStateView(
                      icon: Icons.done_all,
                      title: 'No pending tasks assigned',
                      subtitle: 'You currently have zero active work orders in your assigned queue.',
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: tasks.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return _buildTaskCard(context, task, dateFormat);
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

  Widget _buildTaskCard(BuildContext context, ComplaintModel task, DateFormat dateFormat) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: task.isAtRisk ? AppColors.priorityCritical : AppColors.border,
          width: task.isAtRisk ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                task.caseNumber,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.primary),
              ),
              const SizedBox(width: 8),
              StatusBadge(status: task.status, compact: true),
              if (task.priority != null) ...[
                const SizedBox(width: 8),
                PriorityBadge(priority: task.priority!),
              ],
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => context.go('/technician/complaints/${task.id}'),
                icon: const Icon(Icons.fact_check_outlined, size: 14),
                label: const Text('Checklist & Repair'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.roleTechnician,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            task.description,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.meeting_room_outlined, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(task.locationString, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Assigned: ${dateFormat.format(task.createdAt)}',
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
