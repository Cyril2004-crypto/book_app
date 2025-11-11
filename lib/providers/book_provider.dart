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

  // changed: make loadBooks accept optional query and be callable after login
  Future<void> loadBooks({String query = 'flutter'}) async {
    _loading = true;
    notifyListeners();
    _books = await _api.fetchBooks(query: query);
    _loading = false;
    notifyListeners();
  }

  // convenience search
  Future<void> search(String query) async => await loadBooks(query: query);

  bool isFavorite(String id) {
    return _favBox.get(id, defaultValue: false) as bool;
  }

  void toggleFavorite(Book book) {
    final cur = isFavorite(book.id);
    _favBox.put(book.id, !cur);
    notifyListeners();
  }

  List<Book> get favorites => _books.where((b) => isFavorite(b.id)).toList();
}