import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../auth/controllers/auth_controller.dart';

class ProfileView extends GetView<AuthController> {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => controller.logout(),
          ),
        ],
      ),
      body: Obx(() {
        final user = controller.currentUser.value;
        if (user == null) {
          return const Center(child: Text('Kullanıcı bilgisi yükleniyor...'));
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        child: Text(user.username[0].toUpperCase()),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.displayName ?? user.username,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Text('@${user.username}'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                if (user.bio != null)
                  Text(user.bio!),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Get.toNamed('/profile-edit'),
                  child: const Text('Profili Düzenle'),
                ),
                const SizedBox(height: 16),
                Text('Makalelerim', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                // Article list here
              ],
            ),
          ),
        );
      }),
    );
  }
}