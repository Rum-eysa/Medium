import '../error/app_error.dart';

class ResponseEnvelope<T> {
  final bool success;
  final T? data;
  final AppError? error;
  final Map<String, dynamic>? meta;

  const ResponseEnvelope({required this.success, this.data, this.error, this.meta});

  bool get isSuccess => success && error == null;

  factory ResponseEnvelope.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) =>
      ResponseEnvelope<T>(
        success: json["success"] as bool,
        data: json["data"] != null && fromJsonT != null
            ? fromJsonT(json["data"])
            : null,
        error: json["error"] != null
            ? AppError.fromJson(json["error"] as Map<String, dynamic>)
            : null,
        meta: json["meta"] as Map<String, dynamic>?,
      );
}