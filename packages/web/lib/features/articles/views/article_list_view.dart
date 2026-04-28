import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../controllers/article_controller.dart';
import '../models/article_model.dart';

class ArticleListView extends GetView<ArticleController> {
  const ArticleListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.articles.isEmpty) {
        return ListView.builder(
          itemCount: 5,
          itemBuilder: (_, _) => Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 200, color: Colors.grey),
                  const SizedBox(height: 8),
                  Container(height: 16, color: Colors.grey),
                  const SizedBox(height: 8),
                  Container(height: 16, width: 200, color: Colors.grey),
                ],
              ),
            ),
          ),
        );
      }

      return ListView.builder(
        itemCount: controller.articles.length,
        itemBuilder: (_, index) =>
            ArticleCard(article: controller.articles[index]),
      );
    });
  }
}

class ArticleCard extends StatelessWidget {
  final ArticleModel article;

  const ArticleCard({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: InkWell(
        onTap: () => Get.toNamed('/article/${article.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                article.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              if (article.subtitle != null)
                Text(
                  article.subtitle!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: article.author.photoUrl != null
                        ? NetworkImage(article.author.photoUrl!)
                        : null,
                    child: article.author.photoUrl == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          article.author.displayName ?? article.author.username,
                        ),
                        Text(
                          '${article.readingTimeMinutes} min read',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.favorite_border),
                    onPressed: () =>
                        Get.find<ArticleController>().clapArticle(article.id),
                  ),
                  Text('${article.clapCount}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
