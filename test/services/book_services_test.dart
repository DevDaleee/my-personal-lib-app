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
}
