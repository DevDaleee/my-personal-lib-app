import 'package:my_personal_lib_app/models/book.dart';

/// Livro de teste com valores padrão; troque só o que importa no teste.
Book fakeBook({
  String id = 'b-1',
  String title = 'Torto Arado',
  String author = 'Itamar Vieira Junior',
  int totalPages = 264,
  int currentPage = 0,
  BookStatus status = BookStatus.wannaRead,
  String? coverUrl,
}) {
  final now = DateTime(2026, 11, 22);
  return Book(
    id: id,
    userId: 'u-1',
    title: title,
    author: author,
    totalPages: totalPages,
    currentPage: currentPage,
    status: status,
    coverUrl: coverUrl,
    owned: true,
    createdAt: now,
    updatedAt: now,
  );
}

/// Os três status, um de cada.
List<Book> sampleShelf() => [
  fakeBook(id: 'b-1', title: 'Grande Sertão: Veredas', author: 'João Guimarães Rosa', totalPages: 624, currentPage: 137, status: BookStatus.reading),
  fakeBook(id: 'b-2', title: 'Torto Arado', author: 'Itamar Vieira Junior', totalPages: 264, status: BookStatus.wannaRead),
  fakeBook(id: 'b-3', title: 'A Hora da Estrela', author: 'Clarice Lispector', totalPages: 88, currentPage: 88, status: BookStatus.read),
];

/// JSON no formato do `GET /books` (opcionais vêm como `null`, como na API).
Map<String, dynamic> bookJson(Book book) => {
  'id': book.id,
  'user_id': book.userId,
  'title': book.title,
  'author': book.author,
  'isbn': book.isbn,
  'total_pages': book.totalPages,
  'current_page': book.currentPage,
  'status': switch (book.status) {
    BookStatus.wannaRead => 'wanna_read',
    BookStatus.reading => 'reading',
    BookStatus.read => 'read',
  },
  'rating': book.rating,
  'notes': book.notes,
  'cover_url': book.coverUrl,
  'owned': book.owned,
  'started_at': book.startedAt?.toIso8601String(),
  'finished_at': book.finishedAt?.toIso8601String(),
  'created_at': book.createdAt.toIso8601String(),
  'updated_at': book.updatedAt.toIso8601String(),
};

/// Respostas do `BookServices`: {"status_code", "data", "error"}.
Map<String, dynamic> booksOk(List<Book> books) => {"status_code": 200, "data": books.map(bookJson).toList(), "error": null};
Map<String, dynamic> booksFailure(int? status, String error) => {"status_code": status, "data": null, "error": error};
