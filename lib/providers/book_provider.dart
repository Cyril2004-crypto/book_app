import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../models/book.dart';
import '../services/api_service.dart';

class BookProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  List<Book> _books = [];
  bool _loading = false;
  final Box _favBox = Hive.box('favorites');

  List<Book> get books => _books;
  bool get isLoading => _loading;

  Future<void> loadBooks({String query = 'flutter'}) async {
    _loading = true;
    notifyListeners();
    _books = await _api.fetchBooks(query: query);
    _loading = false;
    notifyListeners();
  }

  Future<void> search(String query) async => await loadBooks(query: query);

  bool isFavorite(String id) {
    return _favBox.get(id, defaultValue: false) as bool;
  }

  void toggleFavorite(Book book) {
    final cur = isFavorite(book.id);
    _favBox.put(book.id, !cur);
    notifyListeners();
  }

  // Remove favorite explicitly
  void removeFavorite(String id) {
    if (isFavorite(id)) {
      _favBox.delete(id);
      notifyListeners();
    }
  }

  List<Book> get favorites =>
      _books.where((b) => isFavorite(b.id)).toList();

  /// Export favorites (book objects) to a JSON file in app documents.
  /// Returns the file path on success, or null on failure.
  Future<String?> exportFavoritesToFile() async {
    try {
      final favs = favorites;
      final List<Map<String, dynamic>> jsonList = favs.map((b) => b.toJson()).toList();
      final jsonStr = const JsonEncoder.withIndent('  ').convert(jsonList);
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}${Platform.pathSeparator}book_app_favorites_${DateTime.now().millisecondsSinceEpoch}.json');
      await file.writeAsString(jsonStr);
      return file.path;
    } catch (e) {
      if (kDebugMode) print('Export favorites failed: $e');
      return null;
    }
  }

  /// Import favorites from a JSON string (expects a list of book objects).
  /// Marks each imported book's id as favorite in the favorites Hive box.
  Future<bool> importFavoritesFromJsonString(String jsonStr) async {
    try {
      final data = json.decode(jsonStr);
      if (data is List) {
        for (final item in data) {
          if (item is Map<String, dynamic>) {
            final book = Book.fromJson(item);
            if (book.id.isNotEmpty) {
              _favBox.put(book.id, true);
            }
          } else if (item is Map) {
            // dynamic map type
            final book = Book.fromJson(Map<String, dynamic>.from(item));
            if (book.id.isNotEmpty) {
              _favBox.put(book.id, true);
            }
          }
        }
        notifyListeners();
        return true;
      }
    } catch (e) {
      if (kDebugMode) print('Import favorites failed: $e');
    }
    return false;
  }

  /// Import favorites from a file path. Returns true on success.
  Future<bool> importFavoritesFromFile(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) return false;
      final jsonStr = await file.readAsString();
      return await importFavoritesFromJsonString(jsonStr);
    } catch (e) {
      if (kDebugMode) print('Import from file failed: $e');
      return false;
    }
  }
}