// ============================================================================
// HOME VIEW — Medium tarzı Feed
// ============================================================================
// Dosya: features/home/views/home_view.dart
//
// US-010 Kişiselleştirilmiş Anasayfa Feed (sonsuz kaydırma)
// US-011 Etiket Keşfi (trend tag satırı)
// US-013 Trend Makaleler (Trending sekmesi)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../search/views/search_view.dart';
import '../../article/views/article_detail_view.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../../core/widgets/app_colors_ext.dart';

const _feedMaxWidth = 820.0;

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: FeedTab.values.length,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            _HomeAppBar(innerBoxIsScrolled: innerBoxIsScrolled),
            _TagsBar(),
          ],
          body: Obx(() {
            if (controller.isLoading.value) {
              return const _FeedSkeleton();
            }
            return RefreshIndicator(
              onRefresh: controller.refreshFeed,
              color: Theme.of(context).colorScheme.primary,
              child: _FeedList(),
            );
          }),
        ),
      ),
    );
  }
}

// ── App bar ──────────────────────────────────────────────────────────────────

class _HomeAppBar extends GetView<HomeController> {
  const _HomeAppBar({required this.innerBoxIsScrolled});
  final bool innerBoxIsScrolled;

  @override
  Widget build(BuildContext context) {
    final tabs = ['Senin için', 'Takipler', 'Trend'];
    return SliverAppBar(
      floating: true,
      snap: true,
      pinned: false,
      forceElevated: innerBoxIsScrolled,
      title: const AppLogo(),
      actions: [
        Obx(() {
          final theme = ThemeController.to;
          return IconButton(
            icon: Icon(
              theme.isDark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
            onPressed: theme.toggleTheme,
            tooltip: theme.isDark ? 'Açık tema' : 'Koyu tema',
          );
        }),
        // Arama — US-012
        IconButton(
          icon: const Icon(Icons.search_rounded),
          onPressed: () => Get.to(() => const SearchView()),
          tooltip: 'Ara',
        ),
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded),
          onPressed: () => Get.toNamed('/notifications'),
          tooltip: 'Bildirimler',
        ),
        // Yeni yazı — US-007
        IconButton(
          icon: const Icon(Icons.edit_outlined),
          onPressed: () => Get.toNamed('/editor'),
          tooltip: 'Yaz',
        ),
        // Profil avatarı
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: GestureDetector(
            onTap: () => Get.toNamed('/profile'),
            child: const AuthorAvatar(initials: 'AY', size: 32),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(40),
        child: Obx(
          () => TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            padding: const EdgeInsets.only(left: 8),
            labelPadding: const EdgeInsets.symmetric(horizontal: 12),
            indicatorPadding: EdgeInsets.zero,
            tabs: tabs
                .asMap()
                .entries
                .map(
                  (e) => Tab(
                    child: Text(
                      e.value,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: controller.currentTab.value.index == e.key
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                )
                .toList(),
            onTap: (i) => controller.switchTab(FeedTab.values[i]),
          ),
        ),
      ),
    );
  }
}

// ── Trend etiket satırı — US-011 ────────────────────────────────────────────

class _TagsBar extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Obx(() {
        if (controller.trendingTags.isEmpty) return const SizedBox.shrink();
        return SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: controller.trendingTags.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final tag = controller.trendingTags[i];
              return TagChip(label: tag, onTap: () => Get.toNamed('/tag/$tag'));
            },
          ),
        );
      }),
    );
  }
}

// ── Feed list ─────────────────────────────────────────────────────────────────

class _FeedList extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final feed = controller.currentFeed;
      if (feed.isEmpty) return const _EmptyFeed();

      return ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: feed.length + 1, // +1 load more
        separatorBuilder: (_, __) => Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _feedMaxWidth),
            child: Divider(
              height: 1,
              thickness: 0.5,
              indent: 20,
              endIndent: 20,
              color: context.appColors.border,
            ),
          ),
        ),
        itemBuilder: (context, i) {
          if (i == feed.length) return _LoadMoreButton();

          final article = feed[i];
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _feedMaxWidth),
              child: ArticleCard(
                title: article.title,
                subtitle: article.subtitle,
                authorName: article.authorName,
                authorInitials: article.authorInitials,
                readingMinutes: article.readingMinutes,
                tag: article.tag,
                clapCount: article.clapCount,
                isClapped: article.isClapped,
                isMemberOnly: article.isMemberOnly,
                isBookmarked: article.isBookmarked,
                onTap: () => Get.to(
                  () => ArticleDetailView(article: article),
                  transition: Transition.cupertino,
                ),
                onClapTap: () => controller.toggleClap(article.id),
                onBookmarkTap: () => controller.toggleBookmark(article.id),
              ),
            ),
          );
        },
      );
    });
  }
}

// ── Load more ────────────────────────────────────────────────────────────────

class _LoadMoreButton extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _feedMaxWidth),
        child: Obx(
          () => Padding(
            padding: const EdgeInsets.all(24),
            child: controller.isLoadingMore.value
                ? Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: context.appColors.textSub,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}

// ── Empty state ──────────────────────────────────────────────────────────────

class _EmptyFeed extends StatelessWidget {
  const _EmptyFeed();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.article_outlined,
            size: 48,
            color: context.appColors.textHint,
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz içerik yok',
            style: TextStyle(
              fontSize: 16,
              color: context.appColors.textSub,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Yazar takip etmeye başla ve feed\'ini doldur.',
            style: TextStyle(fontSize: 13, color: context.appColors.textHint),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Skeleton loader ──────────────────────────────────────────────────────────

class _FeedSkeleton extends StatelessWidget {
  const _FeedSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: 4,
      separatorBuilder: (_, __) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _feedMaxWidth),
          child: const Divider(height: 1),
        ),
      ),
      itemBuilder: (_, __) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _feedMaxWidth),
          child: const _SkeletonCard(),
        ),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    final c = context.appColors.surface;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // author row
          Row(
            children: [
              _Box(width: 20, height: 20, radius: 10, color: c),
              const SizedBox(width: 8),
              _Box(width: 100, height: 10, color: c),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Box(width: double.infinity, height: 14, color: c),
                    const SizedBox(height: 6),
                    _Box(width: 200, height: 14, color: c),
                    const SizedBox(height: 10),
                    _Box(width: 140, height: 10, color: c),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              _Box(width: 72, height: 72, radius: 4, color: c),
            ],
          ),
        ],
      ),
    );
  }
}

class _Box extends StatelessWidget {
  const _Box({
    this.width,
    required this.height,
    this.radius = 4,
    required this.color,
  });
  final double? width;
  final double height;
  final double radius;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
