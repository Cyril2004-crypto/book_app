import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import '../widgets/book_list_item.dart';
import 'book_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});
  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  bool _exporting = false;

  Future<void> _export() async {
    setState(() => _exporting = true);
    final prov = context.read<BookProvider>();
    final path = await prov.exportFavoritesToFile();
    setState(() => _exporting = false);
    if (path != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Exported to $path')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Export failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<BookProvider>();
    final favs = prov.favorites;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        actions: [
          IconButton(
            icon: _exporting ? const SizedBox(width:20,height:20,child:CircularProgressIndicator(strokeWidth:2)) : const Icon(Icons.download),
            onPressed: _exporting ? null : _export,
            tooltip: 'Export favorites to JSON',
          )
        ],
      ),
      body: favs.isEmpty
          ? const Center(child: Text('No favorites yet'))
          : ListView.separated(
              itemCount: favs.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, i) {
                final book = favs[i];
                return Dismissible(
                  key: ValueKey(book.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    prov.removeFavorite(book.id);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Removed from favorites')));
                  },
                  child: BookListItem(
                    book: book,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => BookDetailScreen(book: book)),
                    ),
                  ),
                );
              },
            ),
    );
  }
}