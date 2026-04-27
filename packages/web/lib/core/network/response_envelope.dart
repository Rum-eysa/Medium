class ResponseEnvelope<T> {
  final bool success;
  final T? data;
  final ErrorDetail? error;
  final Map<String, dynamic>? meta;

  ResponseEnvelope({
    required this.success,
    this.data,
    this.error,
    this.meta,
  });

  factory ResponseEnvelope.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ResponseEnvelope(
      success: json['success'] ?? false,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : null,
      error: json['error'] != null
          ? ErrorDetail.fromJson(json['error'])
          : null,
      meta: json['meta'],
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'data': data,
    'error': error,
    'meta': meta,
  };
}

class ErrorDetail {
  final String code;
  final String message;
  final Map<String, dynamic>? details;

  ErrorDetail({
    required this.code,
    required this.message,
    this.details,
  });

  factory ErrorDetail.fromJson(Map<String, dynamic> json) {
    return ErrorDetail(
      code: json['code'] ?? 'UNKNOWN_ERROR',
      message: json['message'] ?? 'Bilinmeyen hata',
      details: json['details'],
    );
  }

  Map<String, dynamic> toJson() => {
    'code': code,
    'message': message,
    'details': details,
  };
}