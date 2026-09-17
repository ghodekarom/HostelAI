import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/ui_components.dart';
import '../../providers/role_provider.dart';

class PortalHomeScreen extends ConsumerWidget {
  const PortalHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Banner
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, Color(0xFF1E40AF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.auto_awesome, color: Colors.amberAccent, size: 14),
                              SizedBox(width: 6),
                              Text(
                                'SRS v1.1 Complete Multi-Persona Client',
                                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Hostel Facility Complaint Management System',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'AI-powered case triage, diagnostic checklists, SLA risk monitoring, and human-in-the-loop resolutions across all campus operational roles.',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            const SectionHeader(
              title: 'Operational Personas',
              subtitle: 'Select any role below to test its tailored workflow and UI controls',
            ),
            const SizedBox(height: 16),

            // 6-Role Grid
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth >= 1100 ? 3 : (constraints.maxWidth >= 700 ? 2 : 1);
                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.4,
                  children: [
                    _buildPortalCard(
                      context: context,
                      ref: ref,
                      role: UserRole.student,
                      title: 'Student Portal',
                      subtitle: 'File complaints with photos, track status timeline, respond to questions, & confirm resolution.',
                      icon: Icons.school_outlined,
                      color: AppColors.roleStudent,
                      route: '/student',
                    ),
                    _buildPortalCard(
                      context: context,
                      ref: ref,
                      role: UserRole.operator,
                      title: 'Operator Room',
                      subtitle: 'Review AI classification, inspect duplicate cases via pg_trgm, assign technicians, & propose resolutions.',
                      icon: Icons.support_agent_outlined,
                      color: AppColors.roleOperator,
                      route: '/operator',
                    ),
                    _buildPortalCard(
                      context: context,
                      ref: ref,
                      role: UserRole.technician,
                      title: 'Technician Console',
                      subtitle: 'View prioritized jobs, execute diagnostic checklists (INVESTIGATED), & log repair actions (ACTION_TAKEN).',
                      icon: Icons.handyman_outlined,
                      color: AppColors.roleTechnician,
                      route: '/technician',
                    ),
                    _buildPortalCard(
                      context: context,
                      ref: ref,
                      role: UserRole.teamLead,
                      title: 'Warden / Team Lead',
                      subtitle: 'Supervise AT_RISK complaints, review AI escalation draft briefs, boost priority, & reassign technicians.',
                      icon: Icons.supervisor_account_outlined,
                      color: AppColors.priorityCritical,
                      route: '/team-lead',
                    ),
                    _buildPortalCard(
                      context: context,
                      ref: ref,
                      role: UserRole.manager,
                      title: 'Manager Analytics',
                      subtitle: 'Monitor MTTR, MTTA, SLA compliance rate, chronic failure hotspots, & 90-day recurring problem clusters.',
                      icon: Icons.insights_outlined,
                      color: AppColors.verifiedGreen,
                      route: '/manager',
                    ),
                    _buildPortalCard(
                      context: context,
                      ref: ref,
                      role: UserRole.admin,
                      title: 'Admin Hub',
                      subtitle: 'Manage hostel infrastructure (Hostels, Blocks, Rooms), complaint categories with SLA, & maintenance teams.',
                      icon: Icons.admin_panel_settings_outlined,
                      color: AppColors.roleAdmin,
                      route: '/admin',
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 28),

            // Quick Stats Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  _statItem('14', 'Lifecycle Statuses', Icons.timeline, AppColors.primary),
                  _divider(),
                  _statItem('6', 'Operational Roles', Icons.badge_outlined, AppColors.roleOperator),
                  _divider(),
                  _statItem('100%', 'Human-Gated AI', Icons.verified_user_outlined, AppColors.verifiedGreen),
                  _divider(),
                  _statItem('pg_trgm', 'Trigram Search', Icons.search, AppColors.aiPurple),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPortalCard({
    required BuildContext context,
    required WidgetRef ref,
    required UserRole role,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    return InkWell(
      onTap: () {
        ref.read(roleProvider.notifier).setRole(role);
        context.go(route);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
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
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const Spacer(),
                Icon(Icons.arrow_forward_rounded, size: 16, color: color),
              ],
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.center,
              children: [
                Text(
                  value,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      height: 36,
      width: 1,
      color: AppColors.border,
      margin: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}
