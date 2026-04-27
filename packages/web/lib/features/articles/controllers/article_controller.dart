import 'package:get/get.dart';
import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/response_envelope.dart';
import '../models/article_model.dart';

class ArticleController extends GetxController {
  final _apiClient = ApiClient();

  final articles = <ArticleModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPublishedArticles();
  }

  Future<void> fetchPublishedArticles() async {
    try {
      isLoading.value = true;
      final response = await _apiClient.get(ApiEndpoints.articles);

      final envelope = ResponseEnvelope<List<ArticleModel>>.fromJson(
        response.data,
        (json) {
          if (json is List) {
            return json.map((item) => ArticleModel.fromJson(item)).toList();
          }
          return [];
        },
      );

      if (envelope.success && envelope.data != null) {
        articles.value = envelope.data!;
      }
    } catch (e) {
      Get.snackbar('Hata', 'Makaleler yüklenirken hata oluştu.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<ArticleModel?> fetchArticleById(String id) async {
    try {
      final response = await _apiClient.get('${ApiEndpoints.articles}/$id');

      final envelope = ResponseEnvelope<ArticleModel>.fromJson(
        response.data,
        (json) => ArticleModel.fromJson(json),
      );

      return envelope.data;
    } catch (e) {
      Get.snackbar('Hata', 'Makale yüklenemedi.');
      return null;
    }
  }

  Future<bool> createArticle({
    required String title,
    required String content,
    String? subtitle,
    String? coverImageUrl,
    List<String> tagNames = const [],
    bool publish = false,
  }) async {
    try {
      isLoading.value = true;
      final response = await _apiClient.post(
        ApiEndpoints.articles,
        data: {
          'title': title,
          'subtitle': subtitle,
          'content': content,
          'cover_image_url': coverImageUrl,
          'tag_names': tagNames,
          'status': publish ? 'published' : 'draft',
        },
      );

      final envelope = ResponseEnvelope<ArticleModel>.fromJson(
        response.data,
        (json) => ArticleModel.fromJson(json),
      );

      if (envelope.success) {
        Get.snackbar('Başarılı', 
          publish ? 'Makale yayınlandı.' : 'Taslak kaydedildi.');
        return true;
      }
    } catch (e) {
      Get.snackbar('Hata', 'Makale oluşturulamadı.');
    } finally {
      isLoading.value = false;
    }
    return false;
  }

  Future<bool> clapArticle(String articleId, {int count = 1}) async {
    try {
      final response = await _apiClient.post(
        '${ApiEndpoints.articles}/$articleId/clap',
        queryParameters: {'count': count},
      );

      final envelope = ResponseEnvelope.fromJson(
        response.data,
        null,
      );

      if (envelope.success) {
        // Update local article clap count
        final index = articles.indexWhere((a) => a.id == articleId);
        if (index != -1) {
          final updated = articles[index];
          articles[index] = ArticleModel(
            id: updated.id,
            title: updated.title,
            subtitle: updated.subtitle,
            content: updated.content,
            coverImageUrl: updated.coverImageUrl,
            slug: updated.slug,
            status: updated.status,
            readingTimeMinutes: updated.readingTimeMinutes,
            viewCount: updated.viewCount,
            clapCount: updated.clapCount + count,
            author: updated.author,
            tags: updated.tags,
            createdAt: updated.createdAt,
            publishedAt: updated.publishedAt,
          );
          articles.refresh();
        }
        return true;
      }
    } catch (e) {
      Get.snackbar('Hata', 'Beğeni eklenemedi.');
    }
    return false;
  }

  Future<bool> followAuthor(String authorId) async {
    try {
      final response = await _apiClient.post(
        '${ApiEndpoints.articles}/authors/$authorId/follow',
      );

      final envelope = ResponseEnvelope.fromJson(
        response.data,
        null,
      );

      if (envelope.success) {
        Get.snackbar('Başarılı', 'Yazar takip edildi.');
        return true;
      }
    } catch (e) {
      Get.snackbar('Hata', 'Yazar takip edilemedi.');
    }
    return false;
  }
}