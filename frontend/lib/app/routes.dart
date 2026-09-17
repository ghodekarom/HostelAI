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
import '../features/team_lead/team_lead_at_risk_screen.dart';
import '../features/team_lead/team_lead_intervention_screen.dart';
import '../features/manager/manager_analytics_screen.dart';
import '../features/admin/admin_dashboard_screen.dart';
import '../features/notifications/notifications_screen.dart';
import '../features/auth/sign_in_screen.dart';
import '../features/auth/sign_up_screen.dart';
import '../features/auth/verify_code_screen.dart';
import '../features/auth/password_reset_screen.dart';

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

        // 1. Student Portal
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

        // 2. Operator Room
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

        // 3. Technician Console
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

        // 4. Warden / Team Lead Console
        GoRoute(
          path: '/team-lead',
          builder: (context, state) => const TeamLeadAtRiskScreen(),
          routes: [
            GoRoute(
              path: 'complaints/:id',
              builder: (context, state) {
                final id = int.tryParse(state.pathParameters['id'] ?? '1') ?? 1;
                return TeamLeadInterventionScreen(id: id);
              },
            ),
          ],
        ),

        // 5. Manager Analytics
        GoRoute(
          path: '/manager',
          builder: (context, state) => const ManagerAnalyticsScreen(),
        ),

        // 6. Campus Admin Hub
        GoRoute(
          path: '/admin',
          builder: (context, state) => const AdminDashboardScreen(),
        ),

        // In-App Notifications
        GoRoute(
          path: '/notifications',
          builder: (context, state) => const NotificationsScreen(),
        ),
      ],
    ),

    // Authentication Routes (Standalone outside Shell)
    GoRoute(
      path: '/login',
      builder: (context, state) => const SignInScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path: '/verify',
      builder: (context, state) {
        final email = state.uri.queryParameters['email'];
        return VerifyCodeScreen(email: email);
      },
    ),
    GoRoute(
      path: '/password-reset',
      builder: (context, state) => const PasswordResetScreen(),
    ),
  ],
);
