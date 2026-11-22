import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_personal_lib_app/services/api/dio.dart';
import 'package:my_personal_lib_app/services/api/user_services.dart';

class MockApiServices extends Mock implements ApiServices {}

class MockDio extends Mock implements Dio {}

final _req = RequestOptions(path: '');

Response<dynamic> _response(int status, Object? data) => Response(requestOptions: _req, statusCode: status, data: data);

DioException _badResponse(int status, Object? data) =>
    DioException(requestOptions: _req, type: DioExceptionType.badResponse, response: _response(status, data));

/// Toda resposta do service tem as mesmas três chaves.
void expectShape(Map<String, dynamic> result) {
  expect(result.keys, containsAll(['status_code', 'data', 'error']), reason: 'formato único: status_code, data, error');
}

void main() {
  late MockDio dio;
  late UserServices service;

  void stubPost(Future<Response<dynamic>> Function() answer) {
    when(() => dio.post<dynamic>(any(), data: any(named: 'data'))).thenAnswer((_) => answer());
  }

  setUp(() async {
    await GetIt.instance.reset();
    dio = MockDio();
    final api = MockApiServices();
    when(() => api.dio).thenReturn(dio);
    GetIt.instance.registerSingleton<ApiServices>(api);
    service = UserServices();
  });

  group('login', () {
    test('200: devolve o corpo em data e error nulo', () async {
      stubPost(() async => _response(200, {'token': 'jwt.abc', 'user_id': 'u-1'}));

      final result = await service.login('leitor@caderno.com.br', 'Leitura#2026');

      expectShape(result);
      expect(result['status_code'], 200);
      expect(result['data'], {'token': 'jwt.abc', 'user_id': 'u-1'});
      expect(result['error'], isNull);
    });

    test('envia e-mail e senha para /auth/login', () async {
      stubPost(() async => _response(200, {'token': 'jwt.abc', 'user_id': 'u-1'}));

      await service.login('leitor@caderno.com.br', 'Leitura#2026');

      final captured = verify(() => dio.post<dynamic>(captureAny(), data: captureAny(named: 'data'))).captured;
      expect(captured[0], endsWith('/auth/login'));
      expect(captured[1], {'email': 'leitor@caderno.com.br', 'password': 'Leitura#2026'});
    });

    test('401: devolve a mensagem do campo "error" da API', () async {
      stubPost(() => Future.error(_badResponse(401, {'error': 'E-mail ou senha incorretos'})));

      final result = await service.login('leitor@caderno.com.br', 'errada');

      expectShape(result);
      expect(result['status_code'], 401);
      expect(result['data'], isNull);
      expect(result['error'], 'E-mail ou senha incorretos');
    });

    test('sem conexão: status nulo e uma mensagem amigável', () async {
      stubPost(() => Future.error(DioException(requestOptions: _req, type: DioExceptionType.connectionError)));

      final result = await service.login('leitor@caderno.com.br', 'Leitura#2026');

      expectShape(result);
      expect(result['data'], isNull);
      expect(result['error'], isA<String>().having((e) => e, 'mensagem', isNotEmpty));
      expect(result['error'], isNot(contains('Exception')), reason: 'nada de e.toString() para o usuário');
    });

    test('erro inesperado: mensagem amigável, sem detalhes técnicos', () async {
      stubPost(() => Future.error(StateError('quebrou')));

      final result = await service.login('leitor@caderno.com.br', 'Leitura#2026');

      expectShape(result);
      expect(result['error'], isA<String>().having((e) => e, 'mensagem', isNotEmpty));
      expect(result['error'], isNot(contains('StateError')));
    });
  });

  group('register', () {
    const created = {'id': 'u-1', 'email': 'clarice@caderno.com.br', 'name': 'Clarice', 'created_at': '2026-11-22T18:00:00Z'};

    test('201: devolve o corpo em data e error nulo', () async {
      stubPost(() async => _response(201, created));

      final result = await service.register('clarice@caderno.com.br', 'Leitura#2026', 'Clarice');

      expectShape(result);
      expect(result['status_code'], 201);
      expect(result['data'], created);
      expect(result['error'], isNull);
    });

    test('envia name, email e password para /auth/register', () async {
      stubPost(() async => _response(201, created));

      await service.register('clarice@caderno.com.br', 'Leitura#2026', 'Clarice');

      final captured = verify(() => dio.post<dynamic>(captureAny(), data: captureAny(named: 'data'))).captured;
      expect(captured[0], endsWith('/auth/register'));
      expect(captured[1], {'name': 'Clarice', 'email': 'clarice@caderno.com.br', 'password': 'Leitura#2026'});
    });

    test('409: devolve a mensagem do campo "error" da API', () async {
      stubPost(() => Future.error(_badResponse(409, {'error': 'E-mail já cadastrado'})));

      final result = await service.register('clarice@caderno.com.br', 'Leitura#2026', 'Clarice');

      expectShape(result);
      expect(result['status_code'], 409);
      expect(result['error'], 'E-mail já cadastrado');
    });

    test('400 com nome vazio: repassa a mensagem da API', () async {
      stubPost(() => Future.error(_badResponse(400, {'error': 'Nome vazio'})));

      final result = await service.register('clarice@caderno.com.br', 'Leitura#2026', '');

      expect(result['status_code'], 400);
      expect(result['error'], 'Nome vazio');
    });
  });
}
