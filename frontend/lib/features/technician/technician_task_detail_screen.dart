import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/priority_badge.dart';
import '../../core/widgets/ui_components.dart';
import '../../models/checklist_model.dart';
import '../../providers/api_providers.dart';
import '../../providers/student_complaints_provider.dart';
import '../../providers/technician_tasks_provider.dart';

class TechnicianTaskDetailScreen extends ConsumerStatefulWidget {
  final int id;

  const TechnicianTaskDetailScreen({super.key, required this.id});

  @override
  ConsumerState<TechnicianTaskDetailScreen> createState() => _TechnicianTaskDetailScreenState();
}

class _TechnicianTaskDetailScreenState extends ConsumerState<TechnicianTaskDetailScreen> {
  final _repairActionController = TextEditingController();
  final _partsReplacedController = TextEditingController();
  final _repairNotesController = TextEditingController();
  bool _isActionLoading = false;

  @override
  void dispose() {
    _repairActionController.dispose();
    _partsReplacedController.dispose();
    _repairNotesController.dispose();
    super.dispose();
  }

  Future<void> _showFindingDialog(ChecklistItemModel item) async {
    final findingController = TextEditingController(text: item.findingNotes ?? '');
    String status = item.status == 'PENDING' ? 'COMPLETED' : item.status;

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Record Checklist Finding', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              content: SizedBox(
                width: 450,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.itemDescription,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.primary),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: status,
                      decoration: const InputDecoration(labelText: 'Inspection Result'),
                      items: const [
                        DropdownMenuItem(value: 'COMPLETED', child: Text('Verified / Completed')),
                        DropdownMenuItem(value: 'ISSUE_CONFIRMED', child: Text('Issue Confirmed')),
                        DropdownMenuItem(value: 'NO_ISSUE_FOUND', child: Text('No Issue Found')),
                      ],
                      onChanged: (v) => setDialogState(() => status = v ?? 'COMPLETED'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: findingController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Diagnostic Observation / Finding Notes *',
                        hintText: 'e.g. Lime scale calcification inside spindle; rubber seal disintegrated.',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () async {
                    if (findingController.text.trim().isEmpty) return;
                    Navigator.pop(ctx);
                    await _recordFinding(item.id, findingController.text.trim(), status);
                  },
                  child: const Text('Save Finding (INVESTIGATED)'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _recordFinding(int itemId, String notes, String status) async {
    setState(() => _isActionLoading = true);
    try {
      final repo = ref.read(technicianRepositoryProvider);
      await repo.recordFinding(
        complaintId: widget.id,
        itemId: itemId,
        findingNotes: notes,
        status: status,
      );
      ref.invalidate(checklistProvider(widget.id));
      ref.invalidate(complaintDetailProvider(widget.id));
      ref.read(technicianTasksProvider.notifier).refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.verifiedGreen,
            content: Text('Finding recorded! Complaint updated to INVESTIGATED.'),
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
      if (mounted) setState(() => _isActionLoading = false);
    }
  }

  Future<void> _submitRepairAction() async {
    final action = _repairActionController.text.trim();
    if (action.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe the repair action taken.')),
      );
      return;
    }

    setState(() => _isActionLoading = true);
    try {
      await ref.read(technicianTasksProvider.notifier).logRepair(
            widget.id,
            actionDescription: action,
            partsReplaced: _partsReplacedController.text.trim(),
            notes: _repairNotesController.text.trim(),
          );
      ref.invalidate(complaintDetailProvider(widget.id));
      ref.invalidate(checklistProvider(widget.id));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.verifiedGreen,
            content: Text('Repair work logged! Status updated to ACTION_TAKEN.'),
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
      if (mounted) setState(() => _isActionLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(complaintDetailProvider(widget.id));
    final checklistAsync = ref.watch(checklistProvider(widget.id));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: detailAsync.when(
        loading: () => const LoadingView(message: 'Loading work order details...'),
        error: (err, stack) => ErrorView(
          message: err.toString(),
          onRetry: () => ref.invalidate(complaintDetailProvider(widget.id)),
        ),
        data: (detail) {
          final c = detail.complaint;

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
                          onPressed: () => context.go('/technician'),
                          icon: const Icon(Icons.arrow_back),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Work Order: ${c.caseNumber}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
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
                              '${c.locationString} • Assigned Tech: ${c.assignedTechnicianName ?? "Suresh Kumar"}',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Problem Summary Card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Reported Fault', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                          const SizedBox(height: 6),
                          Text(c.description, style: const TextStyle(fontSize: 13, height: 1.4)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Diagnostic Checklist Card
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
                              Icon(Icons.checklist_rounded, color: AppColors.roleTechnician),
                              SizedBox(width: 8),
                              Text(
                                'Diagnostic Inspection Checklist',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Complete diagnostic checkpoints before logging repair actions. Each finding records an immutable audit record.',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 16),

                          checklistAsync.when(
                            loading: () => const LinearProgressIndicator(),
                            error: (e, s) => Text('Error loading checklist: $e'),
                            data: (checklist) {
                              if (checklist.items.isEmpty) {
                                return const Text('No checklist items defined.');
                              }

                              return ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: checklist.items.length,
                                separatorBuilder: (context, index) => const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  final item = checklist.items[index];
                                  final isDone = item.status == 'COMPLETED';

                                  return Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isDone ? const Color(0xFFF0FDF4) : AppColors.background,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isDone ? const Color(0xFF86EFAC) : AppColors.border,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                                          color: isDone ? AppColors.verifiedGreen : Colors.grey,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.itemDescription,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13,
                                                  color: isDone ? AppColors.verifiedGreen : AppColors.textPrimary,
                                                ),
                                              ),
                                              if (item.findingNotes != null) ...[
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Finding: ${item.findingNotes}',
                                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        OutlinedButton(
                                          onPressed: _isActionLoading ? null : () => _showFindingDialog(item),
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          ),
                                          child: Text(isDone ? 'Edit Note' : 'Log Finding'),
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
                    const SizedBox(height: 20),

                    // Log Completed Repair Action Card
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
                              Icon(Icons.build_circle_outlined, color: AppColors.primary),
                              SizedBox(width: 8),
                              Text(
                                'Log Completed Repair Work',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _repairActionController,
                            maxLines: 2,
                            decoration: const InputDecoration(
                              labelText: 'Corrective Action Taken *',
                              hintText: 'e.g. Replaced rubber washer seal with 1/2-inch high pressure gasket.',
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _partsReplacedController,
                            decoration: const InputDecoration(
                              labelText: 'Parts Replaced / Materials Consumed',
                              hintText: 'e.g. 1x Rubber Washer (Part #PW-102), 1x Teflon Tape',
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _repairNotesController,
                            decoration: const InputDecoration(
                              labelText: 'Additional Notes / Evidence File URL',
                              hintText: 'e.g. post_repair_test.jpg',
                            ),
                          ),
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              onPressed: _isActionLoading ? null : _submitRepairAction,
                              icon: const Icon(Icons.task_alt, size: 16),
                              label: const Text('Log Repair Work (ACTION_TAKEN)'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.roleTechnician,
                                foregroundColor: Colors.white,
                              ),
                            ),
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
}
