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