# flutter_setup.ps1 — Auth + Articles complete implementation
# Production-ready Flutter architecture for Medium app

param([string]$ProjectPath = "$HOME\Desktop\Medium\packages\web")

$ErrorActionPreference = "Stop"

function Log  { param($m) Write-Host "  [OK] $m" -ForegroundColor Green  }
function Info { param($m) Write-Host "  -->  $m" -ForegroundColor Cyan   }
function Hdr  { param($m) Write-Host "`n===== $m =====" -ForegroundColor Cyan }

function Write-File {
    param([string]$Path, [string]$Content)
    $dir = Split-Path $Path -Parent
    if ($dir -and !(Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    [System.IO.File]::WriteAllText($Path, $Content, [System.Text.UTF8Encoding]::new($false))
}

Hdr "Flutter Setup — Auth + Articles"
Info "Path: $ProjectPath"

# ═══════════════════════════════════════════════════════════════════════════
# 1. CORE — Config, Network, Services
# ═══════════════════════════════════════════════════════════════════════════

Write-File "$ProjectPath/lib/core/config/app_config.dart" @'
class AppConfig {
  static const String appName = 'Medium';
  static const String apiBaseUrl = 'http://localhost:8000/api/v1';
  static const int requestTimeout = 30000; // ms
  static const int tokenRefreshThreshold = 300000; // 5 min before expiry
}

class ApiEndpoints {
  static const String auth = '/auth';
  static const String login = '$auth/login';
  static const String register = '$auth/register';
  static const String me = '$auth/me';
  static const String refresh = '$auth/refresh';
  static const String logout = '$auth/logout';
  
  static const String articles = '/articles';
  static const String myArticles = '$articles/my';
  static const String articleDetail = '$articles/{id}';
  static const String clap = '$articles/{id}/clap';
  static const String follow = '$articles/authors/{id}/follow';
  
  static const String users = '/users';
  static const String userProfile = '$users/{username}';
}

class StorageKeys {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String currentUser = 'current_user';
}
'@

Write-File "$ProjectPath/lib/core/services/secure_storage_service.dart" @'
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static final SecureStorageService _instance = SecureStorageService._internal();

  factory SecureStorageService() {
    return _instance;
  }

  SecureStorageService._internal();

  final _storage = const FlutterSecureStorage();

  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  Future<bool> containsKey(String key) async {
    final value = await _storage.read(key: key);
    return value != null;
  }
}
'@

Write-File "$ProjectPath/lib/core/network/response_envelope.dart" @'
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
'@

Write-File "$ProjectPath/lib/core/network/api_client.dart" @'
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../config/app_config.dart';
import '../services/secure_storage_service.dart';
import 'response_envelope.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();

  factory ApiClient() {
    return _instance;
  }

  late Dio _dio;
  final _storage = SecureStorageService();

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(milliseconds: AppConfig.requestTimeout),
        receiveTimeout: const Duration(milliseconds: AppConfig.requestTimeout),
      ),
    );

    _dio.interceptors.add(AuthInterceptor());
    _dio.interceptors.add(ErrorInterceptor());
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _dio.get(
      path,
      queryParameters: queryParameters,
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
    );
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
  }) async {
    return _dio.patch(path, data: data);
  }

  Future<Response<T>> delete<T>(String path) async {
    return _dio.delete(path);
  }

  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }
}

class AuthInterceptor extends Interceptor {
  final _storage = SecureStorageService();

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(StorageKeys.accessToken);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      final refreshToken = await _storage.read(StorageKeys.refreshToken);
      if (refreshToken != null) {
        try {
          final response = await Dio().post(
            '${AppConfig.apiBaseUrl}${ApiEndpoints.refresh}',
            data: {'refresh_token': refreshToken},
          );

          if (response.statusCode == 200) {
            final data = response.data['data'];
            await _storage.write(StorageKeys.accessToken, data['access_token']);
            await _storage.write(StorageKeys.refreshToken, data['refresh_token']);

            final options = err.requestOptions;
            options.headers['Authorization'] = 'Bearer ${data['access_token']}';

            final newResponse = await Dio().request(
              options.path,
              options: Options(
                method: options.method,
                headers: options.headers,
              ),
              data: options.data,
            );

            return handler.resolve(newResponse);
          }
        } catch (e) {
          await _storage.deleteAll();
          Get.offAllNamed('/login');
        }
      }
    }
    return handler.next(err);
  }
}

class ErrorInterceptor extends Interceptor {
  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      final errorMsg = _getErrorMessage(err);
      Get.snackbar(
        'Hata',
        errorMsg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
    return handler.next(err);
  }

  String _getErrorMessage(DioException error) {
    if (error.response?.data is Map) {
      final data = error.response!.data as Map;
      return data['error']?['message'] ?? 'Bilinmeyen hata';
    }
    return error.message ?? 'Bağlantı hatası';
  }
}

import 'package:flutter/material.dart';
'@

# ═══════════════════════════════════════════════════════════════════════════
# 2. MODELS
# ═══════════════════════════════════════════════════════════════════════════

Write-File "$ProjectPath/lib/features/auth/models/user_model.dart" @'
class UserModel {
  final String id;
  final String email;
  final String username;
  final String? displayName;
  final String? bio;
  final String? photoUrl;
  final bool isActive;
  final bool isVerified;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.username,
    this.displayName,
    this.bio,
    this.photoUrl,
    required this.isActive,
    required this.isVerified,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      displayName: json['display_name'],
      bio: json['bio'],
      photoUrl: json['photo_url'],
      isActive: json['is_active'] ?? true,
      isVerified: json['is_verified'] ?? false,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'username': username,
    'display_name': displayName,
    'bio': bio,
    'photo_url': photoUrl,
    'is_active': isActive,
    'is_verified': isVerified,
    'created_at': createdAt.toIso8601String(),
  };
}

class TokenResponse {
  final String accessToken;
  final String refreshToken;
  final String tokenType;

  TokenResponse({
    required this.accessToken,
    required this.refreshToken,
    this.tokenType = 'bearer',
  });

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
      tokenType: json['token_type'] ?? 'bearer',
    );
  }

  Map<String, dynamic> toJson() => {
    'access_token': accessToken,
    'refresh_token': refreshToken,
    'token_type': tokenType,
  };
}
'@

Write-File "$ProjectPath/lib/features/articles/models/article_model.dart" @'
enum ArticleStatus { draft, published, archived }

class ArticleModel {
  final String id;
  final String title;
  final String? subtitle;
  final String content;
  final String? coverImageUrl;
  final String? slug;
  final ArticleStatus status;
  final int readingTimeMinutes;
  final int viewCount;
  final int clapCount;
  final UserPreviewModel author;
  final List<TagModel> tags;
  final DateTime createdAt;
  final DateTime? publishedAt;

  ArticleModel({
    required this.id,
    required this.title,
    this.subtitle,
    required this.content,
    this.coverImageUrl,
    this.slug,
    required this.status,
    required this.readingTimeMinutes,
    required this.viewCount,
    required this.clapCount,
    required this.author,
    required this.tags,
    required this.createdAt,
    this.publishedAt,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'],
      content: json['content'] ?? '',
      coverImageUrl: json['cover_image_url'],
      slug: json['slug'],
      status: _parseStatus(json['status']),
      readingTimeMinutes: json['reading_time_minutes'] ?? 1,
      viewCount: json['view_count'] ?? 0,
      clapCount: json['clap_count'] ?? 0,
      author: UserPreviewModel.fromJson(json['author'] ?? {}),
      tags: (json['tags'] as List?)?.map((t) => TagModel.fromJson(t)).toList() ?? [],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      publishedAt: json['published_at'] != null
          ? DateTime.parse(json['published_at'])
          : null,
    );
  }

  static ArticleStatus _parseStatus(String? status) {
    switch (status) {
      case 'published':
        return ArticleStatus.published;
      case 'archived':
        return ArticleStatus.archived;
      default:
        return ArticleStatus.draft;
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'subtitle': subtitle,
    'content': content,
    'cover_image_url': coverImageUrl,
    'slug': slug,
    'status': status.toString().split('.').last,
    'reading_time_minutes': readingTimeMinutes,
    'view_count': viewCount,
    'clap_count': clapCount,
    'author': author.toJson(),
    'tags': tags.map((t) => t.toJson()).toList(),
    'created_at': createdAt.toIso8601String(),
    'published_at': publishedAt?.toIso8601String(),
  };
}

class UserPreviewModel {
  final String id;
  final String username;
  final String? displayName;
  final String? photoUrl;

  UserPreviewModel({
    required this.id,
    required this.username,
    this.displayName,
    this.photoUrl,
  });

  factory UserPreviewModel.fromJson(Map<String, dynamic> json) {
    return UserPreviewModel(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      displayName: json['display_name'],
      photoUrl: json['photo_url'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'display_name': displayName,
    'photo_url': photoUrl,
  };
}

class TagModel {
  final String id;
  final String name;
  final String slug;

  TagModel({
    required this.id,
    required this.name,
    required this.slug,
  });

  factory TagModel.fromJson(Map<String, dynamic> json) {
    return TagModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'slug': slug,
  };
}
'@

# ═══════════════════════════════════════════════════════════════════════════
# 3. AUTH CONTROLLER
# ═══════════════════════════════════════════════════════════════════════════

Write-File "$ProjectPath/lib/features/auth/controllers/auth_controller.dart" @'
import 'package:get/get.dart';
import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/response_envelope.dart';
import '../../../core/services/secure_storage_service.dart';
import '../models/user_model.dart';

class AuthController extends GetxController {
  final _apiClient = ApiClient();
  final _storage = SecureStorageService();

  final isLoading = false.obs;
  final currentUser = Rx<UserModel?>(null);
  final isAuthenticated = false.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final token = await _storage.read(StorageKeys.accessToken);
    if (token != null) {
      _apiClient.setAuthToken(token);
      await _fetchCurrentUser();
    }
  }

  Future<void> register({
    required String email,
    required String username,
    required String password,
    String? displayName,
  }) async {
    try {
      isLoading.value = true;
      final response = await _apiClient.post(
        ApiEndpoints.register,
        data: {
          'email': email,
          'username': username,
          'password': password,
          'display_name': displayName,
        },
      );

      final envelope = ResponseEnvelope<TokenResponse>.fromJson(
        response.data,
        (json) => TokenResponse.fromJson(json),
      );

      if (envelope.success && envelope.data != null) {
        await _saveTokens(envelope.data!);
        _apiClient.setAuthToken(envelope.data!.accessToken);
        await _fetchCurrentUser();
        Get.offAllNamed('/home');
      }
    } catch (e) {
      Get.snackbar('Kayıt Hatası', 'Lütfen bilgilerinizi kontrol edin.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      final response = await _apiClient.post(
        ApiEndpoints.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      final envelope = ResponseEnvelope<TokenResponse>.fromJson(
        response.data,
        (json) => TokenResponse.fromJson(json),
      );

      if (envelope.success && envelope.data != null) {
        await _saveTokens(envelope.data!);
        _apiClient.setAuthToken(envelope.data!.accessToken);
        await _fetchCurrentUser();
        Get.offAllNamed('/home');
      }
    } catch (e) {
      Get.snackbar('Giriş Hatası', 'E-posta veya şifre yanlış.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      final refreshToken = await _storage.read(StorageKeys.refreshToken);
      if (refreshToken != null) {
        await _apiClient.post(
          ApiEndpoints.logout,
          data: {'refresh_token': refreshToken},
        );
      }
      await _storage.deleteAll();
      _apiClient.clearAuthToken();
      currentUser.value = null;
      isAuthenticated.value = false;
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar('Çıkış Hatası', 'Bir hata oluştu.');
    }
  }

  Future<void> _fetchCurrentUser() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.me);
      final envelope = ResponseEnvelope<UserModel>.fromJson(
        response.data,
        (json) => UserModel.fromJson(json),
      );

      if (envelope.success && envelope.data != null) {
        currentUser.value = envelope.data!;
        isAuthenticated.value = true;
      }
    } catch (e) {
      await logout();
    }
  }

  Future<void> _saveTokens(TokenResponse tokens) async {
    await _storage.write(StorageKeys.accessToken, tokens.accessToken);
    await _storage.write(StorageKeys.refreshToken, tokens.refreshToken);
  }
}
'@

# ═══════════════════════════════════════════════════════════════════════════
# 4. ARTICLES CONTROLLER
# ═══════════════════════════════════════════════════════════════════════════

Write-File "$ProjectPath/lib/features/articles/controllers/article_controller.dart" @'
import 'package:get/get.dart';
import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/response_envelope.dart';
import '../models/article_model.dart';

class ArticleController extends GetxController {
  final _apiClient = ApiClient();

  final articles = <ArticleModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPublishedArticles();
  }

  Future<void> fetchPublishedArticles() async {
    try {
      isLoading.value = true;
      final response = await _apiClient.get(ApiEndpoints.articles);

      final envelope = ResponseEnvelope<List<ArticleModel>>.fromJson(
        response.data,
        (json) {
          if (json is List) {
            return json.map((item) => ArticleModel.fromJson(item)).toList();
          }
          return [];
        },
      );

      if (envelope.success && envelope.data != null) {
        articles.value = envelope.data!;
      }
    } catch (e) {
      Get.snackbar('Hata', 'Makaleler yüklenirken hata oluştu.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<ArticleModel?> fetchArticleById(String id) async {
    try {
      final response = await _apiClient.get('${ApiEndpoints.articles}/$id');

      final envelope = ResponseEnvelope<ArticleModel>.fromJson(
        response.data,
        (json) => ArticleModel.fromJson(json),
      );

      return envelope.data;
    } catch (e) {
      Get.snackbar('Hata', 'Makale yüklenemedi.');
      return null;
    }
  }

  Future<bool> createArticle({
    required String title,
    required String content,
    String? subtitle,
    String? coverImageUrl,
    List<String> tagNames = const [],
    bool publish = false,
  }) async {
    try {
      isLoading.value = true;
      final response = await _apiClient.post(
        ApiEndpoints.articles,
        data: {
          'title': title,
          'subtitle': subtitle,
          'content': content,
          'cover_image_url': coverImageUrl,
          'tag_names': tagNames,
          'status': publish ? 'published' : 'draft',
        },
      );

      final envelope = ResponseEnvelope<ArticleModel>.fromJson(
        response.data,
        (json) => ArticleModel.fromJson(json),
      );

      if (envelope.success) {
        Get.snackbar('Başarılı', 
          publish ? 'Makale yayınlandı.' : 'Taslak kaydedildi.');
        return true;
      }
    } catch (e) {
      Get.snackbar('Hata', 'Makale oluşturulamadı.');
    } finally {
      isLoading.value = false;
    }
    return false;
  }

  Future<bool> clapArticle(String articleId, {int count = 1}) async {
    try {
      final response = await _apiClient.post(
        '${ApiEndpoints.articles}/$articleId/clap',
        queryParameters: {'count': count},
      );

      final envelope = ResponseEnvelope.fromJson(
        response.data,
        null,
      );

      if (envelope.success) {
        // Update local article clap count
        final index = articles.indexWhere((a) => a.id == articleId);
        if (index != -1) {
          final updated = articles[index];
          articles[index] = ArticleModel(
            id: updated.id,
            title: updated.title,
            subtitle: updated.subtitle,
            content: updated.content,
            coverImageUrl: updated.coverImageUrl,
            slug: updated.slug,
            status: updated.status,
            readingTimeMinutes: updated.readingTimeMinutes,
            viewCount: updated.viewCount,
            clapCount: updated.clapCount + count,
            author: updated.author,
            tags: updated.tags,
            createdAt: updated.createdAt,
            publishedAt: updated.publishedAt,
          );
          articles.refresh();
        }
        return true;
      }
    } catch (e) {
      Get.snackbar('Hata', 'Beğeni eklenemedi.');
    }
    return false;
  }

  Future<bool> followAuthor(String authorId) async {
    try {
      final response = await _apiClient.post(
        '${ApiEndpoints.articles}/authors/$authorId/follow',
      );

      final envelope = ResponseEnvelope.fromJson(
        response.data,
        null,
      );

      if (envelope.success) {
        Get.snackbar('Başarılı', 'Yazar takip edildi.');
        return true;
      }
    } catch (e) {
      Get.snackbar('Hata', 'Yazar takip edilemedi.');
    }
    return false;
  }
}
'@

Log "Flutter setup complete - Auth + Articles structure created"

Write-Host ""
Write-Host "✅ Setup tamamlandı!" -ForegroundColor Green
Write-Host ""
Write-Host "Yapılan işlemler:" -ForegroundColor White
Write-Host "  ✓ Core (Config, Storage, Network)" -ForegroundColor Cyan
Write-Host "  ✓ Models (User, Article, Token)" -ForegroundColor Cyan
Write-Host "  ✓ Controllers (Auth, Articles)" -ForegroundColor Cyan
Write-Host "  ✓ API integration" -ForegroundColor Cyan
Write-Host ""
Write-Host "Sıradaki adım:" -ForegroundColor Yellow
Write-Host "  cd ""$ProjectPath""" -ForegroundColor White
Write-Host "  flutter pub get" -ForegroundColor White
Write-Host ""
