import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_personal_lib_app/controllers/library_controller.dart';
import 'package:my_personal_lib_app/controllers/new_book_controller.dart';
import 'package:my_personal_lib_app/services/api/book_services.dart';
import 'package:my_personal_lib_app/services/constants.dart';

import '../helpers/books.dart';

class MockBookServices extends Mock implements BookServices {}

class MockLibraryController extends Mock implements LibraryController {}

void main() {
  late MockBookServices services;
  late MockLibraryController library;
  late NewBookController controller;

  // Stub do createBook para qualquer combinação de argumentos.
  void stubCreate(Future<Map<String, dynamic>> Function() answer) {
    when(
      () => services.createBook(
        title: any(named: 'title'),
        author: any(named: 'author'),
        totalPages: any(named: 'totalPages'),
        owned: any(named: 'owned'),
        isbn: any(named: 'isbn'),
        rating: any(named: 'rating'),
        notes: any(named: 'notes'),
        coverUrl: any(named: 'coverUrl'),
      ),
    ).thenAnswer((_) => answer());
  }

  Future<dynamic> saveSample() => controller.save(title: 'Torto Arado', author: 'Itamar Vieira Junior', totalPages: 264);

  setUp(() async {
    await GetIt.instance.reset();
    services = MockBookServices();
    library = MockLibraryController();
    when(() => library.fetchBooks()).thenAnswer((_) async {});
    GetIt.instance.registerSingleton<BookServices>(services);
    GetIt.instance.registerSingleton<LibraryController>(library);
    controller = NewBookController();
  });

  test('começa sem nota, sem exemplar e sem erro', () {
    expect(controller.rating, isNull);
    expect(controller.owned, isFalse);
    expect(controller.error, isNull);
    expect(controller.isSaving, isFalse);
  });

  test('nota: setRating guarda entre 1 e 5 e clearRating volta para "Não avaliado"', () {
    controller.setRating(4);
    expect(controller.rating, 4);
    controller.setRating(9);
    expect(controller.rating, 5);
    controller.clearRating();
    expect(controller.rating, isNull);
  });

  test('201: envia nota e exemplar, devolve o livro e recarrega a biblioteca', () async {
    stubCreate(() async => {"status_code": 201, "data": bookJson(fakeBook(title: 'Torto Arado')), "error": null});
    controller.setRating(5);
    controller.setOwned(true);

    final book = await controller.save(
      title: 'Torto Arado',
      author: 'Itamar Vieira Junior',
      totalPages: 264,
      isbn: '978-65-5921-000-0',
      notes: 'Releitura',
      coverUrl: 'https://exemplo.com/capa.jpg',
    );

    expect(book?.title, 'Torto Arado');
    expect(controller.error, isNull);
    expect(controller.isSaving, isFalse);
    verify(
      () => services.createBook(
        title: 'Torto Arado',
        author: 'Itamar Vieira Junior',
        totalPages: 264,
        owned: true,
        isbn: '978-65-5921-000-0',
        rating: 5,
        notes: 'Releitura',
        coverUrl: 'https://exemplo.com/capa.jpg',
      ),
    ).called(1);
    verify(() => library.fetchBooks()).called(1);
  });

  test('isSaving fica verdadeiro durante a chamada', () async {
    stubCreate(() async => {"status_code": 201, "data": bookJson(fakeBook()), "error": null});

    final future = saveSample();
    expect(controller.isSaving, isTrue);
    await future;
    expect(controller.isSaving, isFalse);
  });

  test('erro da API: guarda a mensagem, devolve null e não recarrega a lista', () async {
    stubCreate(() async => booksFailure(400, 'Total de páginas inválido'));

    final book = await saveSample();

    expect(book, isNull);
    expect(controller.error, 'Total de páginas inválido');
    expect(controller.isSaving, isFalse);
    verifyNever(() => library.fetchBooks());
  });

  test('JSON fora do contrato: mensagem genérica', () async {
    stubCreate(() async => {"status_code": 201, "data": {'id': 'b-1'}, "error": null});

    final book = await saveSample();

    expect(book, isNull);
    expect(controller.error, ApiErrors.unexpectedError);
  });

  test('novo envio que dá certo limpa o erro anterior', () async {
    stubCreate(() async => booksFailure(null, ApiErrors.connectionError));
    await saveSample();
    stubCreate(() async => {"status_code": 201, "data": bookJson(fakeBook()), "error": null});

    await saveSample();

    expect(controller.error, isNull);
  });
}
