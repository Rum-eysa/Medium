// ============================================================================
// SHARED WIDGETS
// ============================================================================
// Dosya: core/widgets/shared_widgets.dart
//
// İçerik:
//   • ArticleCard        — feed, profil, trend listeleri
//   • MiniArticleCard    — yatay / kompakt liste
//   • TagChip            — etiket pill
//   • AuthorAvatar       — initials + photo destekli
//   • MemberBadge        — premium içerik rozeti
//   • ClapButton         — animasyonlu beğeni (US-014)
//   • BookmarkButton     — kaydetme (US-018)
//   • ReadingTimeBadge   — okuma süresi (US-009)
//   • SectionDivider     — ince ayırıcı
//   • AppLogo            — AppBar logo
// ============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors_ext.dart'; // BuildContext extension

// ── ArticleCard ─────────────────────────────────────────────────────────────

class ArticleCard extends StatelessWidget {
  const ArticleCard({
    super.key,
    required this.title,
    required this.subtitle,
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
    this.onTap,
    this.onBookmarkTap,
    this.onClapTap,
    this.onMoreTap,
  });

  final String title;
  final String subtitle;
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
  final VoidCallback? onTap;
  final VoidCallback? onBookmarkTap;
  final VoidCallback? onClapTap;
  final VoidCallback? onMoreTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Yazar satırı ───────────────────────────────────────────────
            Row(
              children: [
                AuthorAvatar(
                  initials: authorInitials,
                  imageUrl: authorImageUrl,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    authorName,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isMemberOnly) ...[
                  const SizedBox(width: 8),
                  const MemberBadge(),
                ],
              ],
            ),
            const SizedBox(height: 10),

            // ── İçerik + kapak ────────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                if (coverImageUrl != null || true) ...[
                  const SizedBox(width: 16),
                  _CoverImage(imageUrl: coverImageUrl),
                ],
              ],
            ),
            const SizedBox(height: 12),

            // ── Alt bilgi satırı ──────────────────────────────────────────
            Row(
              children: [
                if (tag != null) ...[
                  TagChip(label: tag!),
                  const SizedBox(width: 8),
                ],
                ReadingTimeBadge(minutes: readingMinutes),
                const Spacer(),
                ClapButton(
                  count: clapCount,
                  isClapped: isClapped,
                  onTap: onClapTap,
                ),
                const SizedBox(width: 4),
                BookmarkButton(
                  isBookmarked: isBookmarked,
                  onTap: onBookmarkTap,
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz, size: 18),
                  onPressed: onMoreTap,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Cover image placeholder ─────────────────────────────────────────────────

class _CoverImage extends StatelessWidget {
  const _CoverImage({this.imageUrl});
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: context.appColors.surface,
        image: imageUrl != null
            ? DecorationImage(image: NetworkImage(imageUrl!), fit: BoxFit.cover)
            : null,
      ),
      child: imageUrl == null
          ? Icon(
              Icons.image_outlined,
              size: 24,
              color: context.appColors.textHint,
            )
          : null,
    );
  }
}

// ── MiniArticleCard (profil yazı listesi) ──────────────────────────────────

class MiniArticleCard extends StatelessWidget {
  const MiniArticleCard({
    super.key,
    required this.title,
    required this.readingMinutes,
    this.tag,
    this.clapCount = 0,
    this.isMemberOnly = false,
    this.onTap,
  });

  final String title;
  final int readingMinutes;
  final String? tag;
  final int clapCount;
  final bool isMemberOnly;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(fontSize: 15),
                  ),
                ),
                if (isMemberOnly) ...[
                  const SizedBox(width: 8),
                  const MemberBadge(),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (tag != null) ...[
                  TagChip(label: tag!),
                  const SizedBox(width: 8),
                ],
                ReadingTimeBadge(minutes: readingMinutes),
                const SizedBox(width: 12),
                ClapMark(size: 14, color: context.appColors.textSub),
                const SizedBox(width: 3),
                Text(
                  '$clapCount',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── TagChip ─────────────────────────────────────────────────────────────────

class TagChip extends StatelessWidget {
  const TagChip({super.key, required this.label, this.onTap});
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: context.appColors.tag,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: context.appColors.tagText,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ── AuthorAvatar ─────────────────────────────────────────────────────────────

class AuthorAvatar extends StatelessWidget {
  const AuthorAvatar({
    super.key,
    required this.initials,
    this.imageUrl,
    this.size = 36,
  });

  final String initials;
  final String? imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE8E8E8),
        image: imageUrl != null
            ? DecorationImage(image: NetworkImage(imageUrl!), fit: BoxFit.cover)
            : null,
      ),
      child: imageUrl == null
          ? Center(
              child: Text(
                initials.length > 2 ? initials.substring(0, 2) : initials,
                style: TextStyle(
                  fontSize: size * 0.35,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? const Color(0xFF888888)
                      : const Color(0xFF666666),
                ),
              ),
            )
          : null,
    );
  }
}

// ── MemberBadge ─────────────────────────────────────────────────────────────

class MemberBadge extends StatelessWidget {
  const MemberBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFFFFBEB),
        border: Border.all(
          color: isDark ? const Color(0xFF333333) : const Color(0xFFFDE68A),
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 10, color: const Color(0xFFF59E0B)),
          const SizedBox(width: 3),
          Text(
            'Üye',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFF59E0B) : const Color(0xFFB45309),
            ),
          ),
        ],
      ),
    );
  }
}

// ── ClapButton — US-014 ──────────────────────────────────────────────────────

class ClapButton extends StatefulWidget {
  const ClapButton({
    super.key,
    this.count = 0,
    this.isClapped = false,
    this.onTap,
  });
  final int count;
  final bool isClapped;
  final VoidCallback? onTap;

  @override
  State<ClapButton> createState() => _ClapButtonState();
}

class _ClapButtonState extends State<ClapButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scale = Tween<double>(
      begin: 1,
      end: 1.35,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    _ctrl.forward().then((_) => _ctrl.reverse());
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _scale,
              child: ClapMark(
                size: 16,
                color: widget.isClapped
                    ? Theme.of(context).colorScheme.secondary
                    : context.appColors.textSub,
                filled: widget.isClapped,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              widget.count > 0 ? '${widget.count}' : '',
              style: TextStyle(
                fontSize: 12,
                color: widget.isClapped
                    ? Theme.of(context).colorScheme.secondary
                    : context.appColors.textSub,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ClapMark extends StatelessWidget {
  const ClapMark({
    super.key,
    required this.size,
    required this.color,
    this.filled = false,
  });

  final double size;
  final Color color;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final icon = filled ? Icons.back_hand_rounded : Icons.back_hand_outlined;
    return SizedBox(
      width: size * 1.45,
      height: size * 1.15,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: size * 0.02,
            top: size * 0.08,
            child: Transform.rotate(
              angle: -math.pi / 12,
              child: Icon(icon, size: size, color: color),
            ),
          ),
          Positioned(
            right: size * 0.02,
            top: 0,
            child: Transform.scale(
              scaleX: -1,
              child: Transform.rotate(
                angle: -math.pi / 12,
                child: Icon(icon, size: size, color: color),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── BookmarkButton — US-018 ──────────────────────────────────────────────────

class BookmarkButton extends StatefulWidget {
  const BookmarkButton({super.key, this.isBookmarked = false, this.onTap});
  final bool isBookmarked;
  final VoidCallback? onTap;

  @override
  State<BookmarkButton> createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends State<BookmarkButton> {
  late bool _saved;

  @override
  void initState() {
    super.initState();
    _saved = widget.isBookmarked;
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        _saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
        size: 18,
        color: _saved
            ? Theme.of(context).colorScheme.primary
            : context.appColors.textSub,
      ),
      onPressed: () {
        HapticFeedback.lightImpact();
        setState(() => _saved = !_saved);
        widget.onTap?.call();
      },
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
    );
  }
}

// ── ReadingTimeBadge — US-009 ────────────────────────────────────────────────

class ReadingTimeBadge extends StatelessWidget {
  const ReadingTimeBadge({super.key, required this.minutes});
  final int minutes;

  @override
  Widget build(BuildContext context) {
    return Text(
      '$minutes dk okuma',
      style: Theme.of(context).textTheme.labelSmall,
    );
  }
}

// ── SectionDivider ───────────────────────────────────────────────────────────

class SectionDivider extends StatelessWidget {
  const SectionDivider({super.key, this.label});
  final String? label;

  @override
  Widget build(BuildContext context) {
    if (label == null) return const Divider(height: 1);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Text(
            label!,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: context.appColors.textSub,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Divider(color: context.appColors.border, thickness: 0.5),
          ),
        ],
      ),
    );
  }
}

// ── AppLogo ──────────────────────────────────────────────────────────────────

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 22});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Text(
      'Blogify',
      style: TextStyle(
        fontSize: size,
        fontWeight: FontWeight.w700,
        fontFamily: 'Georgia',
        letterSpacing: -0.5,
        color: Theme.of(context).textTheme.titleLarge?.color,
      ),
    );
  }
}
