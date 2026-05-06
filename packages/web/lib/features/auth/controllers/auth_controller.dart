import 'package:get/get.dart';
import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/response_envelope.dart';
import '../../../core/services/secure_storage_service.dart';
import '../models/user_model.dart' hide TokenResponse;

class AuthController extends GetxController {
  final _apiClient = ApiClient();
  final _storage = SecureStorageService();

  final isLoading = false.obs;
  final isPasswordResetLoading = false.obs;
  final currentUser = Rx<UserModel?>(null);
  final isAuthenticated = false.obs;
  final resetEmailSent = false.obs;
  final passwordResetSuccess = false.obs;

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

  // ─── US-001 Register ────────────────────────────────────────────────────────

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
          if (displayName != null && displayName.isNotEmpty)
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
      // ErrorInterceptor snackbar'ı zaten gösteriyor
    } finally {
      isLoading.value = false;
    }
  }

  // ─── US-002 Login ────────────────────────────────────────────────────────────

  Future<void> login({required String email, required String password}) async {
    try {
      isLoading.value = true;
      final response = await _apiClient.post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
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
      // ErrorInterceptor handle ediyor
    } finally {
      isLoading.value = false;
    }
  }

  // ─── US-003 Forgot Password ──────────────────────────────────────────────────

  Future<void> forgotPassword({required String email}) async {
    try {
      isPasswordResetLoading.value = true;
      final response = await _apiClient.post(
        ApiEndpoints.forgotPassword,
        data: {'email': email},
      );

      final envelope = ResponseEnvelope<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (envelope.success) {
        resetEmailSent.value = true;
      }
    } catch (e) {
      // ErrorInterceptor handle ediyor
    } finally {
      isPasswordResetLoading.value = false;
    }
  }

  // ─── US-003 Reset Password ────────────────────────────────────────────────────

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      isPasswordResetLoading.value = true;
      final response = await _apiClient.post(
        ApiEndpoints.resetPassword,
        data: {'token': token, 'new_password': newPassword},
      );

      final envelope = ResponseEnvelope<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (envelope.success) {
        passwordResetSuccess.value = true;
      }
    } catch (e) {
      // ErrorInterceptor handle ediyor
    } finally {
      isPasswordResetLoading.value = false;
    }
  }

  // ─── US-004 Logout ────────────────────────────────────────────────────────────

  Future<void> logout() async {
    try {
      final refreshToken = await _storage.read(StorageKeys.refreshToken);
      if (refreshToken != null) {
        await _apiClient.post(
          ApiEndpoints.logout,
          data: {'refresh_token': refreshToken},
        );
      }
    } catch (_) {
    } finally {
      await _clearSession();
    }
  }

  Future<void> logoutAll() async {
    try {
      await _apiClient.post(ApiEndpoints.logoutAll);
    } catch (_) {
    } finally {
      await _clearSession();
    }
  }

  Future<void> _clearSession() async {
    await _storage.deleteAll();
    _apiClient.clearAuthToken();
    currentUser.value = null;
    isAuthenticated.value = false;
    resetEmailSent.value = false;
    passwordResetSuccess.value = false;
    Get.offAllNamed('/login');
  }

  // ─── Get Me ───────────────────────────────────────────────────────────────────

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
    } catch (_) {
      await _clearSession();
    }
  }

  Future<void> _saveTokens(TokenResponse tokens) async {
    await _storage.write(StorageKeys.accessToken, tokens.accessToken);
    await _storage.write(StorageKeys.refreshToken, tokens.refreshToken);
  }
}
