// ============================================================================
// COMMENTS SHEET — US-015 Yorum Yazma
// ============================================================================
// Dosya: features/article/views/comments_sheet.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../../core/widgets/app_colors_ext.dart';

class _Comment {
  const _Comment({
    required this.initials,
    required this.name,
    required this.text,
    required this.timeAgo,
  });
  final String initials;
  final String name;
  final String text;
  final String timeAgo;
}

class CommentsSheet extends StatefulWidget {
  const CommentsSheet({super.key, required this.articleId});
  final String articleId;

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  bool _sending = false;

  final _comments = <_Comment>[
    const _Comment(
      initials: 'SA',
      name: 'Selin Arslan',
      text:
          'Harika bir yazı, teşekkürler! Özellikle Domain katmanı kısmı çok açıklayıcı olmuş.',
      timeAgo: '2 saat önce',
    ),
    const _Comment(
      initials: 'CD',
      name: 'Can Demir',
      text:
          'GetX ile bu pattern\'ı nasıl uygulayabileceğimizi anlatan bir yazı daha yazabilir misin?',
      timeAgo: '45 dk önce',
    ),
  ];

  void _sendComment() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _sending = true);
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() {
      _comments.insert(
        0,
        _Comment(initials: 'AY', name: 'Sen', text: text, timeAgo: 'Az önce'),
      );
      _ctrl.clear();
      _sending = false;
    });
    _focus.unfocus();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: context.appColors.bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          border: Border(
            top: BorderSide(color: context.appColors.border, width: 0.5),
          ),
        ),
        child: Column(
          children: [
            // Drag handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: context.appColors.borderMid,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Başlık
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Text(
                    'Yorumlar',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: context.appColors.text,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: context.appColors.surface,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      '${_comments.length}',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.appColors.textSub,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: context.appColors.border),

            // Yorum listesi
            Expanded(
              child: ListView.separated(
                controller: scrollCtrl,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _comments.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  indent: 20,
                  endIndent: 20,
                  color: context.appColors.border,
                ),
                itemBuilder: (_, i) => _CommentTile(comment: _comments[i]),
              ),
            ),

            // Input alanı
            Divider(height: 1, color: context.appColors.border),
            _CommentInput(
              controller: _ctrl,
              focusNode: _focus,
              sending: _sending,
              onSend: _sendComment,
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment});
  final _Comment comment;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AuthorAvatar(initials: comment.initials, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: context.appColors.text,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      comment.timeAgo,
                      style: TextStyle(
                        fontSize: 11,
                        color: context.appColors.textSub,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  comment.text,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: context.appColors.text,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentInput extends StatelessWidget {
  const _CommentInput({
    required this.controller,
    required this.focusNode,
    required this.sending,
    required this.onSend,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool sending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 10,
        bottom: 10 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Row(
        children: [
          const AuthorAvatar(initials: 'AY', size: 32),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              maxLines: null,
              maxLength: 1000,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: 'Bir yorum ekle...',
                hintStyle: TextStyle(
                  color: context.appColors.textSub,
                  fontSize: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: context.appColors.border,
                    width: 0.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: context.appColors.border,
                    width: 0.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: context.appColors.text,
                    width: 1,
                  ),
                ),
                fillColor: context.appColors.surface,
                filled: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                counterText: '',
              ),
            ),
          ),
          const SizedBox(width: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: sending
                ? SizedBox(
                    width: 36,
                    height: 36,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: context.appColors.textSub,
                    ),
                  )
                : IconButton(
                    icon: Icon(
                      Icons.send_rounded,
                      color: context.appColors.text,
                    ),
                    onPressed: onSend,
                  ),
          ),
        ],
      ),
    );
  }
}
