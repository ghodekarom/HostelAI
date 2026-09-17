import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/ui_components.dart';
import '../../models/reference_data_models.dart';
import '../../providers/reference_data_provider.dart';
import '../../providers/student_complaints_provider.dart';

class ComplaintFilingScreen extends ConsumerStatefulWidget {
  const ComplaintFilingScreen({super.key});

  @override
  ConsumerState<ComplaintFilingScreen> createState() => _ComplaintFilingScreenState();
}

class _ComplaintFilingScreenState extends ConsumerState<ComplaintFilingScreen> {
  final _formKey = GlobalKey<FormState>();

  int? _selectedHostelId;
  int? _selectedBlockId;
  int? _selectedRoomId;
  int? _selectedCategoryId;
  String? _subcategory;
  String _severity = 'MEDIUM';
  String _priority = 'P3';
  final _descriptionController = TextEditingController();
  bool _hasAttachment = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedHostelId == null || _selectedBlockId == null || _selectedRoomId == null || _selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select Hostel, Block, Room, and Category.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final complaint = await ref.read(myComplaintsProvider.notifier).createComplaint(
            hostelId: _selectedHostelId!,
            blockId: _selectedBlockId!,
            roomId: _selectedRoomId!,
            categoryId: _selectedCategoryId!,
            subcategory: _subcategory,
            description: _descriptionController.text.trim(),
            severity: _severity,
            priority: _priority,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.verifiedGreen,
            content: Text('Complaint ${complaint.caseNumber} filed successfully!'),
          ),
        );
        context.go('/student');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.priorityCritical,
            content: Text('Submission error: $e'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hostelsAsync = ref.watch(hostelsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back & Title
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => context.go('/student'),
                        icon: const Icon(Icons.arrow_back),
                        tooltip: 'Back to Complaints',
                      ),
                      const SizedBox(width: 8),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Report Facility Complaint',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'AI will analyze category, priority, and assign maintenance teams automatically',
                            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Location Card
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
                          '1. Location Details',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 16),

                        // Hostel Dropdown
                        hostelsAsync.when(
                          loading: () => const LinearProgressIndicator(),
                          error: (e, s) => Text('Error loading hostels: $e'),
                          data: (hostels) {
                            return DropdownButtonFormField<int>(
                              value: _selectedHostelId,
                              decoration: const InputDecoration(labelText: 'Hostel Hall of Residence *'),
                              items: hostels.map((h) {
                                return DropdownMenuItem<int>(
                                  value: h.id,
                                  child: Text('${h.name} (${h.code})'),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  _selectedHostelId = val;
                                  _selectedBlockId = null;
                                  _selectedRoomId = null;
                                });
                              },
                              validator: (v) => v == null ? 'Please select a hostel' : null,
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        // Block & Room Row
                        if (_selectedHostelId != null) ...[
                          Row(
                            children: [
                              Expanded(
                                child: Consumer(
                                  builder: (context, ref, _) {
                                    final blocksAsync = ref.watch(blocksProvider(_selectedHostelId!));
                                    return blocksAsync.when(
                                      loading: () => const LinearProgressIndicator(),
                                      error: (e, s) => Text('Error: $e'),
                                      data: (blocks) {
                                        return DropdownButtonFormField<int>(
                                          value: _selectedBlockId,
                                          decoration: const InputDecoration(labelText: 'Block / Wing *'),
                                          items: blocks.map((b) {
                                            return DropdownMenuItem<int>(
                                              value: b.id,
                                              child: Text('${b.name} (${b.blockCode})'),
                                            );
                                          }).toList(),
                                          onChanged: (val) {
                                            setState(() {
                                              _selectedBlockId = val;
                                              _selectedRoomId = null;
                                            });
                                          },
                                          validator: (v) => v == null ? 'Select block' : null,
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _selectedBlockId != null
                                    ? Consumer(
                                        builder: (context, ref, _) {
                                          final roomsAsync = ref.watch(roomsProvider(_selectedBlockId!));
                                          return roomsAsync.when(
                                            loading: () => const LinearProgressIndicator(),
                                            error: (e, s) => Text('Error: $e'),
                                            data: (rooms) {
                                              return DropdownButtonFormField<int>(
                                                value: _selectedRoomId,
                                                decoration: const InputDecoration(labelText: 'Room Number *'),
                                                items: rooms.map((r) {
                                                  return DropdownMenuItem<int>(
                                                    value: r.id,
                                                    child: Text('Room ${r.roomNumber} (Floor ${r.floorNumber ?? 1})'),
                                                  );
                                                }).toList(),
                                                onChanged: (val) => setState(() => _selectedRoomId = val),
                                                validator: (v) => v == null ? 'Select room' : null,
                                              );
                                            },
                                          );
                                        },
                                      )
                                    : const SizedBox(),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Category & Issue Details
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
                          '2. Issue Classification',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 16),

                        // Category Dropdown
                        categoriesAsync.when(
                          loading: () => const LinearProgressIndicator(),
                          error: (e, s) => Text('Error loading categories: $e'),
                          data: (categories) {
                            return DropdownButtonFormField<int>(
                              value: _selectedCategoryId,
                              decoration: const InputDecoration(labelText: 'Complaint Category *'),
                              items: categories.map((c) {
                                return DropdownMenuItem<int>(
                                  value: c.id,
                                  child: Text('${c.name} (SLA: ${c.defaultSlaHours ?? 24}h)'),
                                );
                              }).toList(),
                              onChanged: (val) => setState(() => _selectedCategoryId = val),
                              validator: (v) => v == null ? 'Please select category' : null,
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        // Subcategory
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Subcategory / Component (Optional)',
                            hintText: 'e.g. Washbasin tap, Ceiling fan, LAN port',
                          ),
                          onChanged: (v) => _subcategory = v,
                        ),
                        const SizedBox(height: 16),

                        // Severity & Priority Pickers
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _severity,
                                decoration: const InputDecoration(labelText: 'Severity Level *'),
                                items: const [
                                  DropdownMenuItem(value: 'LOW', child: Text('Low (Minor nuisance)')),
                                  DropdownMenuItem(value: 'MEDIUM', child: Text('Medium (Functional impact)')),
                                  DropdownMenuItem(value: 'HIGH', child: Text('High (Severe outage/leak)')),
                                  DropdownMenuItem(value: 'CRITICAL', child: Text('Critical (Safety/Emergency)')),
                                ],
                                onChanged: (v) => setState(() => _severity = v ?? 'MEDIUM'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _priority,
                                decoration: const InputDecoration(labelText: 'Urgency Priority *'),
                                items: const [
                                  DropdownMenuItem(value: 'P1', child: Text('P1 - Critical (Immediate)')),
                                  DropdownMenuItem(value: 'P2', child: Text('P2 - High (Within 24h)')),
                                  DropdownMenuItem(value: 'P3', child: Text('P3 - Medium (Within 48h)')),
                                  DropdownMenuItem(value: 'P4', child: Text('P4 - Low (Within 72h)')),
                                ],
                                onChanged: (v) => setState(() => _priority = v ?? 'P3'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Description & Evidence
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
                          '3. Description & Evidence',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: 'Detailed Problem Description *',
                            hintText: 'Describe exactly what is broken, when it started, and where it is located...',
                            alignLabelWithHint: true,
                          ),
                          validator: (v) {
                            if (v == null || v.trim().length < 10) {
                              return 'Please provide a clear description (at least 10 characters)';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Photo attachment simulation
                        Row(
                          children: [
                            OutlinedButton.icon(
                              onPressed: () {
                                setState(() => _hasAttachment = !_hasAttachment);
                              },
                              icon: Icon(
                                _hasAttachment ? Icons.check_circle : Icons.camera_alt_outlined,
                                color: _hasAttachment ? AppColors.verifiedGreen : AppColors.primary,
                              ),
                              label: Text(_hasAttachment ? 'Evidence Attached' : 'Attach Photo/Evidence'),
                            ),
                            if (_hasAttachment) ...[
                              const SizedBox(width: 12),
                              const Chip(
                                avatar: Icon(Icons.image, size: 16),
                                label: Text('washbasin_leak.jpg (240 KB)'),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: _isSubmitting ? null : () => context.go('/student'),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _isSubmitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Submit Complaint'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
