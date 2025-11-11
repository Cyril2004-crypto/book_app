import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

class Book {
  final String id;
  final String title;
  final String author;
  final String? description;
  final String imageUrl;
  final String publishedDate;
  final double rating;
  final List<String> subjects;

  Book({
    required this.id,
    required this.title,
    required this.author,
    this.description,
    required this.imageUrl,
    required this.publishedDate,
    required this.rating,
    this.subjects = const [],
  });

  factory Book.fromJson(Map<String, dynamic> json) => Book(
        id: json['id']?.toString() ?? '',
        title: json['title'] ?? 'Unknown Title',
        author: json['author'] ?? 'Unknown Author',
        description: json['description']?.toString(),
        imageUrl: json['imageUrl'] ?? '',
        publishedDate: json['publishedDate'] ?? '',
        rating: (json['rating'] is num) ? (json['rating'] as num).toDouble() : 0.0,
        subjects: (json['subjects'] is List) ? List<String>.from(json['subjects']) : const [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'author': author,
        'description': description,
        'imageUrl': imageUrl,
        'publishedDate': publishedDate,
        'rating': rating,
        'subjects': subjects,
      };

  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? description,
    String? imageUrl,
    String? publishedDate,
    double? rating,
    List<String>? subjects,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      publishedDate: publishedDate ?? this.publishedDate,
      rating: rating ?? this.rating,
      subjects: subjects ?? this.subjects,
    );
  }
}

/// Simple Hive adapter (writes map) — keep same behavior as before.
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