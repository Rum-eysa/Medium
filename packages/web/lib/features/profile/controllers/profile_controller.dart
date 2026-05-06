// ============================================================================
// PROFILE CONTROLLER — US-019, US-016, US-020
// ============================================================================
// Dosya: features/profile/controllers/profile_controller.dart

import 'package:get/get.dart';

class ProfileController extends GetxController {
  ProfileController({required this.isOwnProfile});
  final bool isOwnProfile;

  final isFollowing = false.obs;
  final isLoading = false.obs;

  // Profil bilgileri (normalde API'den gelir)
  String get displayName => 'Ahmet Yılmaz';
  String get username => 'ahmetyilmaz';
  String get initials => 'AY';
  String get bio =>
      'Flutter developer. Açık kaynak meraklısı. Türkçe teknik içerikler yazıyorum.';
  int get articleCount => 24;
  String get followerCount => '1.2K';
  String get followingCount => '140';

  @override
  void onInit() {
    super.onInit();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 300));
    isLoading.value = false;
  }

  void toggleFollow() {
    isFollowing.value = !isFollowing.value;
    // Gerçek projede: API çağrısı + bildirim gönderimi
  }
}
