// ============================================================================
// HOME CONTROLLER
// ============================================================================
// Dosya: features/home/controllers/home_controller.dart
//
// US-010 Kişiselleştirilmiş Anasayfa Feed
// US-011 Etiket Keşfi
// US-013 Trend Makaleler
// ============================================================================

import 'package:get/get.dart';
import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/response_envelope.dart';
import '../models/article_model.dart';

enum FeedTab { forYou, following, trending }

class HomeController extends GetxController {
  static HomeController get to => Get.find();

  final _apiClient = ApiClient();

  // ── State ─────────────────────────────────────────────────────────────────
  final currentTab = FeedTab.forYou.obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;

  final forYouFeed = <ArticleModel>[].obs;
  final followingFeed = <ArticleModel>[].obs;
  final trendingFeed = <ArticleModel>[].obs;

  final trendingTags = <String>[].obs;

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    fetchFeed();
  }

  // ── Feed ──────────────────────────────────────────────────────────────────

  Future<void> fetchFeed() async {
    isLoading.value = true;

    try {
      final response = await _apiClient.get(ApiEndpoints.articles);
      final envelope = ResponseEnvelope<List<ArticleModel>>.fromJson(
        response.data,
        (json) {
          if (json is List) {
            return json
                .map(
                  (item) => ArticleModel.fromJson(item as Map<String, dynamic>),
                )
                .toList();
          }
          return <ArticleModel>[];
        },
      );

      if (envelope.success && envelope.data != null) {
        final articles = envelope.data!;
        forYouFeed.assignAll(articles);
        trendingFeed.assignAll(
          articles.toList()..sort((a, b) => b.clapCount.compareTo(a.clapCount)),
        );
        followingFeed.assignAll(
          articles.where((a) => a.tag != null).take(3).toList(),
        );
      } else {
        throw Exception('Arka uçtan veri alınamadı');
      }
    } catch (_) {
      forYouFeed.assignAll(ArticleModel.mockFeed());
      trendingFeed.assignAll(ArticleModel.mockTrending());
      followingFeed.assignAll(ArticleModel.mockFeed().take(3).toList());
    }

    trendingTags.assignAll([
      'Flutter',
      'Dart',
      'AI',
      'Backend',
      'Clean Code',
      'GetX',
      'Supabase',
    ]);

    isLoading.value = false;
  }

  Future<void> refreshFeed() => fetchFeed();

  Future<void> loadMore() async {
    if (isLoadingMore.value) return;
    isLoadingMore.value = true;
    await Future.delayed(const Duration(milliseconds: 800));
    // Gerçek projede sayfalama burada yapılır
    isLoadingMore.value = false;
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  void switchTab(FeedTab tab) => currentTab.value = tab;

  void toggleBookmark(String articleId) {
    void toggle(RxList<ArticleModel> list) {
      final idx = list.indexWhere((a) => a.id == articleId);
      if (idx == -1) return;
      list[idx] = list[idx].copyWith(isBookmarked: !list[idx].isBookmarked);
    }

    toggle(forYouFeed);
    toggle(trendingFeed);
    toggle(followingFeed);
  }

  void toggleClap(String articleId) {
    void toggle(RxList<ArticleModel> list) {
      final idx = list.indexWhere((a) => a.id == articleId);
      if (idx == -1) return;

      final article = list[idx];
      final isClapped = !article.isClapped;
      list[idx] = article.copyWith(
        isClapped: isClapped,
        clapCount: (article.clapCount + (isClapped ? 1 : -1)).clamp(0, 1 << 31),
      );
    }

    toggle(forYouFeed);
    toggle(trendingFeed);
    toggle(followingFeed);
  }

  List<ArticleModel> get currentFeed {
    switch (currentTab.value) {
      case FeedTab.forYou:
        return forYouFeed;
      case FeedTab.following:
        return followingFeed;
      case FeedTab.trending:
        return trendingFeed;
    }
  }
}
