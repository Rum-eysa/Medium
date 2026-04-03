import "package:flutter/material.dart";
import "package:get/get.dart";
import "../controllers/auth_controller.dart";

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Obx(() => controller.isLoading.value
          ? const CircularProgressIndicator()
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Hosgeldiniz",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Firebase Auth methodu buraya
                  },
                  child: const Text("Google ile Giris Yap"),
                ),
              ],
            )),
      ),
    );
  }
}