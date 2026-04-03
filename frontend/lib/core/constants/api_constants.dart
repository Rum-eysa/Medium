class ApiConstants {
  ApiConstants._();

  static const String _devBaseUrl          = 'http://localhost:8000/api/v1';
  static const String _androidEmulatorUrl  = 'http://10.0.2.2:8000/api/v1';
  static const String _prodBaseUrl         = 'https://api.yourdomain.com/api/v1';

  static const bool _isProd = bool.fromEnvironment('dart.vm.product');
  static String get baseUrl => _isProd ? _prodBaseUrl : _devBaseUrl;

  static const String authMe = '/auth/me';
  static const String users  = '/users';
}