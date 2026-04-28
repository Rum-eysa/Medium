import 'package:flutter/material.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bildirimler')),
      body: ListView.builder(
        itemCount: 5,
        itemBuilder: (_, index) => ListTile(
          leading: const CircleAvatar(
            child: Icon(Icons.favorite),
          ),
          title: const Text('Birisi makaleni beğendi'),
          subtitle: const Text('2 saat önce'),
          onTap: () {},
        ),
      ),
    );
  }
}