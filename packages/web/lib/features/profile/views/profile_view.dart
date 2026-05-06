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
import '../../auth/controllers/auth_controller.dart';
import '../controllers/profile_controller.dart';
import '../../home/models/article_model.dart';
import '../../articles/views/article_detail_view.dart';
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
    final tabCount = controller.isOwnProfile ? 4 : 3;
    return DefaultTabController(
      length: tabCount,
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
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 20),
                    color: context.appColors.surface,
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'logout',
                        child: Text('Çıkış Yap'),
                      ),
                      const PopupMenuItem(
                        value: 'logout_all',
                        child: Text('Tüm cihazlardan çıkış'),
                      ),
                    ],
                    onSelected: (value) {
                      final auth = Get.find<AuthController>();
                      if (value == 'logout_all') {
                        auth.logoutAll();
                      } else {
                        auth.logout();
                      }
                    },
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
              SliverToBoxAdapter(child: _ProfileHeader(ctrl: controller)),

              // ── Tab bar ────────────────────────────────────────────────────
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickyTabBarDelegate(
                  TabBar(
                    tabs: [
                      const Tab(text: 'Yazılar'),
                      const Tab(text: 'En Popüler'),
                      const Tab(text: 'Kayıtlar'),
                      if (controller.isOwnProfile)
                        const Tab(text: 'İstatistikler'),
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
                    if (controller.isOwnProfile) const _StatsTab(),
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

          // Kendi profili ise eylem kutusu
          if (ctrl.isOwnProfile) const _ProfileActionsCard(),
          if (ctrl.isOwnProfile) const SizedBox(height: 16),

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

// ── Profil aksiyon kartı ───────────────────────────────────────────────────

class _ProfileActionsCard extends StatelessWidget {
  const _ProfileActionsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Hesap menüsü',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          _ProfileActionTile(
            label: 'Ayarlar',
            subtitle: 'Profilini ve hesap tercihlerini düzenle',
            icon: Icons.settings_outlined,
            onTap: () => Get.toNamed('/profile/edit'),
          ),
          _ProfileActionTile(
            label: 'Yardım',
            subtitle: 'Sık sorulan sorular ve destek',
            icon: Icons.help_outline,
            onTap: () {
              Get.snackbar(
                'Yardım',
                'Yardım sayfası yakında eklenecek.',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
          _ProfileActionTile(
            label: 'Üyelik ol',
            subtitle: 'Medium üyelik ayrıcalıklarını gör',
            icon: Icons.star_border,
            onTap: () => Get.toNamed('/membership'),
          ),
          _ProfileActionTile(
            label: 'Partner program',
            subtitle: 'Ortaklık tekliflerine başvur',
            icon: Icons.handshake_outlined,
            onTap: () {
              Get.snackbar(
                'Partner Program',
                'Partner programı sayfası yakında aktif olacak.',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
          _ProfileActionTile(
            label: 'Çıkış Yap',
            subtitle:
                'Tüm cihazlardan çıkış yapabilir veya hesabı kapatabilirsin',
            icon: Icons.logout,
            onTap: () {
              final auth = Get.find<AuthController>();
              auth.logout();
            },
          ),
        ],
      ),
    );
  }
}

class _ProfileActionTile extends StatelessWidget {
  const _ProfileActionTile({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: context.appColors.border, width: 0.5),
              color: context.appColors.bg,
            ),
            child: Row(
              children: [
                Icon(icon, color: context.appColors.text, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: context.appColors.text,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: context.appColors.textSub,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Follow button ─────────────────────────────────────────────────────────────

class _StatsTab extends StatelessWidget {
  const _StatsTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'İstatistikler',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: context.appColors.text,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Yayın performansını ve okutma davranışını buradan takip edebilirsin.',
            style: TextStyle(fontSize: 14, color: context.appColors.textSub),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: context.appColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: context.appColors.border, width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Mayıs 2026',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Güncellenme saatlik',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.appColors.textSub,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: context.appColors.bg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      'Grafik yer tutucu',
                      style: TextStyle(color: context.appColors.textSub),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: const [
                    _MiniMetric(title: 'Presentations', value: '0'),
                    _MiniMetric(title: 'Views', value: '0'),
                    _MiniMetric(title: 'Reads', value: '0'),
                    _MiniMetric(title: 'Followers', value: '0'),
                    _MiniMetric(title: 'Subscribers', value: '0'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          _StatsSectionCard(
            title: 'Yayına hazır hikayeler',
            value: '0',
            details:
                'Henüz yayınlanmaya hazır bir yazın yok. “Yaz” butonuna tıklayarak başlayabilirsin.',
          ),
        ],
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({required this.title, required this.value});
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: context.appColors.bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: context.appColors.text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: context.appColors.textSub),
          ),
        ],
      ),
    );
  }
}

class _StatsSectionCard extends StatelessWidget {
  const _StatsSectionCard({
    required this.title,
    required this.value,
    required this.details,
  });
  final String title;
  final String value;
  final String details;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.appColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: context.appColors.text,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: context.appColors.text,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            details,
            style: TextStyle(
              fontSize: 13,
              color: context.appColors.textSub,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

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
      separatorBuilder: (context, index) => Divider(
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
