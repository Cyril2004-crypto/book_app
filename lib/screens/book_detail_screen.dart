import 'package:flutter/material.dart';

import '../models/book.dart';
import '../services/api_service.dart';
import '../providers/book_provider.dart';
import 'package:provider/provider.dart';

class BookDetailScreen extends StatefulWidget {
  final Book book;
  const BookDetailScreen({super.key, required this.book});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  late Book _book;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _book = widget.book;
    _fetchDetailsIfNeeded();
  }

  Future<void> _fetchDetailsIfNeeded() async {
    // if id looks like a work key (/works/OL...), fetch richer details
    if (_book.id.startsWith('/works/')) {
      setState(() => _loading = true);
      final api = ApiService();
      final updated = await api.fetchWorkDetails(_book.id, _book);
      setState(() {
        _book = updated;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<BookProvider>();
    final isFav = prov.isFavorite(_book.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(_book.title),
        actions: [
          IconButton(
            icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
            onPressed: () => prov.toggleFavorite(_book),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  if (_book.imageUrl.isNotEmpty)
                    Image.network(_book.imageUrl, height: 300, fit: BoxFit.cover),
                  const SizedBox(height: 12),
                  Text(_book.title, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text('By ${_book.author}', style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 12),
                  if (_book.description != null && _book.description!.isNotEmpty)
                    Text(_book.description!),
                  const SizedBox(height: 16),
                  if (_book.subjects.isNotEmpty) ...[
                    const Text('Subjects:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Wrap(
                      spacing: 8,
                      children: _book.subjects.map((s) => Chip(label: Text(s))).toList(),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Text('Published: ${_book.publishedDate}'),
                  const SizedBox(height: 8),
                  Text('Rating: ${_book.rating}'),
                ],
              ),
      ),
    );
  }
}