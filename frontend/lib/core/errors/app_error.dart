export '../network/api_exception.dart';

class AppError {
  final String title;
  final String description;

  AppError({required this.title, required this.description});

  factory AppError.fromException(dynamic error) {
    if (error is Exception) {
      return AppError(
        title: 'Operation Failed',
        description: error.toString().replaceAll('Exception:', '').trim(),
      );
    }
    return AppError(
      title: 'Unexpected Error',
      description: error?.toString() ?? 'An unknown error occurred.',
    );
  }
}
