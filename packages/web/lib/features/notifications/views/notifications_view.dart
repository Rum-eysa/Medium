import 'package:flutter/material.dart';
import '../../../core/widgets/app_colors_ext.dart';
import '../../../core/widgets/shared_widgets.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('AY', 'Ahmet yazını alkışladı', 'Flutter ile Clean Architecture', Icons.back_hand_outlined),
      ('EK', 'Elif seni takip etmeye başladı', 'Yeni takipçi', Icons.person_add_alt_1_outlined),
      ('MÖ', 'Mert yorum bıraktı', 'pgvector yazına yorum geldi', Icons.chat_bubble_outline_rounded),
      ('SA', 'Yeni makale yayında', 'Takip ettiğin yazardan yeni içerik', Icons.article_outlined),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Bildirimler')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: items.length,
            separatorBuilder: (_, __) =>
                Divider(height: 1, color: context.appColors.border),
            itemBuilder: (_, index) {
              final item = items[index];
              return ListTile(
                leading: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AuthorAvatar(initials: item.$1, size: 38),
                    Positioned(
                      right: -4,
                      bottom: -4,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: context.appColors.bg,
                          shape: BoxShape.circle,
                          border: Border.all(color: context.appColors.border),
                        ),
                        child: Icon(item.$4, size: 11, color: context.appColors.textSub),
                      ),
                    ),
                  ],
                ),
                title: Text(item.$2),
                subtitle: Text('${item.$3} · 2 saat önce'),
                trailing: Icon(Icons.chevron_right, color: context.appColors.textHint),
                onTap: () {},
              );
            },
          ),
        ),
      ),
    );
  }
}
