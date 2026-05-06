// ============================================================================
// SEARCH VIEW — US-012 Arama, US-011 Etiket Keşfi
// ============================================================================
// Dosya: features/search/views/search_view.dart
//
// • Anlık arama önerileri (debounce 300ms)
// • Yazar / Makale / Etiket sekmeleri
// • Sonuç yoksa öneri gösterilir
// ============================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/search_controller.dart' as sc;
import '../../home/models/article_model.dart';
import '../../article/views/article_detail_view.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../../core/widgets/app_colors_ext.dart';

class SearchView extends StatelessWidget {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<sc.SearchController>()) {
      Get.put(sc.SearchController());
    }
    return const _SearchBody();
  }
}

class _SearchBody extends GetView<sc.SearchController> {
  const _SearchBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: _SearchField(
          onChanged: controller.onSearchChanged,
          onClear: controller.clearSearch,
          controller: controller.textCtrl,
        ),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'İptal',
              style: TextStyle(color: context.appColors.textSub, fontSize: 14),
            ),
          ),
        ],
      ),
      body: Obx(() {
        final query = controller.query.value;
        if (query.isEmpty) return const _DiscoverView();
        return const _ResultsView();
      }),
    );
  }
}

// ── Arama input ──────────────────────────────────────────────────────────────

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.onChanged,
    required this.onClear,
    required this.controller,
  });

  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      margin: const EdgeInsets.only(left: 16),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.appColors.border, width: 0.5),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        autofocus: true,
        style: TextStyle(fontSize: 14, color: context.appColors.text),
        decoration: InputDecoration(
          hintText: 'Ara...',
          hintStyle: TextStyle(color: context.appColors.textSub, fontSize: 14),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 18,
            color: context.appColors.textSub,
          ),
          suffixIcon: Obx(
            () => sc.SearchController.to.query.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.close,
                      size: 16,
                      color: context.appColors.textSub,
                    ),
                    onPressed: onClear,
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}

// ── Keşif ekranı — boş arama ────────────────────────────────────────────────

class _DiscoverView extends GetView<sc.SearchController> {
  const _DiscoverView();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trend etiketler
          const SectionDivider(label: 'TREND ETİKETLER'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: controller.trendingTags
                  .map(
                    (t) => TagChip(
                      label: t,
                      onTap: () => controller.setSearchTerm(t),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 24),

          // Önerilen makaleler
          const SectionDivider(label: 'ÖNERILEN'),
          ...ArticleModel.mockFeed()
              .take(4)
              .map(
                (a) => ArticleCard(
                  title: a.title,
                  subtitle: a.subtitle,
                  authorName: a.authorName,
                  authorInitials: a.authorInitials,
                  readingMinutes: a.readingMinutes,
                  tag: a.tag,
                  clapCount: a.clapCount,
                  isMemberOnly: a.isMemberOnly,
                  onTap: () => Get.to(
                    () => ArticleDetailView(article: a),
                    transition: Transition.cupertino,
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

// ── Sonuç ekranı ─────────────────────────────────────────────────────────────

class _ResultsView extends GetView<sc.SearchController> {
  const _ResultsView();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Sekme çubuğu
        DefaultTabController(
          length: 3,
          child: Expanded(
            child: Column(
              children: [
                TabBar(
                  tabs: const [
                    Tab(text: 'Makaleler'),
                    Tab(text: 'Yazarlar'),
                    Tab(text: 'Etiketler'),
                  ],
                ),
                Expanded(
                  child: Obx(() {
                    if (controller.isSearching.value) {
                      return Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: context.appColors.textSub,
                        ),
                      );
                    }
                    return TabBarView(
                      children: [
                        _ArticleResults(),
                        _AuthorResults(),
                        _TagResults(),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ArticleResults extends GetView<sc.SearchController> {
  @override
  Widget build(BuildContext context) {
    final results = controller.articleResults;
    if (results.isEmpty)
      return const _EmptyResult(message: 'Makale bulunamadı');
    return ListView.separated(
      itemCount: results.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        indent: 20,
        endIndent: 20,
        color: context.appColors.border,
      ),
      itemBuilder: (_, i) {
        final a = results[i];
        return ArticleCard(
          title: a.title,
          subtitle: a.subtitle,
          authorName: a.authorName,
          authorInitials: a.authorInitials,
          readingMinutes: a.readingMinutes,
          tag: a.tag,
          clapCount: a.clapCount,
          isMemberOnly: a.isMemberOnly,
          onTap: () => Get.to(
            () => ArticleDetailView(article: a),
            transition: Transition.cupertino,
          ),
        );
      },
    );
  }
}

class _AuthorResults extends GetView<sc.SearchController> {
  @override
  Widget build(BuildContext context) {
    final results = controller.authorResults;
    if (results.isEmpty) return const _EmptyResult(message: 'Yazar bulunamadı');
    return ListView.separated(
      itemCount: results.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        indent: 20,
        endIndent: 20,
        color: context.appColors.border,
      ),
      itemBuilder: (_, i) {
        final a = results[i];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 8,
          ),
          leading: AuthorAvatar(initials: a['initials']!, size: 40),
          title: Text(
            a['name']!,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: context.appColors.text,
            ),
          ),
          subtitle: Text(
            '${a['articles']} yazı',
            style: TextStyle(fontSize: 12, color: context.appColors.textSub),
          ),
          trailing: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(70, 30),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: const Text('Takip et'),
          ),
          onTap: () => Get.toNamed('/profile/${a['id']}'),
        );
      },
    );
  }
}

class _TagResults extends GetView<sc.SearchController> {
  @override
  Widget build(BuildContext context) {
    final tags = controller.tagResults;
    if (tags.isEmpty) return const _EmptyResult(message: 'Etiket bulunamadı');
    return ListView.separated(
      itemCount: tags.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        indent: 20,
        endIndent: 20,
        color: context.appColors.border,
      ),
      itemBuilder: (_, i) => ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: context.appColors.surface,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: context.appColors.border, width: 0.5),
          ),
          child: Center(
            child: Text(
              '#',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: context.appColors.textSub,
              ),
            ),
          ),
        ),
        title: Text(
          tags[i],
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: context.appColors.text,
          ),
        ),
        trailing: OutlinedButton(
          onPressed: () => Get.toNamed('/tag/${tags[i]}'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(60, 30),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            textStyle: const TextStyle(fontSize: 12),
          ),
          child: const Text('Takip et'),
        ),
        onTap: () => Get.toNamed('/tag/${tags[i]}'),
      ),
    );
  }
}

class _EmptyResult extends StatelessWidget {
  const _EmptyResult({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 40,
            color: context.appColors.textHint,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(color: context.appColors.textSub, fontSize: 14),
          ),
          const SizedBox(height: 6),
          Text(
            'Farklı kelimeler deneyin',
            style: TextStyle(color: context.appColors.textHint, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
