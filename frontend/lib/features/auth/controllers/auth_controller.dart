import "package:get/get.dart";
import "package:firebase_auth/firebase_auth.dart";
import "../models/user_model.dart";
import "../../../core/network/api_client.dart";
import "../../../core/network/response_envelope.dart";
import "../../../core/constants/api_constants.dart";

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  final _api = ApiClient();
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoading       = false.obs;
  final RxBool isAuthenticated = false.obs;

  @override
  void onInit() {
    super.onInit();
    FirebaseAuth.instance.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      currentUser.value = null;
      isAuthenticated.value = false;
      Get.offAllNamed("/login");
      return;
    }
    await fetchMe();
  }

  Future<void> fetchMe() async {
    isLoading.value = true;
    try {
      final res = await _api.dio.get(ApiConstants.authMe);
      final env = ResponseEnvelope.fromJson(
        res.data as Map<String, dynamic>,
        (d) => UserModel.fromJson(d as Map<String, dynamic>),
      );
      if (env.isSuccess) {
        currentUser.value = env.data;
        isAuthenticated.value = true;
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    currentUser.value = null;
    isAuthenticated.value = false;
    Get.offAllNamed("/login");
  }
}