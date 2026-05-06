import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../views/_auth_shared_widgets.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final authCtrl = Get.find<AuthController>();

  final _formKey = GlobalKey<FormState>();
  final emailCtrl = TextEditingController();
  final usernameCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final displayNameCtrl = TextEditingController();

  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return AuthPageScaffold(
      title: 'Yeni hesabını oluştur.',
      subtitle:
          'Blogify’de okuyabilir, takip edebilir ve içerik yayınlayabilirsiniz.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStepIndicator(0, 'Ad'),
                _buildStepIndicator(1, 'Email'),
                _buildStepIndicator(2, 'Şifre'),
              ],
            ),
            const SizedBox(height: 28),
            if (_currentStep == 0) ...[
              const Text(
                'Herkese açık adınız nedir?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              AuthField(
                controller: displayNameCtrl,
                label: 'Ad Soyad',
                icon: Icons.person_outline,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Ad soyad gerekli';
                  return null;
                },
              ),
            ] else if (_currentStep == 1) ...[
              const Text(
                'E-posta ve kullanıcı adı',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              AuthField(
                controller: emailCtrl,
                label: 'E-POSTA',
                hint: 'ornek@email.com',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'E-posta gerekli';
                  if (!v.contains('@')) return 'Geçerli e-posta girin';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              AuthField(
                controller: usernameCtrl,
                label: 'Kullanıcı Adı',
                icon: Icons.alternate_email,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Kullanıcı adı gerekli';
                  }
                  if (v.trim().length < 3) {
                    return 'En az 3 karakter girin';
                  }
                  return null;
                },
              ),
            ] else ...[
              const Text(
                'Güçlü bir şifre seçin',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              AuthField(
                controller: passwordCtrl,
                label: 'ŞİFRE',
                hint: '••••••••',
                icon: Icons.lock_outline,
                isPassword: true,
                validator: (v) {
                  if (v == null || v.length < 8) {
                    return 'En az 8 karakter';
                  }
                  if (!RegExp(r'[A-Z]').hasMatch(v)) {
                    return 'En az 1 büyük harf gerekli';
                  }
                  if (!RegExp(r'[0-9]').hasMatch(v)) {
                    return 'En az 1 rakam gerekli';
                  }
                  return null;
                },
              ),
            ],
            const SizedBox(height: 28),
            Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _currentStep--),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF6C63FF)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Geri'),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 16),
                Expanded(
                  child: PrimaryButton(
                    label: _currentStep < 2 ? 'İleri' : 'Kayıt Ol',
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        if (_currentStep < 2) {
                          setState(() => _currentStep++);
                        } else {
                          authCtrl.register(
                            email: emailCtrl.text.trim(),
                            username: usernameCtrl.text.trim(),
                            password: passwordCtrl.text,
                            displayName: displayNameCtrl.text.trim(),
                          );
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label) {
    bool isActive = _currentStep >= step;
    return Column(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: isActive
              ? const Color(0xFF6C63FF)
              : const Color(0xFF2A2A3A),
          child: Text(
            '${step + 1}',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isActive ? const Color(0xFFF0EFF8) : const Color(0xFF8B8A9B),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    usernameCtrl.dispose();
    passwordCtrl.dispose();
    displayNameCtrl.dispose();
    super.dispose();
  }
}
