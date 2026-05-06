import 'package:flutter/material.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final TextEditingController emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  void _resetPassword() {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Email boş olamaz")));
      return;
    }

    // TODO: backend reset password işlemi buraya
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Şifre sıfırlama linki gönderildi: $email")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Şifremi Unuttum")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _resetPassword,
              child: const Text("Şifreyi Sıfırla"),
            ),
          ],
        ),
      ),
    );
  }
}
