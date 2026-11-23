import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_personal_lib_app/controllers/book_detail_controller.dart';
import 'package:my_personal_lib_app/controllers/library_controller.dart';
import 'package:my_personal_lib_app/models/book.dart';
import 'package:my_personal_lib_app/services/api/book_services.dart';
import 'package:my_personal_lib_app/services/constants.dart';

import '../helpers/books.dart';

class MockBookServices extends Mock implements BookServices {}

class MockLibraryController extends Mock implements LibraryController {}

Map<String, dynamic> _ok(Book book) => {"status_code": 200, "data": bookJson(book), "error": null};

void main() {
  late MockBookServices services;
  late MockLibraryController library;
  late BookDetailController controller;

  /// Abre o controller já com o livro carregado (página 0 de 264).
  Future<void> loadSample() async {
    when(() => services.getBook('b-1')).thenAnswer((_) async => _ok(fakeBook()));
    await controller.load('b-1');
  }

  setUp(() async {
    await GetIt.instance.reset();
    services = MockBookServices();
    library = MockLibraryController();
    when(() => library.fetchBooks()).thenAnswer((_) async {});
    GetIt.instance.registerSingleton<BookServices>(services);
    GetIt.instance.registerSingleton<LibraryController>(library);
    controller = BookDetailController();
  });

  group('load', () {
    test('200: guarda o livro e limpa o erro', () async {
      await loadSample();

      expect(controller.book?.title, 'Torto Arado');
      expect(controller.error, isNull);
      expect(controller.notFound, isFalse);
      expect(controller.isLoading, isFalse);
    });

    test('isLoading fica verdadeiro durante a chamada', () async {
      when(() => services.getBook('b-1')).thenAnswer((_) async => _ok(fakeBook()));

      final future = controller.load('b-1');
      expect(controller.isLoading, isTrue);
      await future;
      expect(controller.isLoading, isFalse);
    });

    test('404: marca notFound, sem mensagem de erro', () async {
      when(() => services.getBook('b-x')).thenAnswer((_) async => booksFailure(404, 'Livro não encontrado'));

      await controller.load('b-x');

      expect(controller.notFound, isTrue);
      expect(controller.error, isNull);
      expect(controller.book, isNull);
    });

    test('erro: guarda a mensagem e mantém o livro que já estava', () async {
      await loadSample();
      when(() => services.getBook('b-1')).thenAnswer((_) async => booksFailure(null, ApiErrors.connectionError));

      await controller.load('b-1');

      expect(controller.error, ApiErrors.connectionError);
      expect(controller.book?.title, 'Torto Arado');
    });

    test('JSON fora do contrato: mensagem genérica', () async {
      when(() => services.getBook('b-1')).thenAnswer((_) async => {"status_code": 200, "data": {'id': 'b-1'}, "error": null});

      await controller.load('b-1');

      expect(controller.error, ApiErrors.unexpectedError);
      expect(controller.book, isNull);
    });
  });

  group('updateProgress', () {
    test('200: troca o livro pelo da API (com o status novo) e recarrega a biblioteca', () async {
      await loadSample();
      when(() => services.updateProgress('b-1', 41)).thenAnswer((_) async => _ok(fakeBook(currentPage: 41, status: BookStatus.reading)));

      final ok = await controller.updateProgress(41);

      expect(ok, isTrue);
      expect(controller.book?.currentPage, 41);
      expect(controller.book?.status, BookStatus.reading);
      expect(controller.updateError, isNull);
      expect(controller.isUpdating, isFalse);
      verify(() => library.fetchBooks()).called(1);
    });

    test('isUpdating fica verdadeiro durante a chamada', () async {
      await loadSample();
      when(() => services.updateProgress('b-1', 10)).thenAnswer((_) async => _ok(fakeBook(currentPage: 10, status: BookStatus.reading)));

      final future = controller.updateProgress(10);
      expect(controller.isUpdating, isTrue);
      await future;
      expect(controller.isUpdating, isFalse);
    });

    test('400: guarda a mensagem, mantém o livro e não recarrega a lista', () async {
      await loadSample();
      when(() => services.updateProgress('b-1', 999)).thenAnswer((_) async => booksFailure(400, 'Página fora do intervalo'));

      final ok = await controller.updateProgress(999);

      expect(ok, isFalse);
      expect(controller.updateError, 'Página fora do intervalo');
      expect(controller.book?.currentPage, 0);
      verifyNever(() => library.fetchBooks());
    });

    test('sem livro carregado: não chama a API', () async {
      final ok = await controller.updateProgress(10);

      expect(ok, isFalse);
      verifyNever(() => services.updateProgress(any(), any()));
    });

    test('nova atualização que dá certo limpa o erro anterior', () async {
      await loadSample();
      when(() => services.updateProgress('b-1', 999)).thenAnswer((_) async => booksFailure(400, 'Erro'));
      await controller.updateProgress(999);
      when(() => services.updateProgress('b-1', 41)).thenAnswer((_) async => _ok(fakeBook(currentPage: 41, status: BookStatus.reading)));

      await controller.updateProgress(41);

      expect(controller.updateError, isNull);
    });
  });
}
