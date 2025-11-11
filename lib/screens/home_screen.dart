import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/book_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/book_list_item.dart';
import 'book_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _doSearch(String query) async {
    final prov = context.read<BookProvider>();
    await prov.search(query.trim().isEmpty ? 'flutter' : query.trim());
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<BookProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Books'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              // navigate back to login
              if (mounted) Navigator.pushReplacementNamed(context, '/');
            },
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    onSubmitted: _doSearch,
                    decoration: InputDecoration(
                      hintText: 'Search books',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          _doSearch('flutter');
                        },
                      ),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _doSearch(_searchCtrl.text),
                  child: const Text('Go'),
                )
              ],
            ),
          ),
        ),
      ),
      body: prov.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              itemCount: prov.books.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final book = prov.books[i];
                return BookListItem(
                  book: book,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookDetailScreen(book: book),
                    ),
                  ),
                );
              },
            ),
    );
  }
}