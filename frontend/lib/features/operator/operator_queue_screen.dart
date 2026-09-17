import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/priority_badge.dart';
import '../../core/widgets/ui_components.dart';
import '../../models/complaint_model.dart';
import '../../providers/operator_queue_provider.dart';

class OperatorQueueScreen extends ConsumerStatefulWidget {
  const OperatorQueueScreen({super.key});

  @override
  ConsumerState<OperatorQueueScreen> createState() => _OperatorQueueScreenState();
}

class _OperatorQueueScreenState extends ConsumerState<OperatorQueueScreen> {
  String _selectedFilter = 'ALL';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilter(String filter) {
    setState(() => _selectedFilter = filter);
    List<String>? statuses;
    if (filter == 'NEW') statuses = ['REPORTED', 'UNDERSTOOD'];
    if (filter == 'REVIEW') statuses = ['OPERATOR_REVIEW'];
    if (filter == 'WAITING_INFO') statuses = ['WAITING_FOR_INFORMATION'];
    if (filter == 'ASSIGNED') statuses = ['ASSIGNED', 'INVESTIGATED', 'ACTION_TAKEN'];
    if (filter == 'AT_RISK') statuses = ['AT_RISK'];
    ref.read(operatorQueueFilterProvider.notifier).state = statuses;
  }

  @override
  Widget build(BuildContext context) {
    final queueAsync = ref.watch(operatorQueueProvider);
    final dateFormat = DateFormat('MMM d, h:mm a');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: queueAsync.when(
        loading: () => const LoadingView(message: 'Loading operator triage queue...'),
        error: (err, stack) => ErrorView(
          message: err.toString(),
          onRetry: () => ref.read(operatorQueueProvider.notifier).refresh(),
        ),
        data: (queue) {
          final query = _searchController.text.trim().toLowerCase();
          final filteredList = queue.where((c) {
            if (query.isEmpty) return true;
            return c.caseNumber.toLowerCase().contains(query) ||
                (c.categoryName?.toLowerCase().contains(query) ?? false) ||
                (c.roomNumber?.toLowerCase().contains(query) ?? false) ||
                c.description.toLowerCase().contains(query);
          }).toList();

          return RefreshIndicator(
            onRefresh: () => ref.read(operatorQueueProvider.notifier).refresh(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Page Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Maintenance Operator Room',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Review AI triages, inspect duplicate cases, assign technicians, and propose resolutions',
                            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () => ref.read(operatorQueueProvider.notifier).refresh(),
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Refresh Queue'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Search Bar & Filters
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search, size: 20),
                            hintText: 'Search by case number, room number, category...',
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 18),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {});
                                    },
                                  )
                                : null,
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          children: [
                            _filterChip('ALL', 'All Cases (${queue.length})'),
                            _filterChip('NEW', 'New Intake'),
                            _filterChip('REVIEW', 'In Review'),
                            _filterChip('WAITING_INFO', 'Waiting Info'),
                            _filterChip('ASSIGNED', 'Assigned/Active'),
                            _filterChip('AT_RISK', 'At Risk ⚠️', isAlert: true),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Queue Table / Cards
                  if (filteredList.isEmpty)
                    const EmptyStateView(
                      icon: Icons.check_circle_outline,
                      title: 'Queue is clear',
                      subtitle: 'No complaints matching the selected filter criteria.',
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredList.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = filteredList[index];
                        return _buildQueueCard(context, item, dateFormat);
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

  Widget _filterChip(String filterKey, String label, {bool isAlert = false}) {
    final isSelected = _selectedFilter == filterKey;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => _applyFilter(filterKey),
      selectedColor: isAlert ? AppColors.priorityCritical.withOpacity(0.15) : AppColors.primary.withOpacity(0.12),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isAlert
            ? (isSelected ? AppColors.priorityCritical : Colors.red.shade800)
            : (isSelected ? AppColors.primary : AppColors.textSecondary),
      ),
    );
  }

  Widget _buildQueueCard(BuildContext context, ComplaintModel item, DateFormat dateFormat) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: item.isAtRisk
              ? AppColors.priorityCritical
              : (item.status == 'REPORTED' ? AppColors.primaryLight : AppColors.border),
          width: item.isAtRisk || item.status == 'REPORTED' ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Status Indicator
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.assignment, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),

          // Main Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      item.caseNumber,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    StatusBadge(status: item.status, compact: true),
                    if (item.priority != null) ...[
                      const SizedBox(width: 6),
                      PriorityBadge(priority: item.priority!),
                    ],
                    if (item.severity != null) ...[
                      const SizedBox(width: 6),
                      SeverityBadge(severity: item.severity!),
                    ],
                    const Spacer(),
                    Text(
                      dateFormat.format(item.createdAt),
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
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
                    if (item.assignedTechnicianName != null) ...[
                      const SizedBox(width: 16),
                      Icon(Icons.person_outline, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        'Tech: ${item.assignedTechnicianName}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Triage Button
          ElevatedButton.icon(
            onPressed: () => context.go('/operator/complaints/${item.id}'),
            icon: const Icon(Icons.open_in_new, size: 14),
            label: const Text('Triage & Assign'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              backgroundColor: AppColors.roleOperator,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
