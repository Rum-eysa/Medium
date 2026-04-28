import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/articles/controllers/article_controller.dart';
import 'features/auth/views/login_view.dart';
import 'features/auth/views/register_view.dart';
import 'features/home/views/home_view.dart';

void main() {
  Get.put(AuthController());
  Get.put(ArticleController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Medium',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
      getPages: [
        GetPage(name: '/login', page: () => const LoginView()),
        GetPage(name: '/register', page: () => const RegisterView()),
        GetPage(name: '/home', page: () => const HomeView()),
      ],
    );
  }
}

class AuthWrapper extends GetView<AuthController> {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => controller.isAuthenticated.value
          ? const HomeView()
          : const LoginView(),
    );
  }
}
