enum ArticleStatus { draft, published, archived }

class ArticleModel {
  final String id;
  final String title;
  final String? subtitle;
  final String content;
  final String? coverImageUrl;
  final String? slug;
  final ArticleStatus status;
  final int readingTimeMinutes;
  final int viewCount;
  final int clapCount;
  final UserPreviewModel author;
  final List<TagModel> tags;
  final DateTime createdAt;
  final DateTime? publishedAt;

  ArticleModel({
    required this.id,
    required this.title,
    this.subtitle,
    required this.content,
    this.coverImageUrl,
    this.slug,
    required this.status,
    required this.readingTimeMinutes,
    required this.viewCount,
    required this.clapCount,
    required this.author,
    required this.tags,
    required this.createdAt,
    this.publishedAt,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'],
      content: json['content'] ?? '',
      coverImageUrl: json['cover_image_url'],
      slug: json['slug'],
      status: _parseStatus(json['status']),
      readingTimeMinutes: json['reading_time_minutes'] ?? 1,
      viewCount: json['view_count'] ?? 0,
      clapCount: json['clap_count'] ?? 0,
      author: UserPreviewModel.fromJson(json['author'] ?? {}),
      tags: (json['tags'] as List?)?.map((t) => TagModel.fromJson(t)).toList() ?? [],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      publishedAt: json['published_at'] != null
          ? DateTime.parse(json['published_at'])
          : null,
    );
  }

  static ArticleStatus _parseStatus(String? status) {
    switch (status) {
      case 'published':
        return ArticleStatus.published;
      case 'archived':
        return ArticleStatus.archived;
      default:
        return ArticleStatus.draft;
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'subtitle': subtitle,
    'content': content,
    'cover_image_url': coverImageUrl,
    'slug': slug,
    'status': status.toString().split('.').last,
    'reading_time_minutes': readingTimeMinutes,
    'view_count': viewCount,
    'clap_count': clapCount,
    'author': author.toJson(),
    'tags': tags.map((t) => t.toJson()).toList(),
    'created_at': createdAt.toIso8601String(),
    'published_at': publishedAt?.toIso8601String(),
  };
}

class UserPreviewModel {
  final String id;
  final String username;
  final String? displayName;
  final String? photoUrl;

  UserPreviewModel({
    required this.id,
    required this.username,
    this.displayName,
    this.photoUrl,
  });

  factory UserPreviewModel.fromJson(Map<String, dynamic> json) {
    return UserPreviewModel(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      displayName: json['display_name'],
      photoUrl: json['photo_url'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'display_name': displayName,
    'photo_url': photoUrl,
  };
}

class TagModel {
  final String id;
  final String name;
  final String slug;

  TagModel({
    required this.id,
    required this.name,
    required this.slug,
  });

  factory TagModel.fromJson(Map<String, dynamic> json) {
    return TagModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'slug': slug,
  };
}