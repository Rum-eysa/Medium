// ============================================================================
// ARTICLE MODEL
// ============================================================================
// Dosya: features/home/models/article_model.dart

class ArticleModel {
  const ArticleModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.authorId,
    required this.authorName,
    required this.authorInitials,
    required this.readingMinutes,
    this.tag,
    this.clapCount = 0,
    this.isClapped = false,
    this.isMemberOnly = false,
    this.isBookmarked = false,
    this.coverImageUrl,
    this.authorImageUrl,
    this.publishedAt,
  });

  final String id;
  final String title;
  final String subtitle;
  final String authorId;
  final String authorName;
  final String authorInitials;
  final int readingMinutes;
  final String? tag;
  final int clapCount;
  final bool isClapped;
  final bool isMemberOnly;
  final bool isBookmarked;
  final String? coverImageUrl;
  final String? authorImageUrl;
  final DateTime? publishedAt;

  ArticleModel copyWith({
    bool? isBookmarked,
    int? clapCount,
    bool? isClapped,
    bool? isMemberOnly,
    String? coverImageUrl,
    String? authorImageUrl,
    DateTime? publishedAt,
  }) => ArticleModel(
    id: id,
    title: title,
    subtitle: subtitle,
    authorId: authorId,
    authorName: authorName,
    authorInitials: authorInitials,
    readingMinutes: readingMinutes,
    tag: tag,
    clapCount: clapCount ?? this.clapCount,
    isClapped: isClapped ?? this.isClapped,
    isMemberOnly: isMemberOnly ?? this.isMemberOnly,
    isBookmarked: isBookmarked ?? this.isBookmarked,
    coverImageUrl: coverImageUrl ?? this.coverImageUrl,
    authorImageUrl: authorImageUrl ?? this.authorImageUrl,
    publishedAt: publishedAt ?? this.publishedAt,
  );

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    final author = json['author'] as Map<String, dynamic>?;
    final authorName =
        author?['display_name'] ?? author?['username'] ?? 'Yazar';
    final authorInitials = authorName
        .split(' ')
        .map((part) => part.isNotEmpty ? part[0] : '')
        .take(2)
        .join()
        .toUpperCase();

    return ArticleModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      authorId: author?['id']?.toString() ?? '',
      authorName: authorName,
      authorInitials: authorInitials.isNotEmpty ? authorInitials : 'Y',
      readingMinutes: json['reading_time_minutes'] is int
          ? json['reading_time_minutes']
          : int.tryParse(json['reading_time_minutes']?.toString() ?? '') ?? 1,
      tag: (json['tags'] is List && (json['tags'] as List).isNotEmpty)
          ? (json['tags'] as List).first['name']?.toString()
          : null,
      clapCount: json['clap_count'] is int
          ? json['clap_count']
          : int.tryParse(json['clap_count']?.toString() ?? '') ?? 0,
      isMemberOnly:
          json['is_member_only'] == true || json['status'] == 'member',
      isBookmarked: json['is_bookmarked'] == true,
      coverImageUrl: json['cover_image_url'] ?? json['coverUrl'],
      authorImageUrl: author?['photo_url'],
      publishedAt: json['published_at'] != null
          ? DateTime.tryParse(json['published_at'].toString())
          : null,
    );
  }

  // Mock data factory
  static List<ArticleModel> mockFeed() => [
    ArticleModel(
      id: '1',
      authorId: 'a1',
      title: 'Flutter ile Clean Architecture: GetX ve Katmanlı Yapı',
      subtitle:
          'State yönetimini doğru kurmak projenin geleceğini belirler. Dependency injection, repository pattern ve controller katmanı.',
      authorName: 'Ahmet Yılmaz',
      authorInitials: 'AY',
      readingMinutes: 4,
      tag: 'Flutter',
      clapCount: 142,
      coverImageUrl: 'https://picsum.photos/seed/flutter1/320/220',
      authorImageUrl: 'https://i.pravatar.cc/150?img=12',
      publishedAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    ArticleModel(
      id: '2',
      authorId: 'a2',
      title: 'Dart\'ta Sealed Classes ile Tip Güvenli State Yönetimi',
      subtitle:
          'Result, Either pattern\'larını Dart 3\'ün sealed class\'larıyla nasıl uygularsınız?',
      authorName: 'Elif Kaya',
      authorInitials: 'EK',
      readingMinutes: 7,
      tag: 'Dart',
      clapCount: 89,
      isMemberOnly: true,
      coverImageUrl: 'https://picsum.photos/seed/dart2/320/220',
      authorImageUrl: 'https://i.pravatar.cc/150?img=35',
      publishedAt: DateTime.now().subtract(const Duration(hours: 8)),
    ),
    ArticleModel(
      id: '3',
      authorId: 'a3',
      title: 'pgvector ile Semantik Arama Sistemi Kurma',
      subtitle:
          'OpenAI embedding\'leri ve PostgreSQL pgvector extension ile benzerlik araması.',
      authorName: 'Mert Öztürk',
      authorInitials: 'MÖ',
      readingMinutes: 5,
      tag: 'AI',
      clapCount: 203,
      coverImageUrl: 'https://picsum.photos/seed/ai3/320/220',
      authorImageUrl: 'https://i.pravatar.cc/150?img=17',
      publishedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    ArticleModel(
      id: '4',
      authorId: 'a4',
      title: 'Supabase ile Gerçek Zamanlı Flutter Uygulaması',
      subtitle: 'Realtime subscription, auth ve storage — hepsi tek backendde.',
      authorName: 'Selin Arslan',
      authorInitials: 'SA',
      readingMinutes: 6,
      tag: 'Backend',
      clapCount: 67,
      coverImageUrl: 'https://picsum.photos/seed/backend4/320/220',
      authorImageUrl: 'https://i.pravatar.cc/150?img=49',
      publishedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    ArticleModel(
      id: '5',
      authorId: 'a5',
      title: 'Riverpod\'dan GetX\'e Geçiş: Fırsatlar ve Tuzaklar',
      subtitle: 'İki state management yaklaşımının karşılaştırmalı analizi.',
      authorName: 'Can Demir',
      authorInitials: 'CD',
      readingMinutes: 9,
      tag: 'Flutter',
      clapCount: 311,
      isMemberOnly: true,
      coverImageUrl: 'https://picsum.photos/seed/flutter5/320/220',
      authorImageUrl: 'https://i.pravatar.cc/150?img=63',
      publishedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  static List<ArticleModel> mockTrending() =>
      mockFeed().toList()..sort((a, b) => b.clapCount.compareTo(a.clapCount));
}
