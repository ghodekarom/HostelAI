import 'package:flutter_riverpod/flutter_riverpod.dart';

enum UserRole {
  student,
  operator,
  technician,
  admin;

  String get displayName {
    switch (this) {
      case UserRole.student:
        return 'Student';
      case UserRole.operator:
        return 'Maintenance Operator';
      case UserRole.technician:
        return 'Field Technician';
      case UserRole.admin:
        return 'Administrator';
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
      case UserRole.admin:
        return '4';
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
