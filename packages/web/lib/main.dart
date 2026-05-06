import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/article/controllers/article_controller.dart';
import 'features/home/controllers/home_controller.dart';
import 'features/auth/views/login_view.dart';
import 'features/auth/views/register_view.dart';
import 'features/auth/views/forgot_password_view.dart';
import 'features/auth/views/reset_password_view.dart';
import 'features/backlog/views/backlog_views.dart';
import 'features/editor/views/editor_view.dart';
import 'features/home/views/home_view.dart';
import 'features/notifications/views/notifications_view.dart';
import 'features/profile/views/profile_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  Get.put(ThemeController());
  Get.put(AuthController());
  Get.put(ArticleController());
  Get.put(HomeController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GetMaterialApp(
        title: 'Medium',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeController.to.mode,
        home: const AuthWrapper(),
        getPages: [
          GetPage(name: '/login', page: () => const LoginView()),
          GetPage(name: '/register', page: () => const RegisterView()),
          GetPage(
            name: '/forgot-password',
            page: () => const ForgotPasswordView(),
          ),
          GetPage(name: '/reset-password', page: () => const ResetPasswordView()),
          GetPage(name: '/home', page: () => const HomeView()),
          GetPage(name: '/editor', page: () => const EditorView()),
          GetPage(name: '/notifications', page: () => const NotificationsView()),
          GetPage(
            name: '/article/:id',
            page: () =>
                ArticleRouteView(articleId: Get.parameters['id'] ?? '1'),
          ),
          GetPage(
            name: '/profile',
            page: () => const ProfileView(isOwnProfile: true),
          ),
          GetPage(name: '/profile/edit', page: () => const ProfileEditView()),
          GetPage(
            name: '/profile/:id',
            page: () => ProfileView(userId: Get.parameters['id']),
          ),
          GetPage(name: '/followers', page: () => const FollowersView()),
          GetPage(
            name: '/tag/:tag',
            page: () =>
                TagArticlesView(tag: Get.parameters['tag'] ?? 'Flutter'),
          ),
          GetPage(name: '/membership', page: () => const MembershipView()),
        ],
      ),
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
