import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../home/models/article_model.dart';
import '../../articles/views/article_detail_view.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../../core/widgets/app_colors_ext.dart';

const _backlogMaxWidth = 820.0;

class TagArticlesView extends StatelessWidget {
  const TagArticlesView({super.key, required this.tag});

  final String tag;

  @override
  Widget build(BuildContext context) {
    final articles = ArticleModel.mockFeed()
        .where((article) => article.tag?.toLowerCase() == tag.toLowerCase())
        .toList();
    final visibleArticles = articles.isEmpty
        ? ArticleModel.mockFeed()
        : articles;

    return Scaffold(
      appBar: AppBar(title: Text('#$tag')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _backlogMaxWidth),
          child: ListView.separated(
            itemCount: visibleArticles.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              indent: 20,
              endIndent: 20,
              color: context.appColors.border,
            ),
            itemBuilder: (_, index) {
              final article = visibleArticles[index];
              return ArticleCard(
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
                onTap: () => Get.to(() => ArticleDetailView(article: article)),
              );
            },
          ),
        ),
      ),
    );
  }
}

class ArticleRouteView extends StatelessWidget {
  const ArticleRouteView({super.key, required this.articleId});

  final String articleId;

  @override
  Widget build(BuildContext context) {
    final article = ArticleModel.mockFeed().firstWhere(
      (item) => item.id == articleId,
      orElse: () => ArticleModel.mockFeed().first,
    );

    return ArticleDetailView(article: article);
  }
}

class MembershipView extends StatelessWidget {
  const MembershipView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Üyelik')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Blogify Üyelik',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Sınırsız premium makale, yazar desteği ve reklamsız okuma.',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 20),
              _PlanTile(
                title: 'Aylık',
                price: '₺79',
                subtitle: 'Her ay yenilenir',
                selected: true,
              ),
              const SizedBox(height: 12),
              _PlanTile(
                title: 'Yıllık',
                price: '₺699',
                subtitle: '2 ay ücretsiz',
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () => Get.snackbar('Üyelik', 'Ödeme akışı hazır.'),
                icon: const Icon(Icons.credit_card),
                label: const Text('Devam et'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanTile extends StatelessWidget {
  const _PlanTile({
    required this.title,
    required this.price,
    required this.subtitle,
    this.selected = false,
  });

  final String title;
  final String price;
  final String subtitle;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: selected
              ? Theme.of(context).colorScheme.secondary
              : context.appColors.borderMid,
        ),
        color: context.appColors.surface,
      ),
      child: Row(
        children: [
          Icon(
            selected ? Icons.radio_button_checked : Icons.radio_button_off,
            color: selected
                ? Theme.of(context).colorScheme.secondary
                : context.appColors.textSub,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Text(price, style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }
}

class FollowersView extends StatelessWidget {
  const FollowersView({super.key});

  @override
  Widget build(BuildContext context) {
    final people = [
      ('Elif Kaya', 'EK'),
      ('Mert Öztürk', 'MÖ'),
      ('Selin Arslan', 'SA'),
      ('Can Demir', 'CD'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Takipçiler')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView.separated(
            itemCount: people.length,
            separatorBuilder: (_, __) =>
                Divider(height: 1, color: context.appColors.border),
            itemBuilder: (_, index) {
              final person = people[index];
              return ListTile(
                leading: AuthorAvatar(initials: person.$2),
                title: Text(person.$1),
                subtitle: const Text('Yazar'),
                trailing: OutlinedButton(
                  onPressed: () {},
                  child: const Text('Takip et'),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class ProfileEditView extends StatefulWidget {
  const ProfileEditView({super.key});

  @override
  State<ProfileEditView> createState() => _ProfileEditViewState();
}

class _ProfileEditViewState extends State<ProfileEditView> {
  final nameCtrl = TextEditingController(text: 'Ahmet Yılmaz');
  final usernameCtrl = TextEditingController(text: 'ahmetyilmaz');
  final bioCtrl = TextEditingController(
    text: 'Flutter developer. Açık kaynak meraklısı.',
  );

  @override
  void dispose() {
    nameCtrl.dispose();
    usernameCtrl.dispose();
    bioCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profili Düzenle'),
        actions: [
          TextButton(
            onPressed: () {
              Get.snackbar('Profil', 'Profil bilgileri kaydedildi.');
              Get.back();
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Center(child: AuthorAvatar(initials: 'AY', size: 84)),
              const SizedBox(height: 20),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Ad'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: usernameCtrl,
                decoration: const InputDecoration(labelText: 'Kullanıcı adı'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bioCtrl,
                maxLength: 160,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'Biyografi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
