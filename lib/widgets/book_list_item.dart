import 'package:flutter/material.dart';

import '../models/book.dart';

class BookListItem extends StatelessWidget {
  final Book book;
  final VoidCallback? onTap;

  const BookListItem({super.key, required this.book, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: book.imageUrl.isNotEmpty
          ? Image.network(book.imageUrl, width: 50, fit: BoxFit.cover)
          : Container(width: 50, height: 70, color: Colors.grey.shade200, child: const Icon(Icons.book)),
      title: Text(book.title),
      subtitle: Text(book.author),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}