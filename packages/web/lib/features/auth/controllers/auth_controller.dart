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