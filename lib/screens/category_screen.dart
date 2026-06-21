import 'package:flutter/material.dart';

import '../data/models.dart';
import '../widgets/verse_tile.dart';

/// Lista de versículos de uma categoria.
class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key, required this.category});

  final VerseCategory category;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${category.emoji}  ${category.name}')),
      body: ListView.builder(
        padding: const EdgeInsets.only(top: 12, bottom: 24),
        itemCount: category.verses.length,
        itemBuilder: (context, i) => VerseTile(verse: category.verses[i]),
      ),
    );
  }
}
