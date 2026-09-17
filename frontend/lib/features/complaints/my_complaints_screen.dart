import 'package:flutter/material.dart';
import 'student_dashboard_screen.dart';

/// MyComplaintsScreen delegates to StudentDashboardScreen for unified complaint management
class MyComplaintsScreen extends StatelessWidget {
  const MyComplaintsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const StudentDashboardScreen();
  }
}
