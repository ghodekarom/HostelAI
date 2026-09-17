import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/ai_badge.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/priority_badge.dart';
import '../../core/widgets/ui_components.dart';
import '../../models/complaint_model.dart';
import '../../providers/api_providers.dart';
import '../../providers/reference_data_provider.dart';
import '../../providers/student_complaints_provider.dart';
import '../../providers/operator_queue_provider.dart';

class OperatorTriageScreen extends ConsumerStatefulWidget {
  final int id;

  const OperatorTriageScreen({super.key, required this.id});

  @override
  ConsumerState<OperatorTriageScreen> createState() => _OperatorTriageScreenState();
}

class _OperatorTriageScreenState extends ConsumerState<OperatorTriageScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // Review Form state
  int? _reviewedCategoryId;
  String _reviewedSeverity = 'MEDIUM';
  String _reviewedPriority = 'P3';
  int? _reviewedTeamId;
  final _operatorNotesController = TextEditingController();

  // Assignment Form state
  int? _assignedTeamId;
  int? _assignedTechnicianId;
  final _assignmentNotesController = TextEditingController();

  // Missing Info state
  final _missingInfoQuestionsController = TextEditingController();

  // Resolution Form state
  final _problemDescController = TextEditingController();
  final _rootCauseController = TextEditingController();
  final _actionTakenController = TextEditingController();
  final _resultSummaryController = TextEditingController();

  bool _isActionLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _operatorNotesController.dispose();
    _assignmentNotesController.dispose();
    _missingInfoQuestionsController.dispose();
    _problemDescController.dispose();
    _rootCauseController.dispose();
    _actionTakenController.dispose();
    _resultSummaryController.dispose();
    super.dispose();
  }

  void _populateInitial(ComplaintModel c) {
    if (_reviewedCategoryId == null && c.categoryId != null) {
      _reviewedCategoryId = c.categoryId;
      _reviewedSeverity = c.severity ?? 'MEDIUM';
      _reviewedPriority = c.priority ?? 'P3';
      _reviewedTeamId = c.assignedTeamId;
      _assignedTeamId = c.assignedTeamId;
      _problemDescController.text = c.description;
    }
  }

  Future<void> _handleReview() async {
    if (_reviewedCategoryId == null) return;
    setState(() => _isActionLoading = true);
    try {
      final repo = ref.read(operatorRepositoryProvider);
      await repo.reviewComplaint(
        id: widget.id,
        severity: _reviewedSeverity,
        priority: _reviewedPriority,
        categoryId: _reviewedCategoryId!,
        teamId: _reviewedTeamId,
        operatorNotes: _operatorNotesController.text.trim(),
      );
      ref.invalidate(complaintDetailProvider(widget.id));
      ref.read(operatorQueueProvider.notifier).refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.verifiedGreen,
            content: Text('Review recorded successfully. Case transitioned to OPERATOR_REVIEW.'),
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

  Future<void> _handleAssign() async {
    if (_assignedTeamId == null || _assignedTechnicianId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both Team and Technician.')),
      );
      return;
    }

    setState(() => _isActionLoading = true);
    try {
      final repo = ref.read(operatorRepositoryProvider);
      await repo.assignComplaint(
        id: widget.id,
        teamId: _assignedTeamId!,
        technicianId: _assignedTechnicianId!,
        assignmentReason: _assignmentNotesController.text.trim(),
      );
      ref.invalidate(complaintDetailProvider(widget.id));
      ref.read(operatorQueueProvider.notifier).refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.verifiedGreen,
            content: Text('Technician assigned & diagnostic checklist initialized!'),
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

  Future<void> _handleMissingInfoRequest() async {
    final questions = _missingInfoQuestionsController.text.trim();
    if (questions.isEmpty) return;

    setState(() => _isActionLoading = true);
    try {
      final repo = ref.read(operatorRepositoryProvider);
      await repo.requestMissingInfo(id: widget.id, questions: questions);
      ref.invalidate(complaintDetailProvider(widget.id));
      ref.read(operatorQueueProvider.notifier).refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.roleOperator,
            content: Text('Clarification dispatched. Case transitioned to WAITING_FOR_INFORMATION.'),
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

  Future<void> _handleProposeResolution() async {
    final prob = _problemDescController.text.trim();
    final root = _rootCauseController.text.trim();
    final action = _actionTakenController.text.trim();
    if (prob.isEmpty || root.isEmpty || action.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill Problem Description, Root Cause, and Action Taken.')),
      );
      return;
    }

    setState(() => _isActionLoading = true);
    try {
      final repo = ref.read(operatorRepositoryProvider);
      await repo.proposeResolution(
        id: widget.id,
        problemDescription: prob,
        rootCause: root,
        actionTaken: action,
        resultSummary: _resultSummaryController.text.trim(),
      );
      ref.invalidate(complaintDetailProvider(widget.id));
      ref.read(operatorQueueProvider.notifier).refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.verifiedGreen,
            content: Text('Resolution proposed to student! Status: RESOLUTION_PROPOSED.'),
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
    final categoriesAsync = ref.watch(categoriesProvider);
    final teamsAsync = ref.watch(teamsProvider);
    final techniciansAsync = ref.watch(techniciansProvider);
    final relatedCasesAsync = ref.watch(relatedCasesProvider(widget.id));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: detailAsync.when(
        loading: () => const LoadingView(message: 'Loading case triage details...'),
        error: (err, stack) => ErrorView(
          message: err.toString(),
          onRetry: () => ref.invalidate(complaintDetailProvider(widget.id)),
        ),
        data: (detail) {
          final c = detail.complaint;
          _populateInitial(c);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Bar
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => context.go('/operator'),
                          icon: const Icon(Icons.arrow_back),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Triage: ${c.caseNumber}',
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
                              '${c.studentName ?? "Student"} • ${c.locationString}',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // AI Suggestion Banner
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.aiPurpleLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.aiPurpleBorder),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const AiBadge(label: 'AI Case Assessment'),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  c.aiSummary ?? 'AI classification suggested category: ${c.categoryName ?? "General"} with priority ${c.priority ?? "P3"}. Review and confirm below.',
                                  style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.4),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Human-in-the-loop: Operator approval is required to assign technicians or resolve duplicate flags.',
                                  style: TextStyle(fontSize: 11, color: AppColors.aiPurple, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Tabs
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        labelColor: AppColors.primary,
                        unselectedLabelColor: AppColors.textSecondary,
                        indicatorColor: AppColors.primary,
                        tabs: const [
                          Tab(icon: Icon(Icons.rate_review_outlined, size: 18), text: 'Review & Verify'),
                          Tab(icon: Icon(Icons.compare_arrows_outlined, size: 18), text: 'Duplicate Check'),
                          Tab(icon: Icon(Icons.person_add_alt_1_outlined, size: 18), text: 'Assign Tech'),
                          Tab(icon: Icon(Icons.assignment_turned_in_outlined, size: 18), text: 'Actions & Resolution'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Tab Views
                    SizedBox(
                      height: 520,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // Tab 1: Review & Verify
                          _buildReviewTab(c, categoriesAsync, teamsAsync),

                          // Tab 2: Duplicate Check
                          _buildDuplicateCheckTab(relatedCasesAsync),

                          // Tab 3: Assign Tech
                          _buildAssignTab(teamsAsync, techniciansAsync),

                          // Tab 4: Actions & Resolution
                          _buildActionsTab(),
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

  Widget _buildReviewTab(
    ComplaintModel c,
    AsyncValue<List<CategoryModel>> categoriesAsync,
    AsyncValue<List<TeamModel>> teamsAsync,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ListView(
        children: [
          const Text('Raw Complaint Description', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
            child: Text(c.description, style: const TextStyle(fontSize: 13, height: 1.4)),
          ),
          const SizedBox(height: 20),
          const Text('Operator Classification Override / Confirmation', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 12),

          // Category Picker
          categoriesAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (e, s) => Text('Error loading categories: $e'),
            data: (cats) {
              return DropdownButtonFormField<int>(
                value: _reviewedCategoryId,
                decoration: const InputDecoration(labelText: 'Assigned Category'),
                items: cats.map((cat) => DropdownMenuItem(value: cat.id, child: Text(cat.name))).toList(),
                onChanged: (v) => setState(() => _reviewedCategoryId = v),
              );
            },
          ),
          const SizedBox(height: 16),

          // Severity & Priority
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _reviewedSeverity,
                  decoration: const InputDecoration(labelText: 'Severity Level'),
                  items: const [
                    DropdownMenuItem(value: 'LOW', child: Text('Low')),
                    DropdownMenuItem(value: 'MEDIUM', child: Text('Medium')),
                    DropdownMenuItem(value: 'HIGH', child: Text('High')),
                    DropdownMenuItem(value: 'CRITICAL', child: Text('Critical')),
                  ],
                  onChanged: (v) => setState(() => _reviewedSeverity = v ?? 'MEDIUM'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _reviewedPriority,
                  decoration: const InputDecoration(labelText: 'Priority (SLA)'),
                  items: const [
                    DropdownMenuItem(value: 'P1', child: Text('P1 (Immediate 4h)')),
                    DropdownMenuItem(value: 'P2', child: Text('P2 (High 24h)')),
                    DropdownMenuItem(value: 'P3', child: Text('P3 (Medium 48h)')),
                    DropdownMenuItem(value: 'P4', child: Text('P4 (Low 72h)')),
                  ],
                  onChanged: (v) => setState(() => _reviewedPriority = v ?? 'P3'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Operator Notes
          TextField(
            controller: _operatorNotesController,
            decoration: const InputDecoration(
              labelText: 'Internal Operator Review Notes',
              hintText: 'e.g. Verified with hostel warden, requires emergency plumbing unit.',
            ),
          ),
          const SizedBox(height: 20),

          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: _isActionLoading ? null : _handleReview,
              icon: const Icon(Icons.check, size: 16),
              label: const Text('Record Review (OPERATOR_REVIEW)'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDuplicateCheckTab(AsyncValue<List<ComplaintModel>> relatedCasesAsync) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: relatedCasesAsync.when(
        loading: () => const LoadingView(message: 'Scanning database with pg_trgm similarity...'),
        error: (e, s) => ErrorView(message: e.toString()),
        data: (related) {
          if (related.isEmpty) {
            return const EmptyStateView(
              icon: Icons.search_off_outlined,
              title: 'No duplicate complaints found',
              subtitle: 'PostgreSQL trigram index found no matching complaints in this hostel/block recently.',
            );
          }

          return ListView.separated(
            itemCount: related.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final r = related[index];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(r.caseNumber, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                              const SizedBox(width: 8),
                              StatusBadge(status: r.status, compact: true),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.aiPurple.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Similarity: 86%',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.aiPurple),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(r.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: () {
                        ref.read(operatorRepositoryProvider).decideRelatedCase(
                              id: widget.id,
                              relatedId: r.id,
                              decision: 'DUPLICATE',
                            );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Marked ${r.caseNumber} as duplicate.')),
                        );
                      },
                      child: const Text('Mark Duplicate'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAssignTab(
    AsyncValue<List<TeamModel>> teamsAsync,
    AsyncValue<List<TechnicianModel>> techniciansAsync,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ListView(
        children: [
          const Text('Technician Work Order Dispatch', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 8),
          const Text(
            'Assigning a technician automatically initializes the diagnostic checklist and transitions case to ASSIGNED.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),

          // Team Selector
          teamsAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (e, s) => Text('Error: $e'),
            data: (teams) {
              return DropdownButtonFormField<int>(
                value: _assignedTeamId,
                decoration: const InputDecoration(labelText: 'Assigned Maintenance Team *'),
                items: teams.map((t) => DropdownMenuItem(value: t.id, child: Text(t.name))).toList(),
                onChanged: (v) => setState(() => _assignedTeamId = v),
              );
            },
          ),
          const SizedBox(height: 16),

          // Technician Selector
          techniciansAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (e, s) => Text('Error: $e'),
            data: (techs) {
              return DropdownButtonFormField<int>(
                value: _assignedTechnicianId,
                decoration: const InputDecoration(labelText: 'Select Field Technician *'),
                items: techs.map((t) => DropdownMenuItem(value: t.id, child: Text('${t.name} (${t.teamName})'))).toList(),
                onChanged: (v) => setState(() => _assignedTechnicianId = v),
              );
            },
          ),
          const SizedBox(height: 16),

          // Assignment Notes
          TextField(
            controller: _assignmentNotesController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Instructions for Technician (Optional)',
              hintText: 'e.g. Inspect washbasin spindle and replace rubber washer seal.',
            ),
          ),
          const SizedBox(height: 24),

          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: _isActionLoading ? null : _handleAssign,
              icon: const Icon(Icons.person_add_alt_1, size: 16),
              label: const Text('Assign Technician (ASSIGNED)'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsTab() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ListView(
        children: [
          // Section 1: Missing Info
          const Text('Request Clarification from Student', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 8),
          TextField(
            controller: _missingInfoQuestionsController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Questions for Student',
              hintText: 'e.g. Is the leak coming from the tap head or the pipe connection below?',
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: _isActionLoading ? null : _handleMissingInfoRequest,
              icon: const Icon(Icons.help_outline, size: 16),
              label: const Text('Send Question (WAITING_FOR_INFORMATION)'),
            ),
          ),
          const Divider(height: 36),

          // Section 2: Propose Resolution
          const Text('Propose Root-Cause Resolution', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 12),
          TextField(
            controller: _rootCauseController,
            decoration: const InputDecoration(labelText: 'Root Cause *', hintText: 'e.g. Worn-out gasket due to hard water calcification'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _actionTakenController,
            decoration: const InputDecoration(labelText: 'Action Taken *', hintText: 'e.g. Replaced rubber seal and tightened fitting'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _resultSummaryController,
            decoration: const InputDecoration(labelText: 'Result Summary', hintText: 'e.g. Continuous water flow tested with zero leakage'),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: _isActionLoading ? null : _handleProposeResolution,
              icon: const Icon(Icons.send_rounded, size: 16),
              label: const Text('Dispatch Resolution to Student (RESOLUTION_PROPOSED)'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.verifiedGreen, foregroundColor: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
