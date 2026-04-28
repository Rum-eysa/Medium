import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../articles/controllers/article_controller.dart';
import '../../articles/views/article_list_view.dart';

class HomeView extends GetView<ArticleController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medium'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Get.toNamed('/search'),
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => Get.toNamed('/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Get.toNamed('/profile'),
          ),
        ],
      ),
      body: const ArticleListView(),
    );
  }
}