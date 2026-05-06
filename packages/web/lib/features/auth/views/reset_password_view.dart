import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../views/_auth_shared_widgets.dart';

class ResetPasswordView extends GetView<AuthController> {
  final String? token; // deep link ile gelebilir
  const ResetPasswordView({super.key, this.token});

  @override
  Widget build(BuildContext context) {
    final tokenCtrl = TextEditingController(text: token ?? '');
    final passCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final passStrength = 0.obs;

    controller.passwordResetSuccess.value = false;

    passCtrl.addListener(() {
      passStrength.value = _calcStrength(passCtrl.text);
    });

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
                const SizedBox(height: 24),
                Obx(
                  () => controller.passwordResetSuccess.value
                      ? const SizedBox.shrink()
                      : GestureDetector(
                          onTap: () => Get.back(),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1C1C27),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFF2A2A3A),
                              ),
                            ),
                            child: const Icon(
                              Icons.arrow_back_rounded,
                              color: Color(0xFF8B8A9B),
                              size: 20,
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 32),

                Obx(
                  () => controller.passwordResetSuccess.value
                      ? _SuccessView(onLogin: () => Get.offAllNamed('/login'))
                      : _FormView(
                          tokenCtrl: tokenCtrl,
                          passCtrl: passCtrl,
                          confirmCtrl: confirmCtrl,
                          passStrength: passStrength,
                          hasPrefilledToken: token != null,
                          isLoading: controller.isPasswordResetLoading,
                          onReset: () {
                            if (formKey.currentState!.validate()) {
                              controller.resetPassword(
                                token: tokenCtrl.text.trim(),
                                newPassword: passCtrl.text,
                              );
                            }
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _calcStrength(String pw) {
    int s = 0;
    if (pw.length >= 8) s++;
    if (pw.contains(RegExp(r'[A-Z]'))) s++;
    if (pw.contains(RegExp(r'[0-9]'))) s++;
    if (pw.contains(RegExp(r'[!@#\$%^&*]'))) s++;
    return s;
  }
}

class _FormView extends StatelessWidget {
  final TextEditingController tokenCtrl, passCtrl, confirmCtrl;
  final RxInt passStrength;
  final bool hasPrefilledToken;
  final RxBool isLoading;
  final VoidCallback onReset;

  const _FormView({
    required this.tokenCtrl,
    required this.passCtrl,
    required this.confirmCtrl,
    required this.passStrength,
    required this.hasPrefilledToken,
    required this.isLoading,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFF6C63FF).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
            ),
          ),
          child: const Icon(
            Icons.key_rounded,
            color: Color(0xFF8B85FF),
            size: 32,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Yeni şifre\nbelirle.',
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
          'E-postanızdaki token\'ı girin ve yeni şifrenizi belirleyin.',
          style: TextStyle(color: Color(0xFF8B8A9B), fontSize: 15, height: 1.5),
        ),
        const SizedBox(height: 36),

        if (!hasPrefilledToken) ...[
          AuthField(
            controller: tokenCtrl,
            label: 'SIFIRLAMA KODU',
            hint: 'E-postanızdaki kodu girin',
            icon: Icons.vpn_key_outlined,
            validator: (v) => (v == null || v.isEmpty) ? 'Token gerekli' : null,
          ),
          const SizedBox(height: 20),
        ] else ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF4ECDC4).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFF4ECDC4).withValues(alpha: 0.3),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  color: Color(0xFF4ECDC4),
                  size: 18,
                ),
                SizedBox(width: 10),
                Text(
                  'Token otomatik dolduruldu',
                  style: TextStyle(
                    color: Color(0xFF4ECDC4),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],

        AuthField(
          controller: passCtrl,
          label: 'YENİ ŞİFRE',
          hint: '••••••••',
          icon: Icons.lock_outline_rounded,
          isPassword: true,
          validator: (v) =>
              (v == null || v.length < 8) ? 'En az 8 karakter' : null,
        ),
        const SizedBox(height: 8),

        // Şifre güç göstergesi
        Obx(() => _PasswordStrengthBar(strength: passStrength.value)),
        const SizedBox(height: 20),

        AuthField(
          controller: confirmCtrl,
          label: 'YENİ ŞİFRE TEKRAR',
          hint: '••••••••',
          icon: Icons.lock_outline_rounded,
          isPassword: true,
          textInputAction: TextInputAction.done,
          validator: (v) => v != passCtrl.text ? 'Şifreler eşleşmiyor' : null,
        ),
        const SizedBox(height: 32),

        Obx(
          () => PrimaryButton(
            label: 'Şifremi Güncelle',
            isLoading: isLoading.value,
            onPressed: onReset,
          ),
        ),
      ],
    );
  }
}

class _PasswordStrengthBar extends StatelessWidget {
  final int strength;
  const _PasswordStrengthBar({required this.strength});

  @override
  Widget build(BuildContext context) {
    final labels = ['', 'Zayıf', 'Orta', 'İyi', 'Güçlü'];
    final colors = [
      const Color(0xFF2A2A3A),
      const Color(0xFFFF5C72),
      Colors.orange,
      Colors.amber,
      const Color(0xFF4ECDC4),
    ];
    final color = strength > 0 ? colors[strength] : colors[0];

    return Row(
      children: [
        ...List.generate(
          4,
          (i) => Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 3,
              margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: i < strength ? color : const Color(0xFF2A2A3A),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          strength > 0 ? labels[strength] : '',
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _SuccessView extends StatelessWidget {
  final VoidCallback onLogin;
  const _SuccessView({required this.onLogin});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFF4ECDC4).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF4ECDC4).withValues(alpha: 0.3),
            ),
          ),
          child: const Icon(
            Icons.check_circle_rounded,
            color: Color(0xFF4ECDC4),
            size: 32,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Şifreniz\ngüncellendi!',
          style: TextStyle(
            color: Color(0xFFF0EFF8),
            fontSize: 38,
            fontWeight: FontWeight.w700,
            height: 1.15,
            fontFamily: 'Georgia',
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Yeni şifrenizle giriş yapabilirsiniz.',
          style: TextStyle(color: Color(0xFF8B8A9B), fontSize: 15, height: 1.5),
        ),
        const SizedBox(height: 40),
        PrimaryButton(label: 'Giriş Yap', onPressed: onLogin),
      ],
    );
  }
}
