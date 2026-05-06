class AppConfig {
  static const String apiBaseUrl = 'http://localhost:8000/api/v1';
  static const int requestTimeout = 30000;
}

/// Backend endpoint'leri — /api/v1 prefix ApiClient.baseUrl'de var
class ApiEndpoints {
  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String logoutAll = '/auth/logout-all';
  static const String refresh = '/auth/refresh';
  static const String me = '/auth/me';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  // Users
  static const String myProfile = '/users/me';
  static const String userProfile = '/users'; // + /{username}

  // Articles
  static const String articles = '/articles';
  static const String myArticles = '/articles/my';
}

class StorageKeys {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
}

class TokenResponse {
  final String accessToken;
  final String refreshToken;

  TokenResponse({required this.accessToken, required this.refreshToken});

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
    );
  }
}
