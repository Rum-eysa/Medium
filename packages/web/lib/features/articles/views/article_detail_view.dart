// ============================================================================
// ARTICLE DETAIL VIEW — Makale okuma ekranı
// ============================================================================
// Dosya: features/article/views/article_detail_view.dart
//
// US-009 Okuma Süresi Tahmini
// US-014 Makale Beğenme (Clap) — tek alkış / geri al
// US-015 Yorum Yazma
// US-016 Yazar Takibi
// US-018 Okuma Listesine Kaydetme
// US-023 Premium İçerik Kilidi (paywall)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../home/models/article_model.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../../core/widgets/app_colors_ext.dart';
import 'comments_sheet.dart';

class ArticleDetailView extends StatefulWidget {
  const ArticleDetailView({super.key, required this.article});
  final ArticleModel article;

  @override
  State<ArticleDetailView> createState() => _ArticleDetailViewState();
}

class _ArticleDetailViewState extends State<ArticleDetailView> {
  final _scrollCtrl = ScrollController();

  bool _isFollowing = false;
  bool _isBookmarked = false;
  int _clapCount = 0;
  int _myClaps = 0;
  bool _appBarVisible = true;
  double _lastOffset = 0;

  @override
  void initState() {
    super.initState();
    _clapCount = widget.article.clapCount;
    _myClaps = widget.article.isClapped ? 1 : 0;
    _isBookmarked = widget.article.isBookmarked;
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    final offset = _scrollCtrl.offset;
    final goingDown = offset > _lastOffset;
    _lastOffset = offset;
    if (goingDown && _appBarVisible && offset > 80) {
      setState(() => _appBarVisible = false);
    } else if (!goingDown && !_appBarVisible) {
      setState(() => _appBarVisible = true);
    }
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _clap() {
    HapticFeedback.lightImpact();
    setState(() {
      final willClap = _myClaps == 0;
      _myClaps = willClap ? 1 : 0;
      _clapCount = (_clapCount + (willClap ? 1 : -1)).clamp(0, 1 << 31);
    });
  }

  void _toggleBookmark() {
    HapticFeedback.lightImpact();
    setState(() => _isBookmarked = !_isBookmarked);
  }

  void _toggleFollow() {
    HapticFeedback.mediumImpact();
    setState(() => _isFollowing = !_isFollowing);
  }

  @override
  Widget build(BuildContext context) {
    final article = widget.article;

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollCtrl,
        slivers: [
          // ── App bar ───────────────────────────────────────────────────────
          SliverAppBar(
            floating: true,
            snap: true,
            actions: [
              BookmarkButton(
                isBookmarked: _isBookmarked,
                onTap: _toggleBookmark,
              ),
              IconButton(
                icon: const Icon(Icons.more_horiz, size: 20),
                onPressed: () {},
              ),
              const SizedBox(width: 4),
            ],
          ),

          // ── Makale içeriği ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // Başlık
                  Text(
                    article.title,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),

                  // Subtitle
                  Text(
                    article.subtitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Yazar satırı — US-016
                  _AuthorRow(
                    initials: article.authorInitials,
                    name: article.authorName,
                    minutes: article.readingMinutes,
                    isFollowing: _isFollowing,
                    onFollow: _toggleFollow,
                  ),

                  const Divider(height: 32),

                  // Premium paywall — US-023
                  if (article.isMemberOnly) ...[
                    _PaywallBanner(preview: _mockBody().substring(0, 200)),
                    const SizedBox(height: 32),
                  ] else ...[
                    // Makale gövdesi
                    Text(
                      _mockBody(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 40),

                    // Etiket
                    if (article.tag != null) TagChip(label: article.tag!),

                    const SizedBox(height: 32),
                    const Divider(height: 1),
                    const SizedBox(height: 32),

                    // Clap alanı
                    _ClapArea(
                      clapCount: _clapCount,
                      myClaps: _myClaps,
                      onClap: _clap,
                    ),

                    const SizedBox(height: 20),
                    const Divider(height: 1),

                    // İlgili makaleler — US-034
                    _RelatedSection(),
                  ],

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),

      // ── Bottom bar — clap + comment + bookmark ───────────────────────────
      bottomNavigationBar: _ArticleBottomBar(
        clapCount: _clapCount,
        myClaps: _myClaps,
        isBookmarked: _isBookmarked,
        onClap: _clap,
        onComment: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => CommentsSheet(articleId: article.id),
        ),
        onBookmark: _toggleBookmark,
      ),
    );
  }

  String _mockBody() => '''
Clean Architecture, yazılım geliştirmede sorumlulukların net biçimde ayrıldığı bir tasarım yaklaşımıdır. Robert C. Martin tarafından tanımlanan bu yaklaşım, bağımlılıkların yalnızca içten dışa doğru akması gerektiğini savunur.

Flutter projelerinde bu yaklaşımı uyguladığınızda üç temel katman ortaya çıkar: Presentation, Domain ve Data. Her katmanın kendine özgü sorumlulukları ve bağımlılık kuralları vardır.

**Presentation Katmanı**

Bu katman, kullanıcı arayüzü widget'larını ve state yönetimini barındırır. GetX kullandığınızda Controller sınıfları bu katmanda yer alır. Controller, iş mantığından tamamen yalıtılmış olmalı; yalnızca UseCase çağrıları yapmalı ve UI state'ini yönetmelidir.

**Domain Katmanı**

Uygulamanın kalbidir. Repository arayüzleri, entity sınıfları ve use case'ler burada tanımlanır. Bu katman hiçbir framework'e bağımlı değildir — ne Flutter'a ne de GetX'e.

**Data Katmanı**

Repository implementasyonları, API client'ları ve local storage adaptörleri bu katmanda bulunur. Dış dünyayla tüm iletişim buradan yönetilir.

Bu yapıyı doğru kurduğunuzda birim testler yazmak son derece kolaylaşır. Domain katmanını tamamen bağımsız test edebilir, mock repository'lerle presentation katmanını izole edebilirsiniz.
''';
}

// ── Author row ────────────────────────────────────────────────────────────────

class _AuthorRow extends StatelessWidget {
  const _AuthorRow({
    required this.initials,
    required this.name,
    required this.minutes,
    required this.isFollowing,
    required this.onFollow,
  });

  final String initials;
  final String name;
  final int minutes;
  final bool isFollowing;
  final VoidCallback onFollow;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AuthorAvatar(initials: initials, size: 40),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: context.appColors.text,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  ReadingTimeBadge(minutes: minutes),
                  Text(
                    ' · ',
                    style: TextStyle(color: context.appColors.textHint),
                  ),
                  Text(
                    _formattedDate(),
                    style: TextStyle(
                      fontSize: 11,
                      color: context.appColors.textSub,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Takip butonu — US-016
        OutlinedButton(
          onPressed: onFollow,
          style: OutlinedButton.styleFrom(
            backgroundColor: isFollowing
                ? Colors.transparent
                : context.appColors.text,
            foregroundColor: isFollowing
                ? context.appColors.text
                : context.appColors.bg,
            side: BorderSide(color: context.appColors.borderMid, width: 0.5),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            isFollowing ? 'Takip ediliyor' : 'Takip et',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  String _formattedDate() {
    final now = DateTime.now();
    return '${now.day} ${_monthName(now.month)}';
  }

  String _monthName(int m) {
    const months = [
      '',
      'Oca',
      'Şub',
      'Mar',
      'Nis',
      'May',
      'Haz',
      'Tem',
      'Ağu',
      'Eyl',
      'Eki',
      'Kas',
      'Ara',
    ];
    return months[m];
  }
}

// ── Clap alanı ───────────────────────────────────────────────────────────────

class _ClapArea extends StatelessWidget {
  const _ClapArea({
    required this.clapCount,
    required this.myClaps,
    required this.onClap,
  });
  final int clapCount;
  final int myClaps;
  final VoidCallback onClap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$clapCount alkış',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: context.appColors.text,
              ),
            ),
            if (myClaps > 0)
              Text(
                'Alkışladın',
                style: TextStyle(
                  fontSize: 11,
                  color: context.appColors.textSub,
                ),
              ),
          ],
        ),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: onClap,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: context.appColors.borderMid,
                width: 0.5,
              ),
            ),
            child: ClapMark(
              size: 20,
              color: myClaps > 0
                  ? Theme.of(context).colorScheme.secondary
                  : context.appColors.textSub,
              filled: myClaps > 0,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Paywall — US-023 ─────────────────────────────────────────────────────────

class _PaywallBanner extends StatelessWidget {
  const _PaywallBanner({required this.preview});
  final String preview;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // İlk 150 kelime önizleme
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              context.appColors.text,
              context.appColors.text.withOpacity(0),
            ],
          ).createShader(bounds),
          blendMode: BlendMode.dstIn,
          child: Text(preview, style: Theme.of(context).textTheme.bodyMedium),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: context.appColors.surface,
            border: Border.all(color: context.appColors.border, width: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.star_rounded,
                size: 32,
                color: Color(0xFFF59E0B),
              ),
              const SizedBox(height: 12),
              Text(
                'Bu makale yalnızca üyelere açık',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Georgia',
                  color: context.appColors.text,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Tüm premium içeriklere sınırsız erişim için üye ol.',
                style: TextStyle(
                  fontSize: 13,
                  color: context.appColors.textSub,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.toNamed('/membership'),
                  child: const Text('Üyeliği başlat'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Related articles — US-034 ────────────────────────────────────────────────

class _RelatedSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final related = ArticleModel.mockFeed().take(3).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionDivider(label: 'BUNLARI DA OKU'),
        ...related.map(
          (a) => MiniArticleCard(
            title: a.title,
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
    );
  }
}

// ── Bottom action bar ─────────────────────────────────────────────────────────

class _ArticleBottomBar extends StatelessWidget {
  const _ArticleBottomBar({
    required this.clapCount,
    required this.myClaps,
    required this.isBookmarked,
    required this.onClap,
    required this.onComment,
    required this.onBookmark,
  });

  final int clapCount;
  final int myClaps;
  final bool isBookmarked;
  final VoidCallback onClap;
  final VoidCallback onComment;
  final VoidCallback onBookmark;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60 + MediaQuery.of(context).padding.bottom,
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: context.appColors.bg,
        border: Border(
          top: BorderSide(color: context.appColors.border, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Clap
          GestureDetector(
            onTap: onClap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClapMark(
                  size: 20,
                  color: myClaps > 0
                      ? Theme.of(context).colorScheme.secondary
                      : context.appColors.textSub,
                  filled: myClaps > 0,
                ),
                const SizedBox(width: 5),
                Text(
                  '$clapCount',
                  style: TextStyle(
                    fontSize: 13,
                    color: context.appColors.textSub,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          // Yorum — US-015
          GestureDetector(
            onTap: onComment,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 20,
                  color: context.appColors.textSub,
                ),
                const SizedBox(width: 5),
                Text(
                  'Yorumlar',
                  style: TextStyle(
                    fontSize: 13,
                    color: context.appColors.textSub,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Bookmark
          IconButton(
            icon: Icon(
              isBookmarked
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              size: 20,
              color: isBookmarked
                  ? context.appColors.text
                  : context.appColors.textSub,
            ),
            onPressed: onBookmark,
          ),
          // Paylaş
          IconButton(
            icon: Icon(
              Icons.ios_share_rounded,
              size: 20,
              color: context.appColors.textSub,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
