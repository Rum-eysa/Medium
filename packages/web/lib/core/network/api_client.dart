import "package:dio/dio.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:get/get.dart" hide Response;
import "../constants/api_constants.dart";

class ApiClient {
  late final Dio dio;

  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 30),
        headers: {"Content-Type": "application/json"},
      ),
    );
    dio.interceptors.addAll([
      _AuthInterceptor(),
      _EnvelopeInterceptor(),
      if (!const bool.fromEnvironment("dart.vm.product"))
        LogInterceptor(requestBody: true, responseBody: true),
    ]);
  }
}

class _AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(RequestOptions o, RequestInterceptorHandler h) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      o.headers["Authorization"] = "Bearer ${await user.getIdToken()}";
    }
    h.next(o);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler h) async {
    if (err.response?.statusCode == 401) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          final token = await user.getIdToken(true);
          err.requestOptions.headers["Authorization"] = "Bearer $token";
          return h.resolve(await Dio().fetch(err.requestOptions));
        } catch (_) {}
      }
      await FirebaseAuth.instance.signOut();
      Get.offAllNamed("/login");
    }
    h.next(err);
  }
}

class _EnvelopeInterceptor extends Interceptor {
  @override
  void onResponse(Response r, ResponseInterceptorHandler h) {
    final body = r.data as Map<String, dynamic>?;
    if (body != null && body["success"] == false) {
      final e = body["error"] as Map<String, dynamic>?;
      _snack(
        e?["code"] as String? ?? "ERROR",
        e?["message"] as String? ?? "Hata",
      );
      return h.reject(
        DioException(
          requestOptions: r.requestOptions,
          response: r,
          type: DioExceptionType.badResponse,
        ),
      );
    }
    h.next(r);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler h) {
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      _snack("TIMEOUT", "Baglanti zaman asimina ugradi.");
    } else if (err.type == DioExceptionType.connectionError) {
      _snack("NO_NETWORK", "Internet baglantisi yok.");
    }
    h.next(err);
  }

  void _snack(String code, String msg) => Get.snackbar(
    "Hata ($code)",
    msg,
    snackPosition: SnackPosition.BOTTOM,
    duration: const Duration(seconds: 3),
  );
}
