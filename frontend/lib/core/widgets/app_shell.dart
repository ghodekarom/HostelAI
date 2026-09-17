import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../../providers/role_provider.dart';
import '../../providers/notification_provider.dart';

class AppShell extends ConsumerWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeRole = ref.watch(roleProvider);
    final unreadCount = ref.watch(unreadNotificationsCountProvider);
    final isWide = MediaQuery.of(context).size.width >= 900;
    final currentRoute = GoRouterState.of(context).uri.path;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          if (isWide) _buildSidebar(context, ref, activeRole, currentRoute),
          Expanded(
            child: Column(
              children: [
                _buildHeader(context, ref, activeRole, unreadCount, isWide),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: !isWide
          ? _buildBottomNav(context, currentRoute)
          : null,
    );
  }

  Widget _buildSidebar(
    BuildContext context,
    WidgetRef ref,
    UserRole activeRole,
    String currentRoute,
  ) {
    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand Header
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.apartment_rounded, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'HFCMS',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          letterSpacing: 0.5,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'AI Case Manager',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.aiPurple,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // Navigation Links
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _navItem(
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard,
                  label: 'Portal Home',
                  route: '/',
                  currentRoute: currentRoute,
                  onTap: () => context.go('/'),
                ),
                const SizedBox(height: 14),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Text(
                    'OPERATIONAL ROLES',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 1),
                  ),
                ),
                _navItem(
                  icon: Icons.school_outlined,
                  activeIcon: Icons.school,
                  label: 'Student Portal',
                  route: '/student',
                  currentRoute: currentRoute,
                  badgeColor: AppColors.roleStudent,
                  onTap: () {
                    ref.read(roleProvider.notifier).setRole(UserRole.student);
                    context.go('/student');
                  },
                ),
                _navItem(
                  icon: Icons.support_agent_outlined,
                  activeIcon: Icons.support_agent,
                  label: 'Operator Room',
                  route: '/operator',
                  currentRoute: currentRoute,
                  badgeColor: AppColors.roleOperator,
                  onTap: () {
                    ref.read(roleProvider.notifier).setRole(UserRole.operator);
                    context.go('/operator');
                  },
                ),
                _navItem(
                  icon: Icons.handyman_outlined,
                  activeIcon: Icons.handyman,
                  label: 'Technician Console',
                  route: '/technician',
                  currentRoute: currentRoute,
                  badgeColor: AppColors.roleTechnician,
                  onTap: () {
                    ref.read(roleProvider.notifier).setRole(UserRole.technician);
                    context.go('/technician');
                  },
                ),
                _navItem(
                  icon: Icons.supervisor_account_outlined,
                  activeIcon: Icons.supervisor_account,
                  label: 'Warden / Team Lead',
                  route: '/team-lead',
                  currentRoute: currentRoute,
                  badgeColor: AppColors.priorityCritical,
                  onTap: () {
                    ref.read(roleProvider.notifier).setRole(UserRole.teamLead);
                    context.go('/team-lead');
                  },
                ),
                _navItem(
                  icon: Icons.insights_outlined,
                  activeIcon: Icons.insights,
                  label: 'Manager Analytics',
                  route: '/manager',
                  currentRoute: currentRoute,
                  badgeColor: AppColors.verifiedGreen,
                  onTap: () {
                    ref.read(roleProvider.notifier).setRole(UserRole.manager);
                    context.go('/manager');
                  },
                ),
                _navItem(
                  icon: Icons.admin_panel_settings_outlined,
                  activeIcon: Icons.admin_panel_settings,
                  label: 'Admin Hub',
                  route: '/admin',
                  currentRoute: currentRoute,
                  badgeColor: AppColors.roleAdmin,
                  onTap: () {
                    ref.read(roleProvider.notifier).setRole(UserRole.admin);
                    context.go('/admin');
                  },
                ),
                const SizedBox(height: 14),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Text(
                    'SYSTEM',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 1),
                  ),
                ),
                _navItem(
                  icon: Icons.notifications_outlined,
                  activeIcon: Icons.notifications,
                  label: 'Notifications',
                  route: '/notifications',
                  currentRoute: currentRoute,
                  onTap: () => context.go('/notifications'),
                ),
                _navItem(
                  icon: Icons.lock_outline,
                  activeIcon: Icons.lock,
                  label: 'Authentication',
                  route: '/login',
                  currentRoute: currentRoute,
                  onTap: () => context.go('/login'),
                ),
              ],
            ),
          ),

          // Active Role Footer
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: _roleColor(activeRole).withOpacity(0.15),
                    child: Icon(_roleIcon(activeRole), size: 16, color: _roleColor(activeRole)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Simulated Persona', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                        Text(
                          activeRole.displayName,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    UserRole activeRole,
    int unreadCount,
    bool isWide,
  ) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          if (!isWide) ...[
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.apartment, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Text('HFCMS', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          ],
          const Spacer(),

          // API Status Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.verifiedGreenLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.verifiedGreen.withOpacity(0.3)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, color: AppColors.verifiedGreen, size: 8),
                SizedBox(width: 6),
                Text(
                  'API Live',
                  style: TextStyle(color: AppColors.verifiedGreen, fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Role Switcher Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _roleColor(activeRole).withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _roleColor(activeRole).withOpacity(0.3)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<UserRole>(
                value: activeRole,
                isDense: true,
                icon: Icon(Icons.arrow_drop_down, color: _roleColor(activeRole)),
                style: TextStyle(color: _roleColor(activeRole), fontSize: 12, fontWeight: FontWeight.w700),
                items: UserRole.values.map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Text('Role: ${role.displayName}'),
                  );
                }).toList(),
                onChanged: (newRole) {
                  if (newRole != null) {
                    ref.read(roleProvider.notifier).setRole(newRole);
                    switch (newRole) {
                      case UserRole.student:
                        context.go('/student');
                        break;
                      case UserRole.operator:
                        context.go('/operator');
                        break;
                      case UserRole.technician:
                        context.go('/technician');
                        break;
                      case UserRole.teamLead:
                        context.go('/team-lead');
                        break;
                      case UserRole.manager:
                        context.go('/manager');
                        break;
                      case UserRole.admin:
                        context.go('/admin');
                        break;
                    }
                  }
                },
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Notification Bell with Badge
          IconButton(
            onPressed: () => context.go('/notifications'),
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_outlined, size: 22, color: AppColors.textSecondary),
                if (unreadCount > 0)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.priorityCritical,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        unreadCount.toString(),
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, String currentRoute) {
    int selectedIndex = 0;
    if (currentRoute.startsWith('/student')) selectedIndex = 1;
    if (currentRoute.startsWith('/operator')) selectedIndex = 2;
    if (currentRoute.startsWith('/technician')) selectedIndex = 3;
    if (currentRoute.startsWith('/team-lead')) selectedIndex = 4;
    if (currentRoute.startsWith('/manager')) selectedIndex = 5;

    return NavigationBar(
      selectedIndex: selectedIndex,
      backgroundColor: Colors.white,
      elevation: 4,
      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            context.go('/');
            break;
          case 1:
            context.go('/student');
            break;
          case 2:
            context.go('/operator');
            break;
          case 3:
            context.go('/technician');
            break;
          case 4:
            context.go('/team-lead');
            break;
          case 5:
            context.go('/manager');
            break;
        }
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.school_outlined), label: 'Student'),
        NavigationDestination(icon: Icon(Icons.support_agent_outlined), label: 'Operator'),
        NavigationDestination(icon: Icon(Icons.handyman_outlined), label: 'Tech'),
        NavigationDestination(icon: Icon(Icons.supervisor_account_outlined), label: 'Lead'),
        NavigationDestination(icon: Icon(Icons.insights_outlined), label: 'Manager'),
      ],
    );
  }

  Widget _navItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required String route,
    required String currentRoute,
    required VoidCallback onTap,
    Color? badgeColor,
  }) {
    final isSelected = route == '/' ? currentRoute == '/' : currentRoute.startsWith(route);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withOpacity(0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        leading: Icon(isSelected ? activeIcon : icon, size: 20, color: isSelected ? AppColors.primary : AppColors.textSecondary),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
        trailing: badgeColor != null
            ? Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: badgeColor, shape: BoxShape.circle),
              )
            : null,
        onTap: onTap,
      ),
    );
  }

  Color _roleColor(UserRole role) {
    switch (role) {
      case UserRole.student:
        return AppColors.roleStudent;
      case UserRole.operator:
        return AppColors.roleOperator;
      case UserRole.technician:
        return AppColors.roleTechnician;
      case UserRole.teamLead:
        return AppColors.priorityCritical;
      case UserRole.manager:
        return AppColors.verifiedGreen;
      case UserRole.admin:
        return AppColors.roleAdmin;
    }
  }

  IconData _roleIcon(UserRole role) {
    switch (role) {
      case UserRole.student:
        return Icons.school;
      case UserRole.operator:
        return Icons.support_agent;
      case UserRole.technician:
        return Icons.handyman;
      case UserRole.teamLead:
        return Icons.supervisor_account;
      case UserRole.manager:
        return Icons.insights;
      case UserRole.admin:
        return Icons.admin_panel_settings;
    }
  }
}
