import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../views/_auth_shared_widgets.dart';
import 'reset_password_view.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final authCtrl = Get.find<AuthController>();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthPageScaffold(
      title: 'Şifreni sıfırla',
      subtitle: 'Kayıtlı e-posta adresine sıfırlama bağlantısı gönderelim.',
      child: Obx(() {
        if (authCtrl.resetEmailSent.value) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Link gönderildi.',
                style: TextStyle(
                  color: Color(0xFFF0EFF8),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'E-posta adresinize sıfırlama bağlantısı gönderildi. Geliştirme ortamında mail gitmezse aşağıdaki tokeni kullanabilirsiniz.',
                style: TextStyle(
                  color: Color(0xFF8B8A9B),
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
              if (authCtrl.resetToken.value != null) ...[
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF12121C),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFF4ECDC4),
                      width: 0.8,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Geliştirici tokeni',
                        style: TextStyle(
                          color: Color(0xFF4ECDC4),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SelectableText(
                        authCtrl.resetToken.value!,
                        style: const TextStyle(
                          color: Color(0xFFF0EFF8),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: () {
                    Get.to(
                      () => ResetPasswordView(token: authCtrl.resetToken.value),
                    );
                  },
                  child: const Text('Token ile şifremi değiştir'),
                ),
              ],
              const SizedBox(height: 18),
              FilledButton(
                onPressed: () => Get.toNamed('/login'),
                child: const Text('Giriş Sayfasına Dön'),
              ),
            ],
          );
        }

        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthField(
                controller: emailController,
                label: 'E-POSTA',
                hint: 'ornek@email.com',
                icon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'E-posta gerekli';
                  if (!value.contains('@')) return 'Geçerli e-posta girin';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Obx(
                () => PrimaryButton(
                  label: 'Sıfırlama Linki Gönder',
                  isLoading: authCtrl.isPasswordResetLoading.value,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      authCtrl.forgotPassword(
                        email: emailController.text.trim(),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
