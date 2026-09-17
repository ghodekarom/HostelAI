import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/ui_components.dart';
import '../../models/analytics_models.dart';
import '../../providers/analytics_provider.dart';

class ManagerAnalyticsScreen extends ConsumerWidget {
  const ManagerAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(analyticsSummaryProvider);
    final hotspotsAsync = ref.watch(hotspotsProvider);
    final recurringAsync = ref.watch(recurringIssuesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Header
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chief Warden & Manager Analytics',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Executive operational intelligence, resolution benchmarks, hotspots, & recurring problem clustering',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Summary KPI Cards
            summaryAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, s) => Text('Error loading analytics: $e'),
              data: (summary) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 900;
                    return GridView.count(
                      crossAxisCount: isWide ? 4 : 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.7,
                      children: [
                        _metricCard('Total Complaints', summary.totalComplaints.toString(), Icons.folder_open, AppColors.primary),
                        _metricCard('Active Complaints', summary.activeComplaints.toString(), Icons.pending_actions, AppColors.roleOperator),
                        _metricCard('MTTR (Mean Time to Resolve)', '${summary.averageMttrHours} hrs', Icons.timer_outlined, AppColors.roleTechnician),
                        _metricCard('SLA Compliance Rate', '${summary.slaComplianceRate}%', Icons.verified_outlined, AppColors.verifiedGreen),
                      ],
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 28),

            // Hotspots & Chronic Failures
            const SectionHeader(
              title: 'Infrastructure Failure Hotspots',
              subtitle: 'Identified clusters with recurring complaints by block and floor',
            ),
            const SizedBox(height: 16),

            hotspotsAsync.when(
              loading: () => const LoadingView(),
              error: (e, s) => ErrorView(message: e.toString()),
              data: (hotspots) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: hotspots.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final h = hotspots[index];
                      Color levelColor = AppColors.priorityLow;
                      if (h.riskLevel == 'HIGH') levelColor = AppColors.priorityHigh;
                      if (h.riskLevel == 'CRITICAL') levelColor = AppColors.priorityCritical;

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: levelColor.withOpacity(0.12),
                          child: Icon(Icons.location_on, color: levelColor, size: 20),
                        ),
                        title: Text(h.location, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                        subtitle: Text('Category: ${h.categoryName} • ${h.complaintCount} incidents in 30 days'),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: levelColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: levelColor.withOpacity(0.3)),
                          ),
                          child: Text(
                            'Risk: ${h.riskLevel}',
                            style: TextStyle(color: levelColor, fontWeight: FontWeight.w700, fontSize: 11),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 28),

            // 90-Day Recurring Problem Clustering
            const SectionHeader(
              title: '90-Day Recurring Issue Clusters',
              subtitle: 'Semantic clustering identifying systemic infrastructure flaws',
            ),
            const SizedBox(height: 16),

            recurringAsync.when(
              loading: () => const LoadingView(),
              error: (e, s) => ErrorView(message: e.toString()),
              data: (issues) {
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: issues.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = issues[index];
                    return Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                item.issueTitle,
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.primary),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${item.occurrences} Cases Clustered',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text('Location: ${item.locationCluster}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.analytics_outlined, size: 16, color: AppColors.aiPurple),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Root Cause Analysis: ${item.primaryRootCause}',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricCard(String label, String value, IconData icon, Color color) {
    return Container(
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
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
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
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
