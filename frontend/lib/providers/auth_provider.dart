import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/auth_models.dart';
import 'api_providers.dart';

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? email;
  final String? role;
  final String? errorMessage;

  AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.email,
    this.role,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? email,
    String? role,
    String? errorMessage,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      email: email ?? this.email,
      role: role ?? this.role,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;

  AuthNotifier(this.ref) : super(AuthState());

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repo = ref.read(authRepositoryProvider);
      final res = await repo.signIn(email, password);
      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        email: res.email,
        role: res.role,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> signUp(String email, String password, String fullName, String role) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.signUp(email, password, fullName, role);
      state = state.copyWith(isLoading: false, email: email, role: role);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> verifyCode(String email, String code) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repo = ref.read(authRepositoryProvider);
      final res = await repo.verifyCode(email, code);
      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        email: res.email,
        role: res.role,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> signOut() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.logout();
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});
