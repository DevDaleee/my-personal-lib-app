import 'package:json_annotation/json_annotation.dart';

part 'book.g.dart';

/// Status do livro. Muda sozinho no back-end conforme a página atual:
/// 0 → wannaRead, entre → reading, igual ao total → read.
enum BookStatus {
  @JsonValue('wanna_read')
  wannaRead,
  @JsonValue('reading')
  reading,
  @JsonValue('read')
  read,
}

/// Livro como vem da API (`GET /books`, `GET /books/{id}`).
/// Os campos opcionais vêm como `null` no JSON.
@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class Book {
  final String id;
  final String userId;
  final String title;
  final String author;
  final String? isbn;
  final int totalPages;
  final int currentPage;
  final BookStatus status;
  final int? rating;
  final String? notes;
  final String? coverUrl;
  final bool owned;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Book({
    required this.id,
    required this.userId,
    required this.title,
    required this.author,
    this.isbn,
    required this.totalPages,
    required this.currentPage,
    required this.status,
    this.rating,
    this.notes,
    this.coverUrl,
    required this.owned,
    this.startedAt,
    this.finishedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Book.fromJson(Map<String, dynamic> json) => _$BookFromJson(json);

  /// Fração lida, de 0 a 1.
  double get progress => totalPages == 0 ? 0 : (currentPage / totalPages).clamp(0, 1);
}
