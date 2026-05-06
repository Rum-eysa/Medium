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
import '../../auth/controllers/auth_controller.dart';
import '../controllers/home_controller.dart';
import '../../search/views/search_view.dart';
import '../../articles/views/article_detail_view.dart';
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
        body: Obx(() {
          if (controller.isLoading.value) {
            return const _FeedSkeleton();
          }

          return RefreshIndicator(
            onRefresh: controller.refreshFeed,
            color: Theme.of(context).colorScheme.primary,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                _HomeAppBar(innerBoxIsScrolled: false),
                _TagsBar(),
                SliverToBoxAdapter(child: _HomeBody()),
              ],
            ),
          );
        }),
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
        // Arama — US-012
        IconButton(
          icon: const Icon(Icons.search_rounded),
          onPressed: () => Get.to(() => const SearchView()),
          tooltip: 'Ara',
        ),
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
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded),
          onPressed: () => Get.toNamed('/notifications'),
          tooltip: 'Bildirimler',
        ),
        Obx(() {
          final auth = Get.find<AuthController>();
          return IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              if (auth.isAuthenticated.value) {
                Get.toNamed('/editor');
              } else {
                Get.snackbar(
                  'Giriş gerekli',
                  'Yeni yazı yayınlamak için giriş yapmalısınız.',
                  snackPosition: SnackPosition.BOTTOM,
                );
                Get.toNamed('/login');
              }
            },
            tooltip: auth.isAuthenticated.value ? 'Yaz' : 'Giriş yap',
          );
        }),
        Obx(() {
          final auth = Get.find<AuthController>();
          if (auth.isAuthenticated.value) {
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () => Get.toNamed('/profile'),
                child: const AuthorAvatar(initials: 'AY', size: 32),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: () => Get.toNamed('/login'),
              child: const Text('Giriş Yap'),
            ),
          );
        }),
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

// ── Home içeriği ve yan paneller ───────────────────────────────────────────────

class _HomeBody extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 1180;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 240, child: _LeftSidebar()),
                    const SizedBox(width: 20),
                    Expanded(child: _MainFeedColumn()),
                    const SizedBox(width: 20),
                    SizedBox(width: 320, child: _RightSidebar()),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _LeftSidebar(),
                    const SizedBox(height: 18),
                    _MainFeedColumn(),
                    const SizedBox(height: 18),
                    _RightSidebar(),
                  ],
                ),
        );
      },
    );
  }
}

class _LeftSidebar extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SidebarCard(
          title: 'Keşfet',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SidebarNavItem(
                icon: Icons.home_outlined,
                label: 'Ana Sayfa',
                onTap: () => controller.switchTab(FeedTab.forYou),
              ),
              _SidebarNavItem(
                icon: Icons.people_outline,
                label: 'Takipler',
                onTap: () => controller.switchTab(FeedTab.following),
              ),
              _SidebarNavItem(
                icon: Icons.trending_up_outlined,
                label: 'Trend',
                onTap: () => controller.switchTab(FeedTab.trending),
              ),
              _SidebarNavItem(
                icon: Icons.bookmark_border,
                label: 'Kaydedilenler',
                onTap: () => Get.toNamed('/reading-list'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _SidebarCard(
          title: 'Popüler etiketler',
          child: Obx(
            () => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: controller.trendingTags
                  .take(6)
                  .map(
                    (tag) => TagChip(
                      label: tag,
                      onTap: () => Get.toNamed('/tag/$tag'),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _RightSidebar extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SidebarCard(
          title: 'Öne çıkan yazılar',
          child: Obx(() {
            final trending = controller.trendingFeed;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < trending.length && i < 3; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: GestureDetector(
                      onTap: () => Get.to(
                        () => ArticleDetailView(article: trending[i]),
                        transition: Transition.cupertino,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trending[i].title,
                            style: Theme.of(context).textTheme.titleMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            trending[i].authorName,
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          }),
        ),
        const SizedBox(height: 18),
        _SidebarCard(
          title: 'Hızlı bakış',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Yeni yazılar, takip ettiğin konular ve anlık trend içeriklere buradan göz atabilirsin.',
                style: TextStyle(
                  fontSize: 13,
                  color: context.appColors.textSub,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    ['Flutter', 'Dart', 'Yapay Zeka', 'Backend', 'Tasarım']
                        .map(
                          (tag) => TagChip(
                            label: tag,
                            onTap: () => Get.toNamed('/tag/$tag'),
                          ),
                        )
                        .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MainFeedColumn extends StatelessWidget {
  const _MainFeedColumn();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _feedMaxWidth),
        child: const _FeedList(),
      ),
    );
  }
}

class _SidebarCard extends StatelessWidget {
  const _SidebarCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _SidebarNavItem extends StatelessWidget {
  const _SidebarNavItem({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 18, color: context.appColors.textSub),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: context.appColors.text,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Feed list ─────────────────────────────────────────────────────────────────

class _FeedList extends GetView<HomeController> {
  const _FeedList();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final feed = controller.currentFeed;
      if (feed.isEmpty) return const _EmptyFeed();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < feed.length; i++) ...[
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _feedMaxWidth),
                child: ArticleCard(
                  title: feed[i].title,
                  subtitle: feed[i].subtitle,
                  authorName: feed[i].authorName,
                  authorInitials: feed[i].authorInitials,
                  readingMinutes: feed[i].readingMinutes,
                  tag: feed[i].tag,
                  clapCount: feed[i].clapCount,
                  isClapped: feed[i].isClapped,
                  isMemberOnly: feed[i].isMemberOnly,
                  isBookmarked: feed[i].isBookmarked,
                  coverImageUrl: feed[i].coverImageUrl,
                  authorImageUrl: feed[i].authorImageUrl,
                  onTap: () => Get.to(
                    () => ArticleDetailView(article: feed[i]),
                    transition: Transition.cupertino,
                  ),
                  onClapTap: () => controller.toggleClap(feed[i].id),
                  onBookmarkTap: () => controller.toggleBookmark(feed[i].id),
                ),
              ),
            ),
            if (i < feed.length - 1)
              Center(
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
          ],
          const SizedBox(height: 16),
          _LoadMoreButton(),
        ],
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
