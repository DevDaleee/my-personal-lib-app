import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_personal_lib_app/services/api/dio.dart';
import 'package:my_personal_lib_app/services/api/stats_services.dart';
import 'package:my_personal_lib_app/services/constants.dart';

class MockApiServices extends Mock implements ApiServices {}

class MockDio extends Mock implements Dio {}

final _req = RequestOptions(path: '');

Response<dynamic> _response(int status, Object? data) => Response(requestOptions: _req, statusCode: status, data: data);

void main() {
  late MockDio dio;
  late StatsServices service;

  setUp(() async {
    await GetIt.instance.reset();
    dio = MockDio();
    final api = MockApiServices();
    when(() => api.dio).thenReturn(dio);
    GetIt.instance.registerSingleton<ApiServices>(api);
    service = StatsServices();
  });

  test('getStreak: chama GET /stats/streak e devolve o corpo em data', () async {
    when(() => dio.get<dynamic>(any())).thenAnswer((_) async => _response(200, {'current_streak': 4}));

    final result = await service.getStreak();

    expect(verify(() => dio.get<dynamic>(captureAny())).captured.single, endsWith('/stats/streak'));
    expect(result, {
      'status_code': 200,
      'data': {'current_streak': 4},
      'error': null,
    });
  });

  test('getMonthly: chama GET /stats/monthly com months', () async {
    when(() => dio.get<dynamic>(any(), queryParameters: any(named: 'queryParameters'))).thenAnswer(
      (_) async => _response(200, [
        {'month': '2026-11-01', 'finished_count': 2},
      ]),
    );

    final result = await service.getMonthly(months: 12);

    final captured = verify(() => dio.get<dynamic>(captureAny(), queryParameters: captureAny(named: 'queryParameters'))).captured;
    expect(captured[0], endsWith('/stats/monthly'));
    expect(captured[1], {'months': 12});
    expect(result['data'], [
      {'month': '2026-11-01', 'finished_count': 2},
    ]);
  });

  test('400: devolve a mensagem da API', () async {
    when(() => dio.get<dynamic>(any())).thenAnswer(
      (_) => Future.error(DioException(requestOptions: _req, type: DioExceptionType.badResponse, response: _response(400, {'error': 'Parâmetro inválido'}))),
    );

    final result = await service.getStreak();

    expect(result, {'status_code': 400, 'data': null, 'error': 'Parâmetro inválido'});
  });

  test('sem resposta: mensagem de conexão', () async {
    when(() => dio.get<dynamic>(any())).thenAnswer((_) => Future.error(DioException(requestOptions: _req, type: DioExceptionType.connectionError)));

    final result = await service.getStreak();

    expect(result, {'status_code': null, 'data': null, 'error': ApiErrors.connectionError});
  });
}
