class AppError {
  final String code;
  final String message;
  final Map<String, dynamic>? details;

  const AppError({required this.code, required this.message, this.details});

  factory AppError.fromJson(Map<String, dynamic> json) => AppError(
        code: json["code"] as String,
        message: json["message"] as String,
        details: json["details"] as Map<String, dynamic>?,
      );

  String? fieldError(String field) => details?[field] as String?;

  @override
  String toString() => "[$code] $message";
}