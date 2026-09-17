import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/ai_badge.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/priority_badge.dart';
import '../../core/widgets/ui_components.dart';
import '../../models/team_lead_models.dart';
import '../../providers/reference_data_provider.dart';
import '../../providers/team_lead_provider.dart';

class TeamLeadInterventionScreen extends ConsumerStatefulWidget {
  final int id;

  const TeamLeadInterventionScreen({super.key, required this.id});

  @override
  ConsumerState<TeamLeadInterventionScreen> createState() => _TeamLeadInterventionScreenState();
}

class _TeamLeadInterventionScreenState extends ConsumerState<TeamLeadInterventionScreen> {
  String _selectedAction = 'BOOST_PRIORITY';
  int? _reassignTechId;
  String _boostPriority = 'P1';
  final _interventionNotesController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _interventionNotesController.dispose();
    super.dispose();
  }

  Future<void> _executeIntervention() async {
    final notes = _interventionNotesController.text.trim();
    if (notes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter intervention notes.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final req = InterventionRequest(
        action: _selectedAction,
        technicianId: _selectedAction == 'REASSIGN_TECHNICIAN' ? _reassignTechId : null,
        priority: _selectedAction == 'BOOST_PRIORITY' ? _boostPriority : null,
        notes: notes,
      );

      await ref.read(teamLeadAtRiskProvider.notifier).intervene(widget.id, req);
      ref.invalidate(teamLeadContextProvider(widget.id));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.verifiedGreen,
            content: Text('Supervisory intervention executed successfully!'),
          ),
        );
        context.go('/team-lead');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: AppColors.priorityCritical, content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final contextAsync = ref.watch(teamLeadContextProvider(widget.id));
    final techsAsync = ref.watch(techniciansProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: contextAsync.when(
        loading: () => const LoadingView(message: 'Loading at-risk diagnostic context...'),
        error: (err, stack) => ErrorView(
          message: err.toString(),
          onRetry: () => ref.invalidate(teamLeadContextProvider(widget.id)),
        ),
        data: (ctxData) {
          final c = ctxData.complaint;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Bar
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => context.go('/team-lead'),
                          icon: const Icon(Icons.arrow_back),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Intervene: ${c.caseNumber}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const StatusBadge(status: 'AT_RISK'),
                                if (c.priority != null) ...[
                                  const SizedBox(width: 8),
                                  PriorityBadge(priority: c.priority!),
                                ],
                              ],
                            ),
                            Text(
                              '${c.locationString} • Category: ${c.categoryName}',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Risk Summary Banner
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFCA5A5)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded, color: AppColors.priorityCritical),
                              const SizedBox(width: 8),
                              Text(
                                ctxData.slaStatus,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  color: AppColors.priorityCritical,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                'Affected: ~${ctxData.affectedStudentsCount} students',
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Text('Risk Reasons Triggered:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                          const SizedBox(height: 4),
                          ...ctxData.riskFactors.map(
                            (r) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.arrow_right, size: 16, color: AppColors.priorityCritical),
                                  Expanded(child: Text(r, style: const TextStyle(fontSize: 13))),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // AI Escalation Brief
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
                          const AiBadge(label: 'AI Escalation Brief'),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              ctxData.aiEscalationDraft,
                              style: const TextStyle(fontSize: 13, height: 1.4, color: AppColors.textPrimary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Supervisory Intervention Form
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Supervisory Intervention Action', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 6),
                          const Text(
                            'Select an intervention action to resolve the at-risk bottleneck and log a permanent audit record.',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 18),

                          DropdownButtonFormField<String>(
                            value: _selectedAction,
                            decoration: const InputDecoration(labelText: 'Action Type *'),
                            items: const [
                              DropdownMenuItem(value: 'BOOST_PRIORITY', child: Text('Boost Priority (Accelerate SLA Target)')),
                              DropdownMenuItem(value: 'REASSIGN_TECHNICIAN', child: Text('Reassign Technician (Workload Balancing)')),
                              DropdownMenuItem(value: 'ADD_RESOURCES', child: Text('Authorize Emergency Equipment / Personnel')),
                              DropdownMenuItem(value: 'ESCALATE', child: Text('Formally Escalate to Chief Warden / Manager')),
                            ],
                            onChanged: (v) => setState(() => _selectedAction = v ?? 'BOOST_PRIORITY'),
                          ),
                          const SizedBox(height: 16),

                          if (_selectedAction == 'BOOST_PRIORITY') ...[
                            DropdownButtonFormField<String>(
                              value: _boostPriority,
                              decoration: const InputDecoration(labelText: 'Select New Target Priority *'),
                              items: const [
                                DropdownMenuItem(value: 'P1', child: Text('P1 - Critical (Emergency SLA)')),
                                DropdownMenuItem(value: 'P2', child: Text('P2 - High (24-Hour SLA)')),
                              ],
                              onChanged: (v) => setState(() => _boostPriority = v ?? 'P1'),
                            ),
                            const SizedBox(height: 16),
                          ],

                          if (_selectedAction == 'REASSIGN_TECHNICIAN') ...[
                            techsAsync.when(
                              loading: () => const LinearProgressIndicator(),
                              error: (e, s) => Text('Error loading technicians: $e'),
                              data: (techs) {
                                return DropdownButtonFormField<int>(
                                  value: _reassignTechId,
                                  decoration: const InputDecoration(labelText: 'New Field Technician *'),
                                  items: techs.map((t) => DropdownMenuItem(value: t.id, child: Text('${t.name} (${t.teamName})'))).toList(),
                                  onChanged: (v) => setState(() => _reassignTechId = v),
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                          ],

                          TextField(
                            controller: _interventionNotesController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Supervisory Intervention Notes *',
                              hintText: 'e.g. Authorized secondary replacement parts from central store due to 24h inactivity.',
                            ),
                          ),
                          const SizedBox(height: 24),

                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : _executeIntervention,
                              icon: const Icon(Icons.bolt, size: 16),
                              label: const Text('Execute Intervention'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.priorityCritical,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
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
