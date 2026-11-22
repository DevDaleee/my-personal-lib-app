import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:my_personal_lib_app/data/shared.dart';
import 'package:my_personal_lib_app/services/api/dio.dart';
import 'package:my_personal_lib_app/services/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Adapter falso: guarda a última requisição e responde com o status pedido.
class FakeAdapter implements HttpClientAdapter {
  FakeAdapter(this.status, [this.body = const {}]);

  final int status;
  final Map<String, dynamic> body;
  RequestOptions? last;

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    last = options;
    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late Dio dio;

  setUp(() async {
    dotenv.loadFromString(envString: 'API_BASE_URL=http://localhost:8080');
    await GetIt.instance.reset();
    GetIt.instance.registerSingleton<SecurityStorage>(SecurityStorage());
    SharedPreferences.setMockInitialValues({tokenKey: 'jwt.salvo', entityId: 'u-1'});
    dio = Dio();
    ApiServices(dio);
  });

  test('manda o token nas rotas protegidas (/books, /stats)', () async {
    final adapter = FakeAdapter(200);
    dio.httpClientAdapter = adapter;

    await dio.get('/books');

    expect(adapter.last!.headers['Authorization'], 'Bearer jwt.salvo');
  });

  test('não manda o token em /auth (o CORS do gateway não libera Authorization lá)', () async {
    final adapter = FakeAdapter(200, {'token': 'novo', 'user_id': 'u-1'});
    dio.httpClientAdapter = adapter;

    await dio.post('/auth/login', data: {'email': 'a@b.com', 'password': '12345678'});

    expect(adapter.last!.headers.containsKey('Authorization'), isFalse);
  });

  test('401 em rota protegida apaga a sessão', () async {
    dio.httpClientAdapter = FakeAdapter(401, {'error': 'Sessão inválida ou expirada. Entre novamente'});

    await expectLater(dio.get('/books'), throwsA(isA<DioException>()));

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(tokenKey), isNull);
    expect(prefs.getString(entityId), isNull);
  });

  test('401 no login (senha errada) não mexe na sessão salva', () async {
    dio.httpClientAdapter = FakeAdapter(401, {'error': 'E-mail ou senha incorretos'});

    await expectLater(dio.post('/auth/login', data: {}), throwsA(isA<DioException>()));

    expect((await SharedPreferences.getInstance()).getString(tokenKey), 'jwt.salvo');
  });
}
