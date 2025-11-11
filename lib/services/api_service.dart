import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/book.dart';

class ApiService {
  // Open Library search endpoint (no API key required)
  static const String _base = 'https://openlibrary.org';

  /// Fetch books from Open Library. Provide a search [query] (defaults to 'flutter').
  Future<List<Book>> fetchBooks({String query = 'flutter'}) async {
    final uri = Uri.parse('$_base/search.json?q=${Uri.encodeQueryComponent(query)}&limit=20');

    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(res.body) as Map<String, dynamic>;
        final List docs = data['docs'] ?? [];

        return docs.map<Book>((raw) {
          final Map<String, dynamic> doc = Map<String, dynamic>.from(raw as Map);
          final String id = (doc['key'] ?? doc['cover_edition_key'] ?? (doc['isbn'] is List ? doc['isbn'][0] : null) ?? doc['title']).toString();
          final String title = (doc['title'] ?? 'Unknown Title').toString();
          final String author = (doc['author_name'] is List && (doc['author_name'] as List).isNotEmpty)
              ? (doc['author_name'][0] as String)
              : 'Unknown Author';
          // description may be a map or string in some endpoints; search results rarely include full desc
          String description = '';
          if (doc['first_sentence'] != null) {
            if (doc['first_sentence'] is Map && doc['first_sentence']['value'] != null) {
              description = doc['first_sentence']['value'].toString();
            } else {
              description = doc['first_sentence'].toString();
            }
          }
          final String publishedDate = doc['first_publish_year'] != null ? doc['first_publish_year'].toString() : '';
          String imageUrl = '';
          if (doc['cover_i'] != null) {
            imageUrl = 'https://covers.openlibrary.org/b/id/${doc['cover_i']}-L.jpg';
          } else if (doc['isbn'] is List && (doc['isbn'] as List).isNotEmpty) {
            // attempt cover by ISBN
            imageUrl = 'https://covers.openlibrary.org/b/isbn/${doc['isbn'][0]}-L.jpg';
          }

          return Book(
            id: id,
            title: title,
            author: author,
            description: description,
            imageUrl: imageUrl,
            publishedDate: publishedDate,
            rating: 0.0, // Open Library does not provide ratings in search results
          );
        }).toList(growable: false);
      }
    } catch (_) {
      // ignore errors and fall back to sample data below
    }

    // Fallback sample data for development/demo
    return [
      Book(
        id: '1',
        title: 'Sample Book One',
        author: 'Author A',
        description: 'A short description of sample book one.',
        imageUrl: '',
        publishedDate: '2020',
        rating: 4.2,
      ),
      Book(
        id: '2',
        title: 'Sample Book Two',
        author: 'Author B',
        description: 'A short description of sample book two.',
        imageUrl: '',
        publishedDate: '2021',
        rating: 3.8,
      ),
    ];
  }
}