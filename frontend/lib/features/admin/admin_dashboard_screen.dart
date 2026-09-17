import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/ui_components.dart';
import '../../models/reference_data_models.dart';
import '../../providers/api_providers.dart';
import '../../providers/reference_data_provider.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _showAddCategoryDialog() async {
    final nameCtrl = TextEditingController();
    final codeCtrl = TextEditingController();
    final slaCtrl = TextEditingController(text: '24');

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Complaint Category', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Category Name *')),
              const SizedBox(height: 12),
              TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: 'Code (e.g. HVAC) *')),
              const SizedBox(height: 12),
              TextField(controller: slaCtrl, decoration: const InputDecoration(labelText: 'Default SLA (Hours) *'), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.isEmpty || codeCtrl.text.isEmpty) return;
              Navigator.pop(ctx);
              await ref.read(referenceDataRepositoryProvider).createCategory(
                    nameCtrl.text.trim(),
                    codeCtrl.text.trim().toUpperCase(),
                    null,
                    int.tryParse(slaCtrl.text) ?? 24,
                  );
              ref.invalidate(categoriesProvider);
            },
            child: const Text('Create Category'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddHostelDialog() async {
    final nameCtrl = TextEditingController();
    final codeCtrl = TextEditingController();
    final blocksCtrl = TextEditingController(text: '3');

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Hostel Residence', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Hostel Name *')),
              const SizedBox(height: 12),
              TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: 'Hostel Code *')),
              const SizedBox(height: 12),
              TextField(controller: blocksCtrl, decoration: const InputDecoration(labelText: 'Total Blocks'), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.isEmpty || codeCtrl.text.isEmpty) return;
              Navigator.pop(ctx);
              await ref.read(referenceDataRepositoryProvider).createHostel(
                    nameCtrl.text.trim(),
                    codeCtrl.text.trim().toUpperCase(),
                    int.tryParse(blocksCtrl.text),
                  );
              ref.invalidate(hostelsProvider);
            },
            child: const Text('Create Hostel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hostelsAsync = ref.watch(hostelsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final teamsAsync = ref.watch(teamsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Administrative Control Hub',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Manage campus buildings, complaint categories, and maintenance teams',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
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
                labelColor: AppColors.roleAdmin,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.roleAdmin,
                tabs: const [
                  Tab(icon: Icon(Icons.apartment, size: 18), text: 'Hostel Infrastructure'),
                  Tab(icon: Icon(Icons.category, size: 18), text: 'Complaint Categories'),
                  Tab(icon: Icon(Icons.groups, size: 18), text: 'Maintenance Teams'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              height: 520,
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Hostels
                  _buildHostelsTab(hostelsAsync),

                  // Tab 2: Categories
                  _buildCategoriesTab(categoriesAsync),

                  // Tab 3: Teams
                  _buildTeamsTab(teamsAsync),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHostelsTab(AsyncValue<List<HostelModel>> hostelsAsync) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Campus Halls of Residence', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ElevatedButton.icon(
                onPressed: _showAddHostelDialog,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Hostel'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.roleAdmin),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: hostelsAsync.when(
              loading: () => const LoadingView(),
              error: (e, s) => ErrorView(message: e.toString()),
              data: (hostels) {
                return ListView.separated(
                  itemCount: hostels.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final h = hostels[index];
                    return ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFFAF5FF),
                        child: Icon(Icons.apartment, color: AppColors.roleAdmin),
                      ),
                      title: Text(h.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text('Code: ${h.code} • Blocks: ${h.totalBlocks ?? "Multiple"}'),
                      trailing: const Icon(Icons.chevron_right),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesTab(AsyncValue<List<CategoryModel>> categoriesAsync) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Active Complaint Categories', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ElevatedButton.icon(
                onPressed: _showAddCategoryDialog,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Category'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.roleAdmin),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: categoriesAsync.when(
              loading: () => const LoadingView(),
              error: (e, s) => ErrorView(message: e.toString()),
              data: (categories) {
                return ListView.separated(
                  itemCount: categories.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final c = categories[index];
                    return ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFF0FDF4),
                        child: Icon(Icons.category, color: AppColors.verifiedGreen),
                      ),
                      title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text('Code: ${c.code} • Target SLA: ${c.defaultSlaHours ?? 24} hours'),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.verifiedGreenLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('ACTIVE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.verifiedGreen)),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamsTab(AsyncValue<List<TeamModel>> teamsAsync) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Maintenance Field Teams', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          Expanded(
            child: teamsAsync.when(
              loading: () => const LoadingView(),
              error: (e, s) => ErrorView(message: e.toString()),
              data: (teams) {
                return ListView.separated(
                  itemCount: teams.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final t = teams[index];
                    return ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFEFF6FF),
                        child: Icon(Icons.groups, color: AppColors.primary),
                      ),
                      title: Text(t.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text('Code: ${t.code}'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
