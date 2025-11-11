import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/book.dart';
import '../providers/book_provider.dart';

class BookDetailScreen extends StatelessWidget {
  final Book book;
  const BookDetailScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<BookProvider>();
    final isFav = prov.isFavorite(book.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(book.title),
        actions: [
          IconButton(
            icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
            onPressed: () => prov.toggleFavorite(book),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            if (book.imageUrl.isNotEmpty)
              Image.network(book.imageUrl, height: 240, fit: BoxFit.cover),
            const SizedBox(height: 12),
            Text(book.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('By ${book.author}', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 12),
            Text(book.description),
            const SizedBox(height: 16),
            Text('Published: ${book.publishedDate}'),
            const SizedBox(height: 8),
            Text('Rating: ${book.rating}'),
          ],
        ),
      ),
    );
  }
}