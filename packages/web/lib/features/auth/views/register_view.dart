import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final authCtrl = Get.find<AuthController>();

  final emailCtrl = TextEditingController();
  final usernameCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final displayNameCtrl = TextEditingController();

  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kayıt Ol')),
      body: SingleChildScrollView(
        // ← SADECE BU DEĞİŞTİ (Obx wrapper'ı çıktı)
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Step indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStepIndicator(0, 'Ad-Soyad'),
                  const SizedBox(width: 16),
                  _buildStepIndicator(1, 'Email'),
                  const SizedBox(width: 16),
                  _buildStepIndicator(2, 'Şifre'),
                ],
              ),
              const SizedBox(height: 32),

              // Step content
              if (_currentStep == 0) ...[
                const Text(
                  'Adınız nedir?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: displayNameCtrl,
                  label: 'Ad Soyad',
                  icon: Icons.person,
                ),
              ] else if (_currentStep == 1) ...[
                const Text(
                  'Email adresiniz?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: emailCtrl,
                  label: 'Email',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: usernameCtrl,
                  label: 'Kullanıcı Adı',
                  icon: Icons.account_circle,
                ),
              ] else if (_currentStep == 2) ...[
                const Text(
                  'Güçlü bir şifre seçin',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: passwordCtrl,
                  label: 'Şifre',
                  icon: Icons.lock,
                  obscureText: true,
                ),
              ],

              const SizedBox(height: 32),

              // Buttons
              Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _currentStep--),
                        child: const Text('Geri'),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentStep < 2) {
                          setState(() => _currentStep++);
                        } else {
                          // Register
                          authCtrl.register(
                            email: emailCtrl.text,
                            username: usernameCtrl.text,
                            password: passwordCtrl.text,
                            displayName: displayNameCtrl.text,
                          );
                        }
                      },
                      child: Text(_currentStep < 2 ? 'İleri' : 'Kayıt Ol'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label) {
    bool isActive = _currentStep >= step;
    return Column(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: isActive ? Colors.blue : Colors.grey,
          child: Text(
            '${step + 1}',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        prefixIcon: Icon(icon),
      ),
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
