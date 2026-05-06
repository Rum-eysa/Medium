import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../views/_auth_shared_widgets.dart';
import 'register_view.dart';
import 'forgot_password_view.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 56),

                // ── Logo ──────────────────────────────────────────────────────
                const AppLogo(),
                const SizedBox(height: 48),

                // ── Başlık ────────────────────────────────────────────────────
                const Text(
                  'Tekrar\nhoş geldiniz.',
                  style: TextStyle(
                    color: Color(0xFFF0EFF8),
                    fontSize: 38,
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                    fontFamily: 'Georgia',
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Hesabınıza giriş yapın.',
                  style: TextStyle(color: Color(0xFF8B8A9B), fontSize: 15),
                ),

                const SizedBox(height: 40),

                // ── E-posta ───────────────────────────────────────────────────
                AuthField(
                  controller: emailCtrl,
                  label: 'E-POSTA',
                  hint: 'ornek@email.com',
                  icon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'E-posta gerekli';
                    if (!v.contains('@')) return 'Geçerli e-posta girin';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // ── Şifre ─────────────────────────────────────────────────────
                AuthField(
                  controller: passCtrl,
                  label: 'ŞİFRE',
                  hint: '••••••••',
                  icon: Icons.lock_outline_rounded,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Şifre gerekli';
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // ── Şifremi unuttum ───────────────────────────────────────────
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => Get.to(() => const ForgotPasswordView()),
                    child: const Text(
                      'Şifremi unuttum',
                      style: TextStyle(
                        color: Color(0xFF8B85FF),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // ── Giriş Butonu ──────────────────────────────────────────────
                Obx(
                  () => PrimaryButton(
                    label: 'Giriş Yap',
                    isLoading: controller.isLoading.value,
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        controller.login(
                          email: emailCtrl.text.trim(),
                          password: passCtrl.text,
                        );
                      }
                    },
                  ),
                ),

                const SizedBox(height: 28),
                const AuthDivider(),
                const SizedBox(height: 20),

                // ── Kayıt ol linki ────────────────────────────────────────────
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Hesabınız yok mu?',
                        style: TextStyle(
                          color: Color(0xFF8B8A9B),
                          fontSize: 14,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Get.to(() => const RegisterView()),
                        child: const Text(
                          'Kayıt Ol',
                          style: TextStyle(
                            color: Color(0xFF8B85FF),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
