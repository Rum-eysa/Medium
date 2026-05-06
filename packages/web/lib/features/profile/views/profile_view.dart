// ============================================================================
// PROFILE VIEW — Yazar Profili
// ============================================================================
// Dosya: features/profile/views/profile_view.dart
//
// US-019 Yazar Profil Sayfası
// US-016 Yazar Takibi (toggle)
// US-020 Profil Düzenleme (kendi profilin)
// US-021 Yazar İstatistikleri (kendi profilin)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import '../../home/models/article_model.dart';
import '../../article/views/article_detail_view.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../../core/widgets/app_colors_ext.dart';
import '../../../core/theme/theme_controller.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key, this.userId, this.isOwnProfile = false});
  final String? userId;
  final bool isOwnProfile;

  @override
  Widget build(BuildContext context) {
    final tag = isOwnProfile ? 'me' : (userId ?? 'author');
    final controller = Get.put(
      ProfileController(isOwnProfile: isOwnProfile),
      tag: tag,
    );
    return _ProfileBody(controller: controller);
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({required this.controller});

  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (_, innerBoxIsScrolled) => [
            SliverAppBar(
              pinned: true,
              forceElevated: innerBoxIsScrolled,
              expandedHeight: 0,
              actions: [
                if (controller.isOwnProfile) ...[
                  // Tema toggle
                  Obx(() {
                    final tc = ThemeController.to;
                    return IconButton(
                      icon: Icon(
                        tc.isDark
                            ? Icons.wb_sunny_outlined
                            : Icons.nights_stay_outlined,
                        size: 20,
                      ),
                      onPressed: tc.toggleTheme,
                      tooltip: 'Temayı değiştir',
                    );
                  }),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    onPressed: () => Get.toNamed('/profile/edit'),
                    tooltip: 'Profili düzenle',
                  ),
                ],
                IconButton(
                  icon: const Icon(Icons.more_horiz, size: 20),
                  onPressed: () {},
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(0),
                child: Container(),
              ),
            ),
          ],
          body: CustomScrollView(
            slivers: [
              // ── Profil header ──────────────────────────────────────────────
              SliverToBoxAdapter(
                child: _ProfileHeader(ctrl: controller),
              ),

              // ── Tab bar ────────────────────────────────────────────────────
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickyTabBarDelegate(
                  TabBar(
                    tabs: const [
                      Tab(text: 'Yazılar'),
                      Tab(text: 'En Popüler'),
                      Tab(text: 'Kayıtlar'),
                    ],
                  ),
                ),
              ),

              // ── Tab içeriği ────────────────────────────────────────────────
              SliverFillRemaining(
                child: TabBarView(
                  children: [
                    _ArticleTab(articles: ArticleModel.mockFeed()),
                    _ArticleTab(articles: ArticleModel.mockTrending()),
                    _SavedTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Profil header ─────────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.ctrl});
  final ProfileController ctrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar + takip butonu
          Row(
            children: [
              AuthorAvatar(initials: ctrl.initials, size: 64),
              const Spacer(),
              if (!ctrl.isOwnProfile)
                Obx(
                  () => _FollowButton(
                    isFollowing: ctrl.isFollowing.value,
                    onTap: ctrl.toggleFollow,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // İsim
          Text(
            ctrl.displayName,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              fontFamily: 'Georgia',
              color: context.appColors.text,
            ),
          ),
          const SizedBox(height: 2),

          // Kullanıcı adı
          Text(
            '@${ctrl.username}',
            style: TextStyle(fontSize: 13, color: context.appColors.textSub),
          ),
          const SizedBox(height: 10),

          // Biyografi
          Text(
            ctrl.bio,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: context.appColors.text,
            ),
          ),
          const SizedBox(height: 16),

          // İstatistikler satırı
          Row(
            children: [
              _StatItem(value: ctrl.articleCount.toString(), label: 'Yazı'),
              const SizedBox(width: 24),
              GestureDetector(
                onTap: () => Get.toNamed('/followers'),
                child: _StatItem(value: ctrl.followerCount, label: 'Takipçi'),
              ),
              const SizedBox(width: 24),
              _StatItem(value: ctrl.followingCount, label: 'Takip'),
            ],
          ),
          const SizedBox(height: 16),

          // Kendi profili — istatistikler banner — US-021
          if (ctrl.isOwnProfile) _StatsCard(),

          const Divider(height: 24),
        ],
      ),
    );
  }
}

// ── Stat item ─────────────────────────────────────────────────────────────────

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: context.appColors.text,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: context.appColors.textSub),
        ),
      ],
    );
  }
}

// ── İstatistikler mini kartı — US-021 ────────────────────────────────────────

class _StatsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final stats = [
      {'label': 'Görüntülenme', 'value': '4.2K'},
      {'label': 'Toplam Clap', 'value': '634'},
      {'label': 'Ort. Okuma', 'value': '3.8 dk'},
    ];
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.appColors.border, width: 0.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: stats
            .map(
              (s) => Column(
                children: [
                  Text(
                    s['value']!,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: context.appColors.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    s['label']!,
                    style: TextStyle(
                      fontSize: 10,
                      color: context.appColors.textSub,
                    ),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}

// ── Follow button ─────────────────────────────────────────────────────────────

class _FollowButton extends StatelessWidget {
  const _FollowButton({required this.isFollowing, required this.onTap});
  final bool isFollowing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: isFollowing
            ? context.appColors.surface
            : context.appColors.text,
        foregroundColor: isFollowing
            ? context.appColors.text
            : context.appColors.bg,
        side: isFollowing
            ? BorderSide(color: context.appColors.borderMid, width: 0.5)
            : null,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        elevation: 0,
      ),
      child: Text(
        isFollowing ? 'Takip ediliyor' : 'Takip et',
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ── Makale sekmesi ────────────────────────────────────────────────────────────

class _ArticleTab extends StatelessWidget {
  const _ArticleTab({required this.articles});
  final List<ArticleModel> articles;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: articles.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        indent: 20,
        endIndent: 20,
        color: context.appColors.border,
      ),
      itemBuilder: (_, i) {
        final a = articles[i];
        return MiniArticleCard(
          title: a.title,
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

// ── Kayıtlar sekmesi — US-018 ────────────────────────────────────────────────

class _SavedTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final saved = ArticleModel.mockFeed()
        .where((a) => a.clapCount > 100)
        .toList();
    if (saved.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_border_rounded,
              size: 40,
              color: context.appColors.textHint,
            ),
            const SizedBox(height: 12),
            Text(
              'Henüz kayıt yok',
              style: TextStyle(color: context.appColors.textSub, fontSize: 14),
            ),
            const SizedBox(height: 6),
            Text(
              'Makaleleri kaydet, burada listele.',
              style: TextStyle(color: context.appColors.textHint, fontSize: 12),
            ),
          ],
        ),
      );
    }
    return _ArticleTab(articles: saved);
  }
}

// ── Sticky tab bar delegate ───────────────────────────────────────────────────

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  const _StickyTabBarDelegate(this.tabBar);
  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height + 0.5;
  @override
  double get maxExtent => tabBar.preferredSize.height + 0.5;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          tabBar,
          Divider(height: 0.5, thickness: 0.5, color: context.appColors.border),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate old) => tabBar != old.tabBar;
}
