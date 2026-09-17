import 'package:flutter_riverpod/flutter_riverpod.dart';

enum UserRole {
  student,
  operator,
  technician,
  teamLead,
  manager,
  admin;

  String get displayName {
    switch (this) {
      case UserRole.student:
        return 'Student';
      case UserRole.operator:
        return 'Maintenance Operator';
      case UserRole.technician:
        return 'Field Technician';
      case UserRole.teamLead:
        return 'Hostel Warden / Team Lead';
      case UserRole.manager:
        return 'Chief Warden / Manager';
      case UserRole.admin:
        return 'Campus Admin';
    }
  }

  String get roleCode {
    switch (this) {
      case UserRole.student:
        return 'ROLE_STUDENT';
      case UserRole.operator:
        return 'ROLE_OPERATOR';
      case UserRole.technician:
        return 'ROLE_TECHNICIAN';
      case UserRole.teamLead:
        return 'ROLE_TEAM_LEAD';
      case UserRole.manager:
        return 'ROLE_MANAGER';
      case UserRole.admin:
        return 'ROLE_ADMIN';
    }
  }

  String get userId {
    switch (this) {
      case UserRole.student:
        return '1';
      case UserRole.operator:
        return '2';
      case UserRole.technician:
        return '3';
      case UserRole.teamLead:
        return '4';
      case UserRole.manager:
        return '5';
      case UserRole.admin:
        return '6';
    }
  }

  String? get technicianId {
    return this == UserRole.technician ? '1' : null;
  }
}

class RoleNotifier extends StateNotifier<UserRole> {
  RoleNotifier() : super(UserRole.student);

  void setRole(UserRole newRole) {
    state = newRole;
  }
}

final roleProvider = StateNotifierProvider<RoleNotifier, UserRole>((ref) {
  return RoleNotifier();
});
