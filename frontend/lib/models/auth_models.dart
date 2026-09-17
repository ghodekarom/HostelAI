class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final String email;
  final String? fullName;
  final String role;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.email,
    this.fullName,
    required this.role,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken']?.toString() ?? '',
      refreshToken: json['refreshToken']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      fullName: json['fullName']?.toString(),
      role: json['role']?.toString() ?? 'STUDENT',
    );
  }
}

class SignUpRequest {
  final String email;
  final String password;
  final String fullName;
  final String role;

  SignUpRequest({
    required this.email,
    required this.password,
    required this.fullName,
    this.role = 'STUDENT',
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'fullName': fullName,
        'role': role,
      };
}

class SignInRequest {
  final String email;
  final String password;

  SignInRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };
}

class VerifyCodeRequest {
  final String email;
  final String code;

  VerifyCodeRequest({required this.email, required this.code});

  Map<String, dynamic> toJson() => {
        'email': email,
        'code': code,
      };
}
