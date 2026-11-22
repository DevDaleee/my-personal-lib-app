import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_personal_lib_app/controllers/library_controller.dart';
import 'package:my_personal_lib_app/models/book.dart';
import 'package:my_personal_lib_app/services/api/book_services.dart';
import 'package:my_personal_lib_app/services/constants.dart';

import '../helpers/books.dart';

class MockBookServices extends Mock implements BookServices {}

void main() {
  late MockBookServices services;
  late LibraryController controller;

  setUp(() async {
    await GetIt.instance.reset();
    services = MockBookServices();
    GetIt.instance.registerSingleton<BookServices>(services);
    controller = LibraryController();
  });

  test('sucesso: guarda os livros e limpa o erro', () async {
    when(() => services.getBooks()).thenAnswer((_) async => booksOk(sampleShelf()));

    await controller.fetchBooks();

    expect(controller.books.map((b) => b.title), ['Grande Sertão: Veredas', 'Torto Arado', 'A Hora da Estrela']);
    expect(controller.books.first.status, BookStatus.reading);
    expect(controller.error, isNull);
    expect(controller.isLoading, isFalse);
  });

  test('isLoading fica verdadeiro durante a chamada', () async {
    when(() => services.getBooks()).thenAnswer((_) async => booksOk([]));

    final future = controller.fetchBooks();
    expect(controller.isLoading, isTrue);
    await future;
    expect(controller.isLoading, isFalse);
  });

  test('erro: guarda a mensagem e mantém os livros que já estavam', () async {
    controller.setBooks([fakeBook()]);
    when(() => services.getBooks()).thenAnswer((_) async => booksFailure(null, ApiErrors.connectionError));

    await controller.fetchBooks();

    expect(controller.error, ApiErrors.connectionError);
    expect(controller.books, hasLength(1));
    expect(controller.isLoading, isFalse);
  });

  test('JSON fora do contrato: mensagem genérica', () async {
    when(() => services.getBooks()).thenAnswer(
      (_) async => {
        "status_code": 200,
        "data": [
          {'id': 'b-1'},
        ],
        "error": null,
      },
    );

    await controller.fetchBooks();

    expect(controller.error, ApiErrors.unexpectedError);
    expect(controller.books, isEmpty);
  });

  test('nova busca que dá certo limpa o erro anterior', () async {
    when(() => services.getBooks()).thenAnswer((_) async => booksFailure(500, 'Erro'));
    await controller.fetchBooks();
    when(() => services.getBooks()).thenAnswer((_) async => booksOk([fakeBook()]));

    await controller.fetchBooks();

    expect(controller.error, isNull);
    expect(controller.books, hasLength(1));
  });
}
