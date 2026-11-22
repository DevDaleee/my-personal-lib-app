import 'package:flutter_test/flutter_test.dart';
import 'package:my_personal_lib_app/models/book.dart';

void main() {
  // Exemplo real do contrato da API (CLAUDE.md): opcionais vêm como null.
  final json = <String, dynamic>{
    'id': 'eadd1886-1cea-4342-a318-eb4a3113eeb1',
    'user_id': '3d8be433-19f8-4963-b427-61e203353630',
    'title': 'Torto Arado',
    'author': 'Itamar Vieira Junior',
    'isbn': null,
    'total_pages': 264,
    'current_page': 41,
    'status': 'reading',
    'rating': null,
    'notes': null,
    'cover_url': null,
    'owned': true,
    'started_at': '2026-11-21T20:40:42.805588Z',
    'finished_at': null,
    'created_at': '2026-11-21T20:40:42.787628Z',
    'updated_at': '2026-11-21T20:40:42.805588Z',
  };

  test('lê o livro da API, com os opcionais nulos', () {
    final book = Book.fromJson(json);

    expect(book.id, 'eadd1886-1cea-4342-a318-eb4a3113eeb1');
    expect(book.userId, '3d8be433-19f8-4963-b427-61e203353630');
    expect(book.title, 'Torto Arado');
    expect(book.totalPages, 264);
    expect(book.currentPage, 41);
    expect(book.status, BookStatus.reading);
    expect(book.isbn, isNull);
    expect(book.rating, isNull);
    expect(book.coverUrl, isNull);
    expect(book.finishedAt, isNull);
    expect(book.owned, isTrue);
    expect(book.startedAt, DateTime.utc(2026, 11, 21, 20, 40, 42, 805, 588));
  });

  test('lê os três status', () {
    expect(Book.fromJson({...json, 'status': 'wanna_read'}).status, BookStatus.wannaRead);
    expect(Book.fromJson({...json, 'status': 'reading'}).status, BookStatus.reading);
    expect(Book.fromJson({...json, 'status': 'read'}).status, BookStatus.read);
  });

  test('lê os opcionais preenchidos', () {
    final book = Book.fromJson({...json, 'isbn': '9786580309313', 'rating': 5, 'notes': 'Bibiana e Belonísia', 'cover_url': 'https://exemplo.com/capa.jpg'});

    expect(book.isbn, '9786580309313');
    expect(book.rating, 5);
    expect(book.notes, 'Bibiana e Belonísia');
    expect(book.coverUrl, 'https://exemplo.com/capa.jpg');
  });

  test('progress vai de 0 a 1 e não divide por zero', () {
    expect(Book.fromJson(json).progress, closeTo(41 / 264, 1e-9));
    expect(Book.fromJson({...json, 'current_page': 0}).progress, 0);
    expect(Book.fromJson({...json, 'current_page': 264}).progress, 1);
    expect(Book.fromJson({...json, 'total_pages': 0, 'current_page': 0}).progress, 0);
  });
}
