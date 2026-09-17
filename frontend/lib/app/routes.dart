import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/widgets/app_shell.dart';
import '../features/portal/portal_home_screen.dart';
import '../features/complaints/student_dashboard_screen.dart';
import '../features/complaints/complaint_filing_screen.dart';
import '../features/complaints/complaint_detail_screen.dart';
import '../features/operator/operator_queue_screen.dart';
import '../features/operator/operator_triage_screen.dart';
import '../features/technician/technician_tasks_screen.dart';
import '../features/technician/technician_task_detail_screen.dart';
import '../features/admin/admin_dashboard_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return AppShell(child: child);
      },
      routes: [
        // Portal Home
        GoRoute(
          path: '/',
          builder: (context, state) => const PortalHomeScreen(),
        ),

        // Student Portal
        GoRoute(
          path: '/student',
          builder: (context, state) => const StudentDashboardScreen(),
          routes: [
            GoRoute(
              path: 'new',
              builder: (context, state) => const ComplaintFilingScreen(),
            ),
            GoRoute(
              path: 'complaints/:id',
              builder: (context, state) {
                final id = int.tryParse(state.pathParameters['id'] ?? '1') ?? 1;
                return ComplaintDetailScreen(id: id);
              },
            ),
          ],
        ),

        // Operator Room
        GoRoute(
          path: '/operator',
          builder: (context, state) => const OperatorQueueScreen(),
          routes: [
            GoRoute(
              path: 'complaints/:id',
              builder: (context, state) {
                final id = int.tryParse(state.pathParameters['id'] ?? '1') ?? 1;
                return OperatorTriageScreen(id: id);
              },
            ),
          ],
        ),

        // Technician Console
        GoRoute(
          path: '/technician',
          builder: (context, state) => const TechnicianTasksScreen(),
          routes: [
            GoRoute(
              path: 'complaints/:id',
              builder: (context, state) {
                final id = int.tryParse(state.pathParameters['id'] ?? '1') ?? 1;
                return TechnicianTaskDetailScreen(id: id);
              },
            ),
          ],
        ),

        // Admin Hub
        GoRoute(
          path: '/admin',
          builder: (context, state) => const AdminDashboardScreen(),
        ),
      ],
    ),

    // Auth Screen Placeholder (Phase 5)
    GoRoute(
      path: '/login',
      builder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('Sign In')),
        body: const Center(
          child: Text('Authentication & RBAC scheduled for Phase 5'),
        ),
      ),
    ),
  ],
);
