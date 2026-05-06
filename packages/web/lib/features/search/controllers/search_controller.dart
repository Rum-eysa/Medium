// ============================================================================
// SEARCH CONTROLLER — US-012
// ============================================================================
// Dosya: features/search/controllers/search_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../home/models/article_model.dart';

class SearchController extends GetxController {
  static SearchController get to => Get.find();

  final textCtrl = TextEditingController();
  final query = ''.obs;
  final isSearching = false.obs;

  final articleResults = <ArticleModel>[].obs;
  final authorResults = <Map<String, String>>[].obs;
  final tagResults = <String>[].obs;

  final trendingTags = [
    'Flutter',
    'Dart',
    'AI',
    'Backend',
    'Clean Code',
    'GetX',
    'Supabase',
    'Riverpod',
    'Firebase',
  ];

  Worker? _debounce;

  @override
  void onInit() {
    super.onInit();
    // Debounce 300ms — US-012 kabul kriteri
    _debounce = debounce(
      query,
      (_) => _performSearch(),
      time: const Duration(milliseconds: 300),
    );
  }

  @override
  void onClose() {
    _debounce?.dispose();
    textCtrl.dispose();
    super.onClose();
  }

  void onSearchChanged(String value) {
    query.value = value;
  }

  void setSearchTerm(String value) {
    textCtrl.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
    query.value = value;
  }

  void clearSearch() {
    textCtrl.clear();
    query.value = '';
    articleResults.clear();
    authorResults.clear();
    tagResults.clear();
  }

  Future<void> _performSearch() async {
    if (query.value.isEmpty) return;
    isSearching.value = true;
    await Future.delayed(const Duration(milliseconds: 400));

    final q = query.value.toLowerCase();

    // Makale sonuçları
    articleResults.assignAll(
      ArticleModel.mockFeed()
          .where(
            (a) =>
                a.title.toLowerCase().contains(q) ||
                a.subtitle.toLowerCase().contains(q) ||
                (a.tag?.toLowerCase().contains(q) ?? false),
          )
          .toList(),
    );

    // Yazar sonuçları (mock)
    final authors = [
      {'id': 'a1', 'initials': 'AY', 'name': 'Ahmet Yılmaz', 'articles': '24'},
      {'id': 'a2', 'initials': 'EK', 'name': 'Elif Kaya', 'articles': '18'},
      {'id': 'a3', 'initials': 'MÖ', 'name': 'Mert Öztürk', 'articles': '31'},
    ];
    authorResults.assignAll(
      authors.where((a) => a['name']!.toLowerCase().contains(q)).toList(),
    );

    // Etiket sonuçları
    tagResults.assignAll(
      trendingTags.where((t) => t.toLowerCase().contains(q)).toList(),
    );

    isSearching.value = false;
  }
}
