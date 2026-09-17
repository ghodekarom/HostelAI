import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/ai_badge.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/priority_badge.dart';
import '../../core/widgets/ui_components.dart';
import '../../models/complaint_detail_model.dart';
import '../../providers/api_providers.dart';
import '../../providers/student_complaints_provider.dart';

class ComplaintDetailScreen extends ConsumerStatefulWidget {
  final int id;

  const ComplaintDetailScreen({super.key, required this.id});

  @override
  ConsumerState<ComplaintDetailScreen> createState() => _ComplaintDetailScreenState();
}

class _ComplaintDetailScreenState extends ConsumerState<ComplaintDetailScreen> {
  final _missingInfoResponseController = TextEditingController();
  final _rejectionFeedbackController = TextEditingController();
  bool _isActionInProgress = false;

  @override
  void dispose() {
    _missingInfoResponseController.dispose();
    _rejectionFeedbackController.dispose();
    super.dispose();
  }

  Future<void> _submitMissingInfoResponse() async {
    final text = _missingInfoResponseController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isActionInProgress = true);
    try {
      final repo = ref.read(complaintRepositoryProvider);
      await repo.respondMissingInfo(widget.id, text);
      ref.invalidate(complaintDetailProvider(widget.id));
      ref.read(myComplaintsProvider.notifier).refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.verifiedGreen,
            content: Text('Response submitted. Complaint returned to active status.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: AppColors.priorityCritical, content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isActionInProgress = false);
    }
  }

  Future<void> _handleResolutionDecision(String decision) async {
    setState(() => _isActionInProgress = true);
    try {
      final repo = ref.read(complaintRepositoryProvider);
      await repo.decideResolution(
        widget.id,
        decision,
        decision == 'REJECTED' ? _rejectionFeedbackController.text.trim() : null,
      );
      ref.invalidate(complaintDetailProvider(widget.id));
      ref.read(myComplaintsProvider.notifier).refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: decision == 'CONFIRMED' ? AppColors.verifiedGreen : AppColors.priorityHigh,
            content: Text(decision == 'CONFIRMED' ? 'Resolution confirmed and closed!' : 'Case reopened for further repair.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: AppColors.priorityCritical, content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isActionInProgress = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(complaintDetailProvider(widget.id));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: detailAsync.when(
        loading: () => const LoadingView(message: 'Fetching complaint history & timeline...'),
        error: (err, stack) => ErrorView(
          message: err.toString(),
          onRetry: () => ref.invalidate(complaintDetailProvider(widget.id)),
        ),
        data: (detail) {
          final c = detail.complaint;
          final dateFormat = DateFormat('MMM d, yyyy • h:mm a');

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Bar
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => context.go('/student'),
                          icon: const Icon(Icons.arrow_back),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  c.caseNumber,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                StatusBadge(status: c.status),
                                if (c.priority != null) ...[
                                  const SizedBox(width: 8),
                                  PriorityBadge(priority: c.priority!),
                                ],
                              ],
                            ),
                            Text(
                              'Filed on ${dateFormat.format(c.createdAt)}',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Missing Info Alert Box
                    if (c.status == 'WAITING_FOR_INFORMATION') ...[
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7ED),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFDBA74)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.help_outline, color: Color(0xFFC2410C)),
                                SizedBox(width: 8),
                                Text(
                                  'Action Required: Operator Requested Clarification',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: Color(0xFFC2410C),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'The maintenance operator requested additional details to proceed with assigning a technician.',
                              style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _missingInfoResponseController,
                              maxLines: 2,
                              decoration: const InputDecoration(
                                hintText: 'Enter clarification response here...',
                                fillColor: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton.icon(
                                onPressed: _isActionInProgress ? null : _submitMissingInfoResponse,
                                icon: const Icon(Icons.send, size: 16),
                                label: const Text('Submit Response'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFC2410C),
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Resolution Proposed Card
                    if (c.status == 'RESOLUTION_PROPOSED' && detail.resolution != null) ...[
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF86EFAC)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.verified, color: AppColors.verifiedGreen),
                                SizedBox(width: 8),
                                Text(
                                  'Repair Completed — Pending Student Confirmation',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: AppColors.verifiedGreen,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _detailRow('Root Cause:', detail.resolution!.rootCause),
                            const SizedBox(height: 6),
                            _detailRow('Action Taken:', detail.resolution!.actionTaken),
                            if (detail.resolution!.resultSummary != null) ...[
                              const SizedBox(height: 6),
                              _detailRow('Outcome:', detail.resolution!.resultSummary!),
                            ],
                            const SizedBox(height: 16),
                            const Text(
                              'Please verify the fix in your room. Confirm to close this case or reject to reopen it for further attention.',
                              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton(
                                  onPressed: _isActionInProgress
                                      ? null
                                      : () => _handleResolutionDecision('REJECTED'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.priorityCritical,
                                  ),
                                  child: const Text('Reject & Reopen Case'),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton.icon(
                                  onPressed: _isActionInProgress
                                      ? null
                                      : () => _handleResolutionDecision('CONFIRMED'),
                                  icon: const Icon(Icons.check_circle_outline, size: 18),
                                  label: const Text('Confirm Resolution & Close'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.verifiedGreen,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Overview Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Case Information',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 12),
                          _detailRow('Location:', c.locationString),
                          const SizedBox(height: 8),
                          _detailRow('Category:', '${c.categoryName ?? "General"} ${c.subcategory != null ? "• " + c.subcategory! : ""}'),
                          const SizedBox(height: 8),
                          _detailRow('Assigned Team:', c.assignedTeamName ?? 'Pending Operator Assignment'),
                          const SizedBox(height: 8),
                          _detailRow('Technician:', c.assignedTechnicianName ?? 'Unassigned'),
                          const Divider(height: 24),
                          const Text(
                            'Description:',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            c.description,
                            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.4),
                          ),
                          if (c.aiSummary != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.aiPurpleLight,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.aiPurpleBorder),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const AiBadge(label: 'AI Summary'),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      c.aiSummary!,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Audit Status History Timeline
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.history, size: 20, color: AppColors.primary),
                              SizedBox(width: 8),
                              Text(
                                'Audit Status Timeline',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (detail.statusHistory.isEmpty)
                            const Text('No status transitions recorded yet.')
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: detail.statusHistory.length,
                              itemBuilder: (context, index) {
                                final hist = detail.statusHistory[index];
                                final isLast = index == detail.statusHistory.length - 1;
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      children: [
                                        Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: isLast ? AppColors.primary : Colors.grey.shade400,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        if (!isLast)
                                          Container(
                                            width: 2,
                                            height: 44,
                                            color: Colors.grey.shade200,
                                          ),
                                      ],
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(bottom: 12.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                StatusBadge(status: hist.newStatus, compact: true),
                                                const SizedBox(width: 8),
                                                Text(
                                                  dateFormat.format(hist.createdAt),
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              hist.changeReason ?? 'Status updated by ${hist.changedByName ?? "System"}',
                                              style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
