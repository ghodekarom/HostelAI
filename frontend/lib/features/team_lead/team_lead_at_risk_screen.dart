import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/priority_badge.dart';
import '../../core/widgets/ui_components.dart';
import '../../models/complaint_model.dart';
import '../../providers/team_lead_provider.dart';

class TeamLeadAtRiskScreen extends ConsumerWidget {
  const TeamLeadAtRiskScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final atRiskAsync = ref.watch(teamLeadAtRiskProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: atRiskAsync.when(
        loading: () => const LoadingView(message: 'Loading at-risk complaints...'),
        error: (err, stack) => ErrorView(
          message: err.toString(),
          onRetry: () => ref.read(teamLeadAtRiskProvider.notifier).refresh(),
        ),
        data: (cases) {
          return RefreshIndicator(
            onRefresh: () => ref.read(teamLeadAtRiskProvider.notifier).refresh(),
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
                            'Hostel Warden & Team Lead Console',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Supervise at-risk complaints, prevent SLA breaches, and execute interventions',
                            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () => ref.read(teamLeadAtRiskProvider.notifier).refresh(),
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Refresh Queue'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // KPI Cards
                  Row(
                    children: [
                      _summaryCard('At-Risk Total', cases.length.toString(), Icons.warning_amber_rounded, AppColors.priorityCritical),
                      const SizedBox(width: 16),
                      _summaryCard('SLA Breached', cases.where((c) => c.status == 'AT_RISK').length.toString(), Icons.timer_off_outlined, AppColors.priorityHigh),
                      const SizedBox(width: 16),
                      _summaryCard('Intervention Ready', cases.length.toString(), Icons.bolt, AppColors.aiPurple),
                    ],
                  ),
                  const SizedBox(height: 28),

                  const SectionHeader(
                    title: 'At-Risk & Escalated Complaints',
                    subtitle: 'Cases requiring supervisory action, technician reassignment, or priority boost',
                  ),
                  const SizedBox(height: 16),

                  if (cases.isEmpty)
                    const EmptyStateView(
                      icon: Icons.verified_user_outlined,
                      title: 'Zero at-risk complaints',
                      subtitle: 'All hostel complaints are progressing well within their SLA targets.',
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: cases.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final c = cases[index];
                        return _buildAtRiskCard(context, c);
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

  Widget _summaryCard(String label, String value, IconData icon, Color color) {
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
                Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAtRiskCard(BuildContext context, ComplaintModel item) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.priorityCritical.withOpacity(0.6), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                item.caseNumber,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.primary),
              ),
              const SizedBox(width: 8),
              const StatusBadge(status: 'AT_RISK', compact: true),
              if (item.priority != null) ...[
                const SizedBox(width: 8),
                PriorityBadge(priority: item.priority!),
              ],
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => context.go('/team-lead/complaints/${item.id}'),
                icon: const Icon(Icons.bolt, size: 14),
                label: const Text('Supervisory Intervene'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.priorityCritical,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.description,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _tag(Icons.location_on_outlined, item.locationString),
              _tag(Icons.category_outlined, item.categoryName ?? 'General'),
              _tag(Icons.person_outline, item.assignedTechnicianName != null ? 'Tech: ${item.assignedTechnicianName}' : 'Unassigned Tech'),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.priorityCritical.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 13, color: AppColors.priorityCritical),
                    SizedBox(width: 4),
                    Text('SLA Target Breached', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.priorityCritical)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tag(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
