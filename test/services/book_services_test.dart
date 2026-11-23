import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_personal_lib_app/services/api/book_services.dart';
import 'package:my_personal_lib_app/services/constants.dart';
import 'package:my_personal_lib_app/services/api/dio.dart';

class MockApiServices extends Mock implements ApiServices {}

class MockDio extends Mock implements Dio {}

final _req = RequestOptions(path: '');

Response<dynamic> _response(int status, Object? data) => Response(requestOptions: _req, statusCode: status, data: data);

DioException _badResponse(int status, Object? data) =>
    DioException(requestOptions: _req, type: DioExceptionType.badResponse, response: _response(status, data));

void main() {
  late MockDio dio;
  late BookServices service;

  void stubGet(Future<Response<dynamic>> Function() answer) {
    when(() => dio.get<dynamic>(any())).thenAnswer((_) => answer());
  }

  setUp(() async {
    await GetIt.instance.reset();
    dio = MockDio();
    final api = MockApiServices();
    when(() => api.dio).thenReturn(dio);
    GetIt.instance.registerSingleton<ApiServices>(api);
    service = BookServices();
  });

  test('200: chama GET /books e devolve a lista em data', () async {
    stubGet(
      () async => _response(200, [
        {'id': 'b-1'},
      ]),
    );

    final result = await service.getBooks();

    expect(verify(() => dio.get<dynamic>(captureAny())).captured.single, endsWith('/books'));
    expect(result, {
      'status_code': 200,
      'data': [
        {'id': 'b-1'},
      ],
      'error': null,
    });
  });

  test('erro da API: devolve a mensagem do campo "error"', () async {
    stubGet(() => Future.error(_badResponse(500, {'error': 'Erro ao listar livros'})));

    final result = await service.getBooks();

    expect(result, {'status_code': 500, 'data': null, 'error': 'Erro ao listar livros'});
  });

  test('erro sem "error" no corpo: mensagem genérica', () async {
    stubGet(() => Future.error(_badResponse(502, '<html>Bad Gateway</html>')));

    final result = await service.getBooks();

    expect(result['error'], ApiErrors.unexpectedError);
  });

  test('sem resposta: mensagem de conexão e status nulo', () async {
    stubGet(() => Future.error(DioException(requestOptions: _req, type: DioExceptionType.connectionError)));

    final result = await service.getBooks();

    expect(result, {'status_code': null, 'data': null, 'error': ApiErrors.connectionError});
  });

  group('getBook', () {
    test('200: chama GET /books/{id} e devolve o livro em data', () async {
      stubGet(() async => _response(200, {'id': 'b-1', 'title': 'Torto Arado'}));

      final result = await service.getBook('b-1');

      expect(verify(() => dio.get<dynamic>(captureAny())).captured.single, endsWith('/books/b-1'));
      expect(result, {
        'status_code': 200,
        'data': {'id': 'b-1', 'title': 'Torto Arado'},
        'error': null,
      });
    });

    test('404: devolve a mensagem do campo "error" da API', () async {
      stubGet(() => Future.error(_badResponse(404, {'error': 'Livro não encontrado'})));

      final result = await service.getBook('b-x');

      expect(result, {'status_code': 404, 'data': null, 'error': 'Livro não encontrado'});
    });
  });

  group('updateProgress', () {
    void stubPatch(Future<Response<dynamic>> Function() answer) {
      when(() => dio.patch<dynamic>(any(), data: any(named: 'data'))).thenAnswer((_) => answer());
    }

    test('200: chama PATCH /books/{id}/progress só com current_page', () async {
      stubPatch(() async => _response(200, {'id': 'b-1', 'current_page': 41, 'status': 'reading'}));

      final result = await service.updateProgress('b-1', 41);

      final captured = verify(() => dio.patch<dynamic>(captureAny(), data: captureAny(named: 'data'))).captured;
      expect(captured[0], endsWith('/books/b-1/progress'));
      expect(captured[1], {'current_page': 41});
      expect(result['status_code'], 200);
      expect(result['data'], {'id': 'b-1', 'current_page': 41, 'status': 'reading'});
      expect(result['error'], isNull);
    });

    test('400: devolve a mensagem do campo "error" da API', () async {
      stubPatch(() => Future.error(_badResponse(400, {'error': 'Página fora do intervalo'})));

      final result = await service.updateProgress('b-1', 999);

      expect(result, {'status_code': 400, 'data': null, 'error': 'Página fora do intervalo'});
    });
  });

  group('createBook', () {
    void stubPost(Future<Response<dynamic>> Function() answer) {
      when(() => dio.post<dynamic>(any(), data: any(named: 'data'))).thenAnswer((_) => answer());
    }

    List<dynamic> capturedPost() => verify(() => dio.post<dynamic>(captureAny(), data: captureAny(named: 'data'))).captured;

    test('201: chama POST /books com todos os campos e devolve o livro em data', () async {
      stubPost(() async => _response(201, {'id': 'b-1', 'title': 'Torto Arado'}));

      final result = await service.createBook(
        title: '  Torto Arado ',
        author: 'Itamar Vieira Junior',
        totalPages: 264,
        owned: true,
        isbn: '978-65-5921-000-0',
        rating: 5,
        notes: 'Releitura',
        coverUrl: 'https://exemplo.com/capa.jpg',
      );

      final captured = capturedPost();
      expect(captured[0], endsWith('/books'));
      expect(captured[1], {
        'title': 'Torto Arado',
        'author': 'Itamar Vieira Junior',
        'total_pages': 264,
        'owned': true,
        'isbn': '978-65-5921-000-0',
        'rating': 5,
        'notes': 'Releitura',
        'cover_url': 'https://exemplo.com/capa.jpg',
      });
      expect(result, {
        'status_code': 201,
        'data': {'id': 'b-1', 'title': 'Torto Arado'},
        'error': null,
      });
    });

    test('opcionais vazios ou só com espaços vão como null', () async {
      stubPost(() async => _response(201, {'id': 'b-1'}));

      await service.createBook(title: 'Torto Arado', author: 'Itamar', totalPages: 264, owned: false, isbn: '', notes: '   ');

      expect(capturedPost()[1], {
        'title': 'Torto Arado',
        'author': 'Itamar',
        'total_pages': 264,
        'owned': false,
        'isbn': null,
        'rating': null,
        'notes': null,
        'cover_url': null,
      });
    });

    test('400: devolve a mensagem do campo "error" da API', () async {
      stubPost(() => Future.error(_badResponse(400, {'error': 'Total de páginas inválido'})));

      final result = await service.createBook(title: 'Torto Arado', author: 'Itamar', totalPages: 0, owned: false);

      expect(result, {'status_code': 400, 'data': null, 'error': 'Total de páginas inválido'});
    });
  });
}
