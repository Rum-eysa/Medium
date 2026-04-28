import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchView extends StatefulWidget {
  const SearchView({Key? key}) : super(key: key);

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final searchCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: searchCtrl,
          decoration: const InputDecoration(
            hintText: 'Makale ara...',
            border: InputBorder.none,
          ),
          onSubmitted: (query) {
            // Search API call here
          },
        ),
      ),
      body: searchCtrl.text.isEmpty
          ? const Center(child: Text('Arama yapmak için bir şey yazın'))
          : const Center(child: CircularProgressIndicator()),
    );
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }
}