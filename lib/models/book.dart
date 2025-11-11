import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

class Book {
  final String id;
  final String title;
  final String author;
  final String description;
  final String imageUrl;
  final String publishedDate;
  final double rating;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.imageUrl,
    required this.publishedDate,
    required this.rating,
  });

  factory Book.fromJson(Map<String, dynamic> json) => Book(
        id: json['id']?.toString() ?? '',
        title: json['title'] ?? 'Unknown Title',
        author: json['author'] ?? 'Unknown Author',
        description: json['description'] ?? '',
        imageUrl: json['imageUrl'] ?? '',
        publishedDate: json['publishedDate'] ?? '',
        rating: (json['rating'] is num) ? (json['rating'] as num).toDouble() : 0.0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'author': author,
        'description': description,
        'imageUrl': imageUrl,
        'publishedDate': publishedDate,
        'rating': rating,
      };
}

/// Manual Hive adapter so no build_runner is required.
class BookAdapter extends TypeAdapter<Book> {
  @override
  final typeId = 1;

  @override
  Book read(BinaryReader reader) {
    final map = Map<String, dynamic>.from(reader.readMap());
    return Book.fromJson(map);
  }

  @override
  void write(BinaryWriter writer, Book obj) {
    writer.writeMap(obj.toJson());
  }
}