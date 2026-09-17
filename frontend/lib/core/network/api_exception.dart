class ApiException implements Exception {
  final int? statusCode;
  final String message;
  final String? error;
  final Map<String, String>? fieldErrors;

  ApiException({
    this.statusCode,
    required this.message,
    this.error,
    this.fieldErrors,
  });

  @override
  String toString() {
    if (fieldErrors != null && fieldErrors!.isNotEmpty) {
      final details = fieldErrors!.entries.map((e) => '${e.key}: ${e.value}').join(', ');
      return '$message ($details)';
    }
    return message;
  }
}
