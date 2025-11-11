import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/book.dart';

class ApiService {
  static const String _base = 'https://openlibrary.org';

  /// Search Open Library (no key required).
  Future<List<Book>> fetchBooks({String query = 'flutter'}) async {
    final uri = Uri.parse('$_base/search.json?q=${Uri.encodeQueryComponent(query)}&limit=30');

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
            imageUrl = 'https://covers.openlibrary.org/b/id/${doc['cover_i']}-M.jpg';
          } else if (doc['isbn'] is List && (doc['isbn'] as List).isNotEmpty) {
            imageUrl = 'https://covers.openlibrary.org/b/isbn/${doc['isbn'][0]}-M.jpg';
          }

          final subjects = (doc['subject'] is List) ? List<String>.from(doc['subject']) : <String>[];

          return Book(
            id: id,
            title: title,
            author: author,
            description: description,
            imageUrl: imageUrl,
            publishedDate: publishedDate,
            rating: 0.0,
            subjects: subjects,
          );
        }).toList(growable: false);
      }
    } catch (_) {
      // ignore and fall through to fallback
    }

    // fallback sample data
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
        description: 'Another sample book.',
        imageUrl: '',
        publishedDate: '2021',
        rating: 3.8,
      ),
    ];
  }

  /// Fetch work details for a work key like "/works/OL123W" and merge into [base].
  Future<Book> fetchWorkDetails(String workKey, Book base) async {
    try {
      final uri = Uri.parse('$_base$workKey.json');
      final res = await http.get(uri).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(res.body) as Map<String, dynamic>;
        // description can be string or {value:...}
        String? description;
        if (data['description'] != null) {
          if (data['description'] is Map && data['description']['value'] != null) {
            description = data['description']['value'].toString();
          } else {
            description = data['description'].toString();
          }
        }

        List<String> subjects = [];
        if (data['subjects'] is List) subjects = List<String>.from(data['subjects']);

        String imageUrl = base.imageUrl;
        if (data['covers'] is List && (data['covers'] as List).isNotEmpty) {
          // take first cover id
          imageUrl = 'https://covers.openlibrary.org/b/id/${data['covers'][0]}-L.jpg';
        }

        return base.copyWith(
          description: description ?? base.description,
          imageUrl: imageUrl,
          // keep other fields same, but include subjects
        ).copyWith(subjects: subjects);
      }
    } catch (_) {
      // ignore
    }
    return base;
  }
}